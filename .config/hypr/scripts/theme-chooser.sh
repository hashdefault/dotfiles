#!/usr/bin/env bash
# Theme Chooser for Wayland — applies theme to niri, Hyprland, Waybar, Rofi,
# Fuzzel, Walker, Swaylock, Eww, QuickShell, Ghostty, Kitty, and Alacritty.
#
# Every generated background alpha targets ~0.9 opacity, to match the
# compositor-level transparency+blur defaults set in niri's config.kdl and
# Hyprland's hyprland.conf.

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
PANEL_ALPHA_HEX="e6" # ~0.9 opacity, appended/prepended to RRGGBB colors

THEME_FILE="$CONFIG_HOME/hypr/current-theme.txt"
HYPR_THEME="$CONFIG_HOME/hypr/theme.conf"
NIRI_CONFIG="$CONFIG_HOME/niri/config.kdl"
WAYBAR_COLOR="$CONFIG_HOME/waybar/colors/current-theme.css"
ROFI_THEME="$CONFIG_HOME/rofi/themes/qtile-theme.rasi"
FUZZEL_THEME="$CONFIG_HOME/fuzzel/fuzzel.ini"
WALKER_STYLE="$CONFIG_HOME/walker/themes/default/style.css"
SWAYLOCK_THEME="$CONFIG_HOME/swaylock/theme.conf"
QS_THEME="$CONFIG_HOME/quickshell/theme.js"
QS_THEME_QML="$CONFIG_HOME/quickshell/Theme.qml"
EWW_THEME="$CONFIG_HOME/eww/theme.scss"
WOFI_STYLE="$CONFIG_HOME/wofi/style.css"
GHOSTTY_THEME="$CONFIG_HOME/ghostty/theme.ghostty"
KITTY_THEME="$CONFIG_HOME/kitty/theme.conf"
ALACRITTY_THEME="$CONFIG_HOME/alacritty/theme.toml"

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


THEMES[Tokyo\ Night]="
neon_green=#66c43e|neon_cyan=#7dcfff|neon_magenta=#a05ee0|neon_pink=#e04870|neon_yellow=#e0af68
dark_bg=#1a1b26|bar_bg=#1a1b26|text=#c0caf5|border_focus=#7dcfff|border_normal=#24283b
border_unfocused=#414868|seg_purple=#24283b|seg_blue=#1f2335|red=#f7768e|blue=#4e84e8|primary=#38a0d8
muted=#565f89|muted2=#414868"




THEMES[Everforest]="
neon_green=#7ab358|neon_cyan=#7fbbb3|neon_magenta=#c474a8|neon_pink=#de6878|neon_yellow=#dbbc7f
dark_bg=#0e1011|bar_bg=#0e1011|text=#d3c6aa|border_focus=#a7c080|border_normal=#343f44
border_unfocused=#3d484d|seg_purple=#15191c|seg_blue=#191d20|red=#e67e80|blue=#52a8a8|primary=#7ab358
muted=#7a8478|muted2=#5c6a72"

THEMES[Rose\ Pine]="
neon_green=#9ccfd8|neon_cyan=#31748f|neon_magenta=#c4a7e7|neon_pink=#eb6f92|neon_yellow=#f6c177
dark_bg=#191724|bar_bg=#1f1d2e|text=#e0def4|border_focus=#31748f|border_normal=#26233a
border_unfocused=#403d52|seg_purple=#1f1d2e|seg_blue=#26233a|red=#eb6f92|blue=#9ccfd8|primary=#31748f
muted=#6e6a86|muted2=#524f67"

# Doom One: fundo cinza-azulado escuro, cores médias saturadas nos widgets
# Branco #f8f8f2 sobre os médios: vermelho ~5.7:1, roxo ~6.6:1, azul ~5:1
THEMES[Doom\ One]="
neon_green=#98c379|neon_cyan=#56b6c2|neon_magenta=#c678dd|neon_pink=#e06c75|neon_yellow=#e5c07b
dark_bg=#21252b|bar_bg=#282c34|text=#f8f8f2|border_focus=#61afef|border_normal=#3e4451
border_unfocused=#4f5666|seg_purple=#2c313a|seg_blue=#21252b|red=#e06c75|blue=#4a90d9|primary=#4a90d9
muted=#5c6370|muted2=#4b5263"

