#!/usr/bin/env bash
# Theme Chooser for Hyprland — applies theme to Hyprland, Waybar, and Rofi

THEME_FILE="$HOME/.config/hypr/current-theme.txt"
WAYBAR_COLOR="$HOME/.config/waybar/colors/current-theme.css"
ROFI_THEME="$HOME/.config/rofi/themes/qtile-theme.rasi"
QS_THEME="$HOME/.config/quickshell/theme.js"
QS_THEME_QML="$HOME/.config/quickshell/Theme.qml"

current_theme=$(cat "$THEME_FILE" 2>/dev/null || echo "Cyberpunk")

# ── Theme definitions ────────────────────────────────────────────────────────
# Each theme: "name|neon_green|neon_cyan|neon_magenta|neon_pink|neon_yellow|
#   dark_bg|bar_bg|text|border_focus|border_normal|border_unfocused|
#   seg_purple|seg_blue|red|blue|primary|muted|muted2"

declare -A THEMES

THEMES[Cyberpunk]="
neon_green=#00ff41|neon_cyan=#00f0ff|neon_magenta=#ff00ff|neon_pink=#ff2079|neon_yellow=#ffc75f
dark_bg=#0a0a0a|bar_bg=#0a0a14|text=#e0e0ff|border_focus=#ff2079|border_normal=#1a1a2e
border_unfocused=#317aaa|seg_purple=#1a0a2e|seg_blue=#0a1a2e|red=#e15656|blue=#9cb0ff|primary=#ff2079
muted=#6c6c8a|muted2=#4a4a6a"

THEMES[Nord]="
neon_green=#a3be8c|neon_cyan=#88c0d0|neon_magenta=#b48ead|neon_pink=#d08770|neon_yellow=#ebcb8b
dark_bg=#2e3440|bar_bg=#2e3440|text=#d8dee9|border_focus=#88c0d0|border_normal=#3b4252
border_unfocused=#4c566a|seg_purple=#3b4252|seg_blue=#434c5e|red=#bf616a|blue=#81a1c1|primary=#88c0d0
muted=#7b88a1|muted2=#616e88"

THEMES[Gruvbox]="
neon_green=#b8bb26|neon_cyan=#83a598|neon_magenta=#d3869b|neon_pink=#fb4934|neon_yellow=#fabd2f
dark_bg=#282828|bar_bg=#282828|text=#ebdbb2|border_focus=#fabd2f|border_normal=#3c3836
border_unfocused=#504945|seg_purple=#3c3836|seg_blue=#504945|red=#fb4934|blue=#83a598|primary=#fabd2f
muted=#928374|muted2=#7c6f64"

THEMES[Tokyo\ Night]="
neon_green=#9ece6a|neon_cyan=#7dcfff|neon_magenta=#bb9af7|neon_pink=#f7768e|neon_yellow=#e0af68
dark_bg=#1a1b26|bar_bg=#1a1b26|text=#c0caf5|border_focus=#7dcfff|border_normal=#24283b
border_unfocused=#414868|seg_purple=#24283b|seg_blue=#1f2335|red=#f7768e|blue=#7aa2f7|primary=#7dcfff
muted=#565f89|muted2=#414868"

THEMES[Catppuccin\ Mocha]="
neon_green=#a6e3a1|neon_cyan=#89dceb|neon_magenta=#cba6f7|neon_pink=#f5c2e7|neon_yellow=#f9e2af
dark_bg=#1e1e2e|bar_bg=#1e1e2e|text=#cdd6f4|border_focus=#89dceb|border_normal=#313244
border_unfocused=#45475a|seg_purple=#181825|seg_blue=#11111b|red=#f38ba8|blue=#89b4fa|primary=#94e2d5
muted=#6c7086|muted2=#585b70"

THEMES[Cyan\ Noir]="
neon_green=#00f5d4|neon_cyan=#00d4ff|neon_magenta=#7c3aed|neon_pink=#22d3ee|neon_yellow=#fde68a
dark_bg=#050608|bar_bg=#050608|text=#e6f7ff|border_focus=#00d4ff|border_normal=#10131a
border_unfocused=#0b1a22|seg_purple=#0b1016|seg_blue=#071019|red=#f87171|blue=#38bdf8|primary=#00d4ff
muted=#475569|muted2=#334155"

