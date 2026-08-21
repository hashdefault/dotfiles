#!/bin/sh
# Detects connected monitors and arranges them via xrandr: whichever one
# ranks highest in the DisplayPort > HDMI > VGA priority becomes primary and
# is positioned at x=1920 (physical right); the other goes to x=0 (physical
# left). With only one monitor connected, it's positioned at x=0. Any other
# connected-but-unselected output gets turned off.
#
# The rest of xmonad.hs (myScreenXOffset, trayer --monitor primary, xmobar
# placement) already assumes screen 0 == the xrandr primary output sitting
# at x=1920 -- this script is what has to keep making that true, whichever
# physical port ends up primary.
#
# Port *names* aren't trusted for the priority ranking: at least one of this
# user's rigs has no native VGA connector on the GPU (checked via
# /sys/class/drm -- only *-DP-* and *-HDMI-* exist), so a VGA monitor there
# can only show up through an active DP-to-VGA adapter -- xrandr reports it
# as "DP-1", same as a real DP monitor would be. Two EDID-based signals are
# combined to unmask it, since neither alone covers every adapter seen in
# practice:
#   1. The "digital input" bit (byte 0x14, bit 7 -- VESA EDID spec): true
#      for a genuine analog VGA monitor wired straight into a real VGA
#      port, no adapter involved.
#   2. The EDID's Display Product Name text descriptor containing "VGA":
#      catches *active* DP/HDMI-to-VGA adapters, which negotiate a real
#      digital link with the GPU (so signal 1 alone reports "digital" and
#      misses them) but still self-identify as VGA in their own
#      synthesized EDID. Confirmed on this exact rig's work setup: DP-1's
#      EDID says "Digital display, DisplayPort interface" (byte 0x14 =
#      0xa5, so signal 1 alone is fooled) from manufacturer "TXD" -- but
#      `edid-decode` shows `Display Product Name: 'VGA'`, while the real
#      HDMI-1 monitor's is its actual model, 'S24F350'. Signal 2 is what
#      catches this case.

set -eu

# xrandr's output name doesn't always match the DRM sysfs connector name
# 1:1 (e.g. xrandr "HDMI-1" vs sysfs "HDMI-A-1"), so match by family prefix
# + trailing number instead of an exact string.
edid_path_for() {
  out="$1"
  family=$(echo "$out" | sed -E 's/-[0-9]+$//')
  num=$(echo "$out" | grep -oE '[0-9]+$')
  for d in /sys/class/drm/card*-*; do
    n=$(basename "$d")
    case "$n" in
      card*-"$family"-*-"$num"|card*-"$family"-"$num")
        echo "$d/edid"
        return 0
        ;;
    esac
  done
  return 1
}

# "digital" or "analog" for a connected xrandr output name; "unknown" if its
# EDID can't be read (treated as digital downstream -- trust the port name).
edid_signal_type() {
  out="$1"
  path=$(edid_path_for "$out") || { echo "unknown"; return; }
  byte=$(xxd -s 20 -l 1 -p "$path" 2>/dev/null)
  [ -z "$byte" ] && { echo "unknown"; return; }
  val=$((16#$byte))
  if [ $((val & 0x80)) -ne 0 ]; then
    echo "digital"
  else
    echo "analog"
  fi
}

# Whether a connected output's EDID Display Product Name mentions "VGA" --
# see the header comment (signal 2). Requires edid-decode; silently skipped
# (treated as no match) if it isn't installed.
edid_name_says_vga() {
  out="$1"
  path=$(edid_path_for "$out") || return 1
  command -v edid-decode >/dev/null 2>&1 || return 1
  edid-decode "$path" 2>/dev/null | grep -qi "Display Product Name: '[^']*VGA[^']*'"
}

# True priority class for a connected xrandr output: dp > hdmi > vga.
class_for() {
  out="$1"
  if [ "$(edid_signal_type "$out")" = "analog" ] || edid_name_says_vga "$out"; then
    echo "vga"
    return
  fi
  case "$out" in
    DP-*)   echo "dp" ;;
    HDMI-*) echo "hdmi" ;;
    VGA-*)  echo "vga" ;;
    *)      echo "hdmi" ;; # unrecognized digital connector, mid-tier default
  esac
}

priority() {
  case "$1" in
    dp)   echo 1 ;;
    hdmi) echo 2 ;;
    vga)  echo 3 ;;
    *)    echo 9 ;;
  esac
}

connected=$(xrandr --query | awk '/ connected/{print $1}')

best_out=""
best_pri=99
second_out=""
second_pri=99

for out in $connected; do
  pri=$(priority "$(class_for "$out")")
  if [ "$pri" -lt "$best_pri" ]; then
    second_out=$best_out
    second_pri=$best_pri
    best_out=$out
    best_pri=$pri
  elif [ "$pri" -lt "$second_pri" ]; then
    second_out=$out
    second_pri=$pri
  fi
done

[ -z "$best_out" ] && exit 0  # nothing connected, nothing to do

cmd="xrandr --output $best_out --primary --mode 1920x1080"

if [ -n "$second_out" ]; then
  cmd="$cmd --pos 1920x0 --output $second_out --mode 1920x1080 --pos 0x0"
else
  cmd="$cmd --pos 0x0"
fi

# Turn off any other connected-but-unselected output (e.g. a 3rd monitor).
for out in $connected; do
  case "$out" in
    "$best_out"|"$second_out") ;;
    *) cmd="$cmd --output $out --off" ;;
  esac
done

eval "$cmd"