THEMES[Monokai]="
neon_green=#a9dc76|neon_cyan=#78dce8|neon_magenta=#ab9df2|neon_pink=#ff6188|neon_yellow=#ffd866
dark_bg=#0f0e0f|bar_bg=#141315|text=#fcfcfa|border_focus=#ff6188|border_normal=#403e41
border_unfocused=#5b595c|seg_purple=#232224|seg_blue=#1e1c1e|red=#ff6188|blue=#78dce8|primary=#ff6188
muted=#939293|muted2=#727072"

THEMES[Solarized\ Dark]="
neon_green=#859900|neon_cyan=#2aa198|neon_magenta=#d33682|neon_pink=#cb4b16|neon_yellow=#b58900
dark_bg=#002b36|bar_bg=#002b36|text=#eee8d5|border_focus=#268bd2|border_normal=#073642
border_unfocused=#586e75|seg_purple=#073642|seg_blue=#00212b|red=#dc322f|blue=#268bd2|primary=#268bd2
muted=#93a1a1|muted2=#657b83"

THEMES[Eldritch]="
neon_green=#37f499|neon_cyan=#04d1f9|neon_magenta=#a48cf2|neon_pink=#f265b5|neon_yellow=#f1fc79
dark_bg=#0a0b12|bar_bg=#0f1019|text=#ebfafa|border_focus=#37f499|border_normal=#323449
border_unfocused=#7081d0|seg_purple=#171823|seg_blue=#10121c|red=#f16c75|blue=#04d1f9|primary=#37f499
muted=#7081d0|muted2=#535d8f"

# Amber: warm ember/amber glass — matches waybar's Amber Sunset + fuzzel
THEMES[Amber]="
neon_green=#9fbf6e|neon_cyan=#4fa8a0|neon_magenta=#c98a5e|neon_pink=#ff6a3d|neon_yellow=#ffd27a
dark_bg=#0a0a0a|bar_bg=#0c0c0c|text=#f5ead8|border_focus=#ffb454|border_normal=#2a1c0e
border_unfocused=#6b5636|seg_purple=#131313|seg_blue=#0f0f0f|red=#ff5f4d|blue=#5f8fae|primary=#ffb454
muted=#a08a63|muted2=#6b5636"

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
    for name in "Cyberpunk" "Nord" "Tokyo Night" "Everforest" "Rose Pine" "Doom One" "Eldritch" "Monokai" "Solarized Dark" "Amber"; do
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
mkdir -p \
    "${THEME_FILE%/*}" \
    "${HYPR_THEME%/*}" \
    "${WAYBAR_COLOR%/*}" \
    "${ROFI_THEME%/*}" \
    "${FUZZEL_THEME%/*}" \
    "${WALKER_STYLE%/*}" \
    "${SWAYLOCK_THEME%/*}" \
    "${QS_THEME%/*}" \
    "${QS_THEME_QML%/*}" \
    "${EWW_THEME%/*}" \
    "${WOFI_STYLE%/*}" \
    "${GHOSTTY_THEME%/*}" \
    "${KITTY_THEME%/*}" \
    "${ALACRITTY_THEME%/*}"

# One-time setup: Walker needs its full default theme directory present
# under $XDG_CONFIG_HOME before we can override just style.css inside it.
if [[ ! -f "$CONFIG_HOME/walker/themes/default/layout.xml" && -d /etc/xdg/walker/themes/default ]]; then
    cp -rn /etc/xdg/walker/themes/default/. "$CONFIG_HOME/walker/themes/default/" 2>/dev/null
fi

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

cat > "$HYPR_THEME" <<EOF
# Auto-generated by theme-chooser - Theme: $chosen
general:col.active_border = $(to_rgba "$border_focus")
general:col.inactive_border = $(to_rgba_aa "$border_unfocused")
decoration:shadow:color = $(to_rgba "$dark_bg")
EOF

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
    printf "rgba(%d, %d, %d, 0.9)" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
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
    bg-a:         ${bar_bg}${PANEL_ALPHA_HEX};
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
    background-color: @bg-a;
    transparency:     "real";
}