THEMES[Matcha]="
neon_green=#a7f3a3|neon_cyan=#69d2b4|neon_magenta=#b48ead|neon_pink=#f2b5d4|neon_yellow=#e6d98f
dark_bg=#101612|bar_bg=#101612|text=#e9f5ee|border_focus=#69d2b4|border_normal=#1a221c
border_unfocused=#2a3530|seg_purple=#151d18|seg_blue=#12221a|red=#f28b82|blue=#8fd3c7|primary=#69d2b4
muted=#7f978c|muted2=#5a6e63"

# ── Helper: parse theme value ────────────────────────────────────────────────
get_val() {
    local theme_data="$1" key="$2"
    echo "$theme_data" | tr '|' '\n' | grep "^${key}=" | head -1 | cut -d= -f2
}

# ── Resolve chosen theme ─────────────────────────────────────────────────────
if [[ "$1" == "--apply" ]]; then
    # Called from QuickShell — theme already written to file
    chosen=$(cat "$THEME_FILE" 2>/dev/null)
else
    # Interactive rofi menu
    menu_entries=""
    for name in "Cyberpunk" "Nord" "Gruvbox" "Tokyo Night" "Catppuccin Mocha" "Cyan Noir" "Matcha"; do
        if [[ "$name" == "$current_theme" ]]; then
            menu_entries+="$name (current)\n"
        else
            menu_entries+="$name\n"
        fi
    done

    chosen=$(echo -e "$menu_entries" | sed '/^$/d' | rofi -dmenu -i -p "Theme" -theme "$ROFI_THEME")
    [[ -z "$chosen" ]] && exit 0
    chosen="${chosen% (current)}"
fi

# Validate
if [[ -z "${THEMES[$chosen]}" ]]; then
    notify-send "Theme Chooser" "Unknown theme: $chosen" -u critical
    exit 1
fi

# ── Save selection ───────────────────────────────────────────────────────────
echo "$chosen" > "$THEME_FILE"
T="${THEMES[$chosen]}"

# ── Apply to Hyprland (live) ─────────────────────────────────────────────────
border_focus=$(get_val "$T" "border_focus")
border_normal=$(get_val "$T" "border_normal")
border_unfocused=$(get_val "$T" "border_unfocused")
dark_bg=$(get_val "$T" "dark_bg")

# Convert #rrggbb to rgba(rrggbbee)
to_rgba() { echo "rgba(${1#\#}ee)"; }
to_rgba_aa() { echo "rgba(${1#\#}aa)"; }

hyprctl keyword general:col.active_border "$(to_rgba "$border_focus")"
hyprctl keyword general:col.inactive_border "$(to_rgba_aa "$border_unfocused")"
hyprctl keyword decoration:shadow:color "$(to_rgba "$dark_bg")"

# ── Apply to Waybar ──────────────────────────────────────────────────────────
neon_green=$(get_val "$T" "neon_green")
neon_cyan=$(get_val "$T" "neon_cyan")
neon_magenta=$(get_val "$T" "neon_magenta")
neon_pink=$(get_val "$T" "neon_pink")
neon_yellow=$(get_val "$T" "neon_yellow")
bar_bg=$(get_val "$T" "bar_bg")
text=$(get_val "$T" "text")
seg_purple=$(get_val "$T" "seg_purple")
seg_blue=$(get_val "$T" "seg_blue")
red=$(get_val "$T" "red")
blue=$(get_val "$T" "blue")
primary=$(get_val "$T" "primary")
muted=$(get_val "$T" "muted")
muted2=$(get_val "$T" "muted2")