mainbox {
    children: [ inputbar, message, listview, mode-switcher ];
    spacing:  0;
    padding:  0;
    background-color: @bg-a;
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
    background-color: @bg-a;
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
    background-color: @bg-a;
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

# ── Helper: replace one INI-style [section] in place, keeping the rest of ────
# the file untouched. Used for apps (like fuzzel) whose config file mixes
# user-tuned settings with theme colors in one flat file with no import
# mechanism, so we can't just overwrite the whole thing on every switch.
replace_ini_section() {
    local file="$1" section="$2" content="$3"
    if [[ ! -f "$file" ]]; then
        printf '[%s]\n%s\n' "$section" "$content" > "$file"
        return
    fi
    awk -v section="[$section]" -v content="$content" '
        BEGIN { in_section = 0; printed = 0 }
        $0 == section {
            print section
            print content
            in_section = 1
            printed = 1
            next
        }
        in_section && /^\[/ { in_section = 0 }
        !in_section { print }
        END {
            if (!printed) {
                print ""
                print section
                print content
            }
        }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# ── Apply to Fuzzel ──────────────────────────────────────────────────────────
# fuzzel.ini has no import/include mechanism, so only the [colors] section
# is regenerated in place — [main] (font size, icon theme, etc.) is left
# exactly as the user configured it.
fuzzel_colors="background=${dark_bg#\#}${PANEL_ALPHA_HEX}
text=${text#\#}ff
prompt=${primary#\#}ff
placeholder=${muted#\#}aa
input=${text#\#}ff
match=${primary#\#}ff
selection=${seg_purple#\#}${PANEL_ALPHA_HEX}
selection-text=ffffffff
selection-match=${neon_pink#\#}ff
border=${primary#\#}ff
counter=${muted#\#}ff"
replace_ini_section "$FUZZEL_THEME" "colors" "$fuzzel_colors"

# ── Apply to Walker ──────────────────────────────────────────────────────────
# Only style.css is regenerated; the rest of the "default" theme (layout.xml,
# item*.xml, keybind.xml, preview.xml) was copied once from /etc/xdg and is
# left alone.
cat > "$WALKER_STYLE" <<EOF
/* Auto-generated by theme-chooser — Theme: $chosen */
@define-color window_bg_color $bar_bg;
@define-color accent_bg_color $primary;
@define-color theme_fg_color $text;
@define-color error_bg_color $red;
@define-color error_fg_color $text;

* {
  all: unset;
}

popover {
  background: lighter(@window_bg_color);
  border: 1px solid darker(@accent_bg_color);
  border-radius: 18px;
  padding: 10px;
}

.normal-icons {
  -gtk-icon-size: 16px;
}

.large-icons {
  -gtk-icon-size: 32px;
}

scrollbar {
  opacity: 0;
}

.box-wrapper {
  box-shadow:
    0 19px 38px rgba(0, 0, 0, 0.3),
    0 15px 12px rgba(0, 0, 0, 0.22);
  background: alpha(@window_bg_color, 0.9);
  padding: 20px;
  border-radius: 20px;
  border: 1px solid darker(@accent_bg_color);
}

.preview-box,
.elephant-hint,
.placeholder {
  color: @theme_fg_color;
}

.search-container {
  border-radius: 10px;
}

.input placeholder {
  opacity: 0.5;
}

.input selection {
  background: lighter(lighter(lighter(@window_bg_color)));
}

.input {
  caret-color: @theme_fg_color;
  background: alpha(@window_bg_color, 0.9);
  padding: 10px;
  color: @theme_fg_color;
}

.list {
  color: @theme_fg_color;
}

.item-box {
  border-radius: 10px;
  padding: 10px;
}

.item-quick-activation {
  background: alpha(@accent_bg_color, 0.25);
  border-radius: 5px;
  padding: 10px;
}

child:selected .item-box,
row:selected .item-box {
  background: alpha(@accent_bg_color, 0.25);
}

.item-subtext {
  font-size: 12px;
  opacity: 0.5;
}

.providerlist .item-subtext {
  font-size: unset;
  opacity: 0.75;
}

.item-image-text {
  font-size: 28px;
}

.preview {
  border: 1px solid alpha(@accent_bg_color, 0.25);
  border-radius: 10px;
  color: @theme_fg_color;
}

.calc .item-text {
  font-size: 24px;
}

.symbols .item-image {
  font-size: 24px;
}

.todo.done .item-text-box {
  opacity: 0.25;
}

.todo.urgent {
  font-size: 24px;
}

.todo.active {
  font-weight: bold;
}

.bluetooth.disconnected {
  opacity: 0.5;
}

.preview .large-icons {
  -gtk-icon-size: 64px;
}

.keybinds {
  padding-top: 10px;
  border-top: 1px solid lighter(@window_bg_color);
  font-size: 12px;
  color: @theme_fg_color;
}

.keybind-button {
  opacity: 0.5;
}

.keybind-button:hover {
  opacity: 0.75;
}

.keybind-bind {
  text-transform: lowercase;
  opacity: 0.35;
}

.keybind-label {
  padding: 2px 4px;
  border-radius: 4px;
  border: 1px solid @theme_fg_color;
}

.error {
  padding: 10px;
  background: @error_bg_color;
  color: @error_fg_color;
}

:not(.calc).current {
  font-style: italic;
}

.preview-content.archlinuxpkgs,
.preview-content.dnfpackages,
.preview-content.aptpackages {
  font-family: monospace;
}
EOF

# ── Apply to Swaylock ────────────────────────────────────────────────────────
# Colors only. ~/.local/bin/lockscreen passes --config "$SWAYLOCK_THEME" and
# keeps the non-color flags (effects, indicator geometry, fonts) itself.
# swaylock wants "rrggbb[aa]" with no leading #.
cat > "$SWAYLOCK_THEME" <<EOF
# Auto-generated by theme-chooser — Theme: $chosen
color=${dark_bg#\#}${PANEL_ALPHA_HEX}
inside-color=${dark_bg#\#}8c
ring-color=${primary#\#}
key-hl-color=${neon_cyan#\#}
bs-hl-color=${red#\#}
ring-ver-color=${neon_green#\#}
inside-ver-color=${dark_bg#\#}8c
ring-wrong-color=${red#\#}
inside-wrong-color=${dark_bg#\#}8c
ring-clear-color=${neon_cyan#\#}
inside-clear-color=${dark_bg#\#}8c
line-color=00000000
separator-color=00000000
text-color=${primary#\#}
text-ver-color=${neon_green#\#}
text-wrong-color=${red#\#}
text-clear-color=${neon_cyan#\#}
EOF

# ── Apply to niri (live) ─────────────────────────────────────────────────────
# config.kdl has no include mechanism either, so the theme-relevant lines are
# tagged with trailing "// @theme:*" markers and updated surgically in place.
if [[ -f "$NIRI_CONFIG" ]]; then
    sed -i \
        -e "s|^\(\s*active-color \"\)[^\"]*\(\" *// @theme:focus-active\)|\1${border_focus}\2|" \
        -e "s|^\(\s*inactive-color \"\)[^\"]*\(\" *// @theme:focus-inactive\)|\1${border_unfocused}\2|" \
        -e "s|^\(\s*active-color \"\)[^\"]*\(\" *// @theme:border-active\)|\1${border_focus}\2|" \
        -e "s|^\(\s*inactive-color \"\)[^\"]*\(\" *// @theme:border-inactive\)|\1${border_unfocused}\2|" \
        -e "s|^\(\s*urgent-color \"\)[^\"]*\(\" *// @theme:border-urgent\)|\1${red}\2|" \
        "$NIRI_CONFIG"
    command -v niri >/dev/null 2>&1 && niri msg action load-config-file >/dev/null 2>&1
fi

# ── Apply to Dunst ───────────────────────────────────────────────────────────
DUNST_THEME="$CONFIG_HOME/dunst/theme.conf"
if [[ -d "$CONFIG_HOME/dunst" ]]; then
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
    dunst -config "$CONFIG_HOME/dunst/dunstrc" &disown 2>/dev/null
fi

# ── Apply to QuickShell ───────────────────────────────────────────────────────
accent_hex="${primary#\#}"
accent_r=$((16#${accent_hex:0:2}))
accent_g=$((16#${accent_hex:2:2}))
accent_b=$((16#${accent_hex:4:2}))

seg_purple_hex="${seg_purple#\#}"
seg_purple_r=$((16#${seg_purple_hex:0:2}))
seg_purple_g=$((16#${seg_purple_hex:2:2}))
seg_purple_b=$((16#${seg_purple_hex:4:2}))

seg_blue_hex="${seg_blue#\#}"
seg_blue_r=$((16#${seg_blue_hex:0:2}))
seg_blue_g=$((16#${seg_blue_hex:2:2}))
seg_blue_b=$((16#${seg_blue_hex:4:2}))

border_unfocused_hex="${border_unfocused#\#}"
border_unfocused_r=$((16#${border_unfocused_hex:0:2}))
border_unfocused_g=$((16#${border_unfocused_hex:2:2}))
border_unfocused_b=$((16#${border_unfocused_hex:4:2}))

dark_bg_hex="${dark_bg#\#}"
dark_bg_r=$((16#${dark_bg_hex:0:2}))
dark_bg_g=$((16#${dark_bg_hex:2:2}))
dark_bg_b=$((16#${dark_bg_hex:4:2}))

# QuickShell panels support real transparency (layer-shell alpha), so panel
# backgrounds default to translucent: Qt/QML wants alpha-first hex (#AARRGGBB).
to_argb() { echo "#${PANEL_ALPHA_HEX}${1#\#}"; }
gradient_top_a=$(to_argb "$bar_bg")
gradient_mid_a=$(to_argb "$seg_purple")
gradient_bottom_a=$(to_argb "$seg_blue")
card_bg_a=$(to_argb "$seg_purple")

cat > "$QS_THEME" <<EOF
// Auto-generated by theme-chooser — Theme: $chosen
var gradientTop = "$gradient_top_a"
var gradientMid = "$gradient_mid_a"
var gradientBottom = "$gradient_bottom_a"
var border = "$border_unfocused"
var borderDim = "$border_normal"
var accent = "$primary"
var accentR = $accent_r
var accentG = $accent_g
var accentB = $accent_b
var text = "$text"
var textMuted = "$muted"
var textDim = "$muted2"
var cardBg = "$card_bg_a"
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
    readonly property string gradientTop: "$gradient_top_a"
    readonly property string gradientMid: "$gradient_mid_a"
    readonly property string gradientBottom: "$gradient_bottom_a"
    readonly property string border: "$border_unfocused"
    readonly property string borderDim: "$border_normal"
    readonly property string accent: "$primary"
    readonly property int accentR: $accent_r
    readonly property int accentG: $accent_g
    readonly property int accentB: $accent_b
    readonly property string text: "$text"
    readonly property string textMuted: "$muted"
    readonly property string textDim: "$muted2"
    readonly property string cardBg: "$card_bg_a"
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

# ── Apply to Eww ─────────────────────────────────────────────────────────────
cat > "$EWW_THEME" <<EOF
/* Auto-generated by theme-chooser - Theme: $chosen */

\$bg: $bar_bg;
\$bg_alt: $seg_purple;
\$bg_panel: $seg_blue;
\$fg: $text;
\$fg_soft: $text;
\$fg_softer: $muted;
\$fg_softest: $neon_cyan;
\$muted: $muted;
\$muted2: $muted2;
\$cyan: $neon_cyan;
\$cyan_dim: $blue;
\$green: $neon_green;
\$pink: $primary;
\$pink_dim: $neon_pink;
\$magenta: $neon_magenta;
\$yellow: $neon_yellow;
\$blue: $blue;
\$red: $red;
\$red_dim: $red;
EOF

if command -v eww >/dev/null 2>&1; then
    eww reload 2>/dev/null || true
elif [[ -x "$HOME/.local/bin/eww" ]]; then
    "$HOME/.local/bin/eww" reload 2>/dev/null || true
fi

# ── Apply to Wofi ────────────────────────────────────────────────────────────
cat > "$WOFI_STYLE" <<EOF
/* ================================================================
   Wofi — $chosen Launcher
   Auto-generated by theme-chooser — Theme: $chosen
   ================================================================

   Tokens:
     gradientTop  $bar_bg   gradientMid  $seg_purple   gradientBottom $seg_blue
     border       $border_unfocused   borderDim    $border_normal
     accent       $primary   cyan         $neon_cyan   purple  $neon_magenta
     text         $text   textMuted    $muted   textDim $muted2
     red          $red   orange       $neon_yellow   pink    $neon_pink
   ================================================================ */

* {
    font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
    font-size: 13.5px;
    transition: background-color 120ms ease, border-color 120ms ease, color 120ms ease;
}

/* ── Window shell ─────────────────────────────────────── */

window {
    background: transparent;
    border-radius: 20px;
}

#window {
    background: transparent;
    border-radius: 20px;
}

#outer-box {
    background: linear-gradient(
        160deg,
        $seg_purple 0%,
        $bar_bg 45%,
        $seg_blue 100%
    );
    border: 1px solid $border_unfocused;
    border-radius: 20px;
    box-shadow:
        0 32px 96px rgba(0, 0, 0, 0.75),
        0 0 0 1px rgba($accent_r, $accent_g, $accent_b, 0.07),
        inset 0 1px 0 rgba(255, 255, 255, 0.05);
    padding: 0;
}

/* ── Accent top bar ───────────────────────────────────── */

#outer-box > box:first-child {
    border-top: 2px solid $primary;
    border-radius: 20px 20px 0 0;
}

/* ── Search input ─────────────────────────────────────── */

#input {
    background: rgba($seg_purple_r, $seg_purple_g, $seg_purple_b, 0.90);
    color: $text;
    border: none;
    border-bottom: 1px solid $border_normal;
    border-radius: 20px 20px 0 0;
    padding: 18px 24px 16px 24px;
    font-size: 15px;
    font-weight: 500;
    letter-spacing: 0.5px;
    caret-color: $primary;
}

#input:focus {
    background: rgba($seg_purple_r, $seg_purple_g, $seg_purple_b, 1.0);
    border-bottom-color: $primary;
    color: $text;
}

/* Placeholder text (pango rendered, pick up via opacity trick) */
#input > placeholder {
    color: $muted2;
    opacity: 0.8;
}

/* ── Scroll / list container ──────────────────────────── */

#scroll {
    background: transparent;
    margin: 0;
    padding: 0;
}

#inner-box {
    background: transparent;
    padding: 8px 10px 14px 10px;
}

/* ── Entry rows ───────────────────────────────────────── */

#entry {
    background: transparent;
    border: 1px solid transparent;
    border-left: 3px solid transparent;
    border-radius: 12px;
    padding: 9px 14px 9px 12px;
    margin: 2px 0;
}

#entry:hover {
    background: rgba($accent_r, $accent_g, $accent_b, 0.07);
    border-color: rgba($border_unfocused_r, $border_unfocused_g, $border_unfocused_b, 0.6);
    border-left-color: rgba($accent_r, $accent_g, $accent_b, 0.45);
}

#entry:selected {
    background: linear-gradient(
        90deg,
        rgba($accent_r, $accent_g, $accent_b, 0.18) 0%,
        rgba($accent_r, $accent_g, $accent_b, 0.06) 55%,
        transparent 100%
    );
    border-color: rgba($accent_r, $accent_g, $accent_b, 0.2);
    border-left-color: $primary;
    box-shadow:
        inset 0 0 0 1px rgba($accent_r, $accent_g, $accent_b, 0.12),
        0 3px 12px rgba(0, 0, 0, 0.30);
}

/* ── Entry icon ───────────────────────────────────────── */

#img {
    border-radius: 8px;
    min-width: 32px;
    min-height: 32px;
    background: rgba($seg_blue_r, $seg_blue_g, $seg_blue_b, 0.75);
    padding: 2px;
}

/* ── Entry text ───────────────────────────────────────── */

#text {
    color: $text;
    margin-left: 8px;
    font-size: 13.5px;
}

#entry:selected #text {
    color: $text;
    font-weight: 600;
}

/* Entry action sub-label */
#entry-default {
    color: $muted;
    font-size: 12px;
    font-weight: 400;
    font-style: italic;
}

/* Numeric shortcut hint */
#num {
    color: $muted2;
    font-size: 11px;
    font-weight: 700;
    margin-right: 4px;
    min-width: 20px;
}

#entry:selected #num {
    color: $primary;
}

/* ── Scrollbar ────────────────────────────────────────── */

scrollbar {
    background: transparent;
    border-radius: 6px;
    margin: 8px 4px 8px 0;
    opacity: 0.6;
}

scrollbar trough {
    background: rgba($dark_bg_r, $dark_bg_g, $dark_bg_b, 0.5);
    border-radius: 6px;
    min-width: 5px;
}

scrollbar slider {
    background: $border_unfocused;
    border-radius: 6px;
    min-width: 5px;
    min-height: 28px;
    border: 1px solid rgba(255, 255, 255, 0.04);
}

scrollbar slider:hover {
    background: rgba($accent_r, $accent_g, $accent_b, 0.65);
    opacity: 1;
}

scrollbar slider:active {
    background: $primary;
    opacity: 1;
}

/* ── No results state ─────────────────────────────────── */

#no-results {
    color: $muted2;
    font-size: 13px;
    font-style: italic;
    padding: 24px;
}
EOF

# ── Apply to Ghostty ─────────────────────────────────────────────────────────
cat > "$GHOSTTY_THEME" <<EOF
# Auto-generated by theme-chooser — Theme: $chosen
background = $dark_bg
foreground = $text
cursor-color = $primary
selection-background = $seg_purple
selection-foreground = $text

palette = 0=$dark_bg
palette = 1=$red
palette = 2=$neon_green
palette = 3=$neon_yellow
palette = 4=$blue
palette = 5=$neon_magenta
palette = 6=$neon_cyan
palette = 7=$text
palette = 8=$muted
palette = 9=$red
palette = 10=$neon_green
palette = 11=$neon_yellow
palette = 12=$blue
palette = 13=$neon_magenta
palette = 14=$neon_cyan
palette = 15=$text
EOF
pkill -SIGUSR2 ghostty 2>/dev/null || true

# ── Apply to Kitty ───────────────────────────────────────────────────────────
cat > "$KITTY_THEME" <<EOF
# Auto-generated by theme-chooser — Theme: $chosen
background $dark_bg
foreground $text
cursor $primary
selection_background $seg_purple
selection_foreground $text

color0 $dark_bg
color1 $red
color2 $neon_green
color3 $neon_yellow
color4 $blue
color5 $neon_magenta
color6 $neon_cyan
color7 $text
color8 $muted
color9 $red
color10 $neon_green
color11 $neon_yellow
color12 $blue
color13 $neon_magenta
color14 $neon_cyan
color15 $text
EOF
pkill -SIGUSR1 kitty 2>/dev/null || true

# ── Apply to Alacritty ───────────────────────────────────────────────────────
cat > "$ALACRITTY_THEME" <<EOF
# Auto-generated by theme-chooser — Theme: $chosen

[colors.primary]
background = "$dark_bg"
foreground = "$text"

[colors.cursor]
text = "$dark_bg"
cursor = "$primary"

[colors.selection]
text = "$text"
background = "$seg_purple"

[colors.normal]
black = "$dark_bg"
red = "$red"
green = "$neon_green"
yellow = "$neon_yellow"
blue = "$blue"
magenta = "$neon_magenta"
cyan = "$neon_cyan"
white = "$text"

[colors.bright]
black = "$muted"
red = "$red"
green = "$neon_green"
yellow = "$neon_yellow"
blue = "$blue"
magenta = "$neon_magenta"
cyan = "$neon_cyan"
white = "$text"
EOF
touch "$ALACRITTY_THEME"

# ── Reload Waybar ────────────────────────────────────────────────────────────
# Waybar has reload_style_on_change: true, but we touch the file to be safe
touch "$WAYBAR_COLOR"

# ── Restart QuickShell to pick up new theme ──────────────────────────────────
# Kill only the quickshell instances that were running and relaunch them
# (except for the ThemeChooser itself)
(
    sleep 0.3
    # Capture currently running quickshell QML files
    running_qmls=$(pgrep -f "quickshell -p" | xargs -r ps -o args= -p 2>/dev/null | grep -oP '(?<=-p\s)\S+' | grep -v "ThemeChooserWindow.qml" | grep -v "shell.qml" | sort -u)
    
    pkill -x quickshell 2>/dev/null
    sleep 0.5
    
    # Relaunch the ones that were actually running
    for qml in $running_qmls; do
        quickshell -p "$qml" &disown 2>/dev/null
    done
) &disown 2>/dev/null

notify-send "Theme Chooser" "Applied theme: $chosen" -t 3000