# Extract r,g,b from hex for rgba background
hex_to_rgba() {
    local hex="${1#\#}"
    printf "rgba(%d, %d, %d, 0.95)" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

cat > "$WAYBAR_COLOR" <<EOF
/* Auto-generated by theme-chooser — Theme: $chosen */
@define-color background $(hex_to_rgba "$bar_bg");
@define-color foreground $text;
@define-color cursor $neon_magenta;

@define-color color1  $neon_pink;      /* accent pink */
@define-color color2  $neon_magenta;   /* accent purple */
@define-color color3  $neon_yellow;    /* accent yellow */
@define-color color4  $neon_green;     /* accent green */
@define-color color5  $primary;        /* primary */
@define-color color6  $red;            /* red/coral */
@define-color color7  $blue;           /* blue */

@define-color color8  $dark_bg;        /* dark base */
@define-color color9  $neon_pink;      /* bright pink */
@define-color color10 $neon_magenta;   /* magenta */
@define-color color11 $neon_yellow;    /* yellow */
@define-color color12 $neon_cyan;      /* bright cyan */
@define-color color13 $muted;          /* muted */
@define-color color14 $blue;           /* blue alt */
@define-color color15 $text;           /* near-white */

@define-color color16 $seg_blue;
EOF

# ── Apply to Rofi ────────────────────────────────────────────────────────────
cat > "$ROFI_THEME" <<EOF
/* Auto-generated by theme-chooser — Theme: $chosen */

* {
    bg:           $bar_bg;
    bg-alt:       $seg_purple;
    bg-selected:  $seg_blue;
    fg:           $text;
    fg-dim:       $muted;
    neon-pink:    $primary;
    neon-cyan:    $neon_cyan;
    neon-purple:  $neon_magenta;
    neon-yellow:  $neon_yellow;
    border-neon:  $primary;
    urgent:       $red;
    surface0:     ${seg_purple}cc;
    surface1:     ${muted2}88;
    subtext0:     $muted;

    background-color: transparent;
    text-color:       @fg;
    margin:           0;
    padding:          0;
    spacing:          0;
}

window {
    location:         center;
    width:            640px;
    border:           2px;
    border-color:     @surface1;
    border-radius:    20px;
    background-color: @bg;
    transparency:     "real";
}

mainbox {
    children: [ inputbar, message, listview, mode-switcher ];
    spacing:  0;
    padding:  0;
    background-color: @bg;
}

/* ── Floating search bar ── */
inputbar {
    children:         [ prompt, entry ];
    padding:          16px 22px;
    margin:           12px 12px 0 12px;
    background-color: @bg-alt;
    border:           1px;
    border-color:     @bg-selected;
    border-radius:    14px;
    spacing:          12px;
}

prompt {
    text-color:       @neon-pink;
    background-color: transparent;
    padding:          0 12px 0 0;
    font:             "JetBrains Mono Nerd Font Bold 13";
    vertical-align:   0.5;
}

entry {
    text-color:        @fg;
    placeholder:       "Type to search...";
    placeholder-color: @fg-dim;
    background-color:  transparent;
    cursor:            text;
    vertical-align:    0.5;
}

/* ── Messages ── */
message {
    padding:          10px 22px;
    margin:           8px 12px 0 12px;
    background-color: @bg-alt;
    border-radius:    10px;
}

textbox {
    text-color:       @neon-yellow;
    background-color: transparent;
}

/* ── Results list ── */
listview {
    lines:            8;
    columns:          1;
    fixed-height:     true;
    padding:          8px 6px;
    margin:           8px 0 0 0;
    background-color: @bg;
    scrollbar:        false;
    spacing:          4px;
}

element {
    padding:          12px 18px;
    spacing:          14px;
    border-radius:    12px;
    background-color: transparent;
}

element normal.normal,
element alternate.normal {
    background-color: transparent;
    text-color:       @subtext0;
}

element normal.urgent,
element alternate.urgent {
    background-color: transparent;
    text-color:       @urgent;
}

element normal.active,
element alternate.active {
    background-color: transparent;
    text-color:       @neon-pink;
}

element selected.normal {
    background-color: @neon-pink;
    text-color:       @bg;
    border:           0;
}

element selected.urgent {
    background-color: @urgent;
    text-color:       @bg;
    border:           0;
}

element selected.active {
    background-color: @neon-pink;
    text-color:       @bg;
    border:           0;
}

element-icon {
    size:             26px;
    vertical-align:   0.5;
    background-color: transparent;
}

element-text {
    text-color:       inherit;
    vertical-align:   0.5;
    background-color: transparent;
}

element-text selected.normal {
    background-color: @neon-pink;
    text-color:       @bg;
}

element-icon selected.normal {
    background-color: @neon-pink;
}

/* ── Mode switcher tabs ── */
mode-switcher {
    padding:          8px 12px 12px 12px;
    spacing:          8px;
    background-color: @bg;
}

button {
    padding:          10px 0;
    border-radius:    10px;
    background-color: @bg-alt;
    text-color:       @fg-dim;
    font:             "JetBrains Mono Nerd Font 11";
    horizontal-align: 0.5;
}

button selected {
    background-color: @neon-pink;
    text-color:       @bg;
    border:           0;
}

/* ── Scrollbar ── */
scrollbar {
    width:            4px;
    handle-width:     4px;
    handle-color:     @surface1;
    background-color: transparent;
    border-radius:    4px;
}
EOF

# ── Apply to Dunst ───────────────────────────────────────────────────────────
DUNST_THEME="$HOME/.config/dunst/theme.conf"
if [[ -d "$HOME/.config/dunst" ]]; then
    cat > "$DUNST_THEME" <<EOF
# Auto-generated by theme-chooser — Theme: $chosen
[global]
frame_color = "$primary"

[urgency_low]
background = "$bar_bg"
foreground = "$text"
frame_color = "$neon_cyan"

[urgency_normal]
background = "$bar_bg"
foreground = "$text"
frame_color = "$primary"

[urgency_critical]
background = "$bar_bg"
foreground = "$text"
frame_color = "$red"
EOF
    pkill dunst 2>/dev/null
    dunst -config ~/.config/dunst/dunstrc &disown 2>/dev/null
fi

# ── Apply to QuickShell ───────────────────────────────────────────────────────
accent_hex="${primary#\#}"
accent_r=$((16#${accent_hex:0:2}))
accent_g=$((16#${accent_hex:2:2}))
accent_b=$((16#${accent_hex:4:2}))

cat > "$QS_THEME" <<EOF
// Auto-generated by theme-chooser — Theme: $chosen
var gradientTop = "$bar_bg"
var gradientMid = "$seg_purple"
var gradientBottom = "$seg_blue"
var border = "$border_unfocused"
var borderDim = "$border_normal"
var accent = "$primary"
var accentR = $accent_r
var accentG = $accent_g
var accentB = $accent_b
var text = "$text"
var textMuted = "$muted"
var textDim = "$muted2"
var cardBg = "$seg_purple"
var darkBase = "$dark_bg"
var red = "$red"
var green = "$neon_green"
var orange = "$neon_yellow"
var purple = "$neon_magenta"
var yellow = "$neon_yellow"
var cyan = "$neon_cyan"
var pink = "$neon_pink"
EOF

cat > "$QS_THEME_QML" <<EOF
import QtQuick

QtObject {
    // Auto-generated by theme-chooser — Theme: $chosen
    readonly property string gradientTop: "$bar_bg"
    readonly property string gradientMid: "$seg_purple"
    readonly property string gradientBottom: "$seg_blue"
    readonly property string border: "$border_unfocused"
    readonly property string borderDim: "$border_normal"
    readonly property string accent: "$primary"
    readonly property int accentR: $accent_r
    readonly property int accentG: $accent_g
    readonly property int accentB: $accent_b
    readonly property string text: "$text"
    readonly property string textMuted: "$muted"
    readonly property string textDim: "$muted2"
    readonly property string cardBg: "$seg_purple"
    readonly property string darkBase: "$dark_bg"
    readonly property string red: "$red"
    readonly property string green: "$neon_green"
    readonly property string orange: "$neon_yellow"
    readonly property string purple: "$neon_magenta"
    readonly property string yellow: "$neon_yellow"
    readonly property string cyan: "$neon_cyan"
    readonly property string pink: "$neon_pink"
}
EOF

# ── Reload Waybar ────────────────────────────────────────────────────────────
# Waybar has reload_style_on_change: true, but we touch the file to be safe
touch "$WAYBAR_COLOR"

# ── Restart QuickShell to pick up new theme ──────────────────────────────────
# Kill all quickshell instances and relaunch the persistent ones
(
    sleep 0.3
    pkill -x quickshell 2>/dev/null
    sleep 0.5
    quickshell -p "$HOME/.config/quickshell/shell.qml" &disown 2>/dev/null
    quickshell -p "$HOME/.config/quickshell/Tips/TipsWindow.qml" &disown 2>/dev/null
) &disown 2>/dev/null

notify-send "Theme Chooser" "Applied theme: $chosen" -t 3000
