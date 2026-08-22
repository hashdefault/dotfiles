#!/usr/bin/env bash
# Theme Chooser for xmonad -- applies a theme to xmonad (borders + xmobar
# workspace colors, via theme.conf + `xmonad --restart`), xmobar (via
# xmobarrc.template + restart.sh), dunst (via dunstrc.template + systemd
# restart), kitty, alacritty, eww, and rofi.
#
# All backgrounds are intentionally kept very dark (near-black) so the
# terminal and topbar read as genuinely dark regardless of theme -- most
# stock palettes (Eldritch, Tokyo Night, ...) ship a background lighter
# than that on purpose; this deliberately goes darker.

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

THEME_FILE="$CONFIG_HOME/xmonad/current-theme.txt"
XMONAD_THEME="$CONFIG_HOME/xmonad/theme.conf"
XMOBAR_TEMPLATE="$CONFIG_HOME/xmobar/xmobarrc.template"
XMOBAR_RC="$CONFIG_HOME/xmobar/xmobarrc"
XMOBAR_RESTART="$CONFIG_HOME/xmobar/restart.sh"
DUNST_TEMPLATE="$CONFIG_HOME/dunst/dunstrc.template"
DUNST_RC="$CONFIG_HOME/dunst/dunstrc"
KITTY_THEME="$CONFIG_HOME/kitty/theme.conf"
ALACRITTY_THEME="$CONFIG_HOME/alacritty/theme.toml"
EWW_THEME="$CONFIG_HOME/eww/theme.scss"
ROFI_THEME="$CONFIG_HOME/rofi/themes/qtile-theme.rasi"

current_theme=$(cat "$THEME_FILE" 2>/dev/null || echo "Eldritch")

# ── Theme definitions ────────────────────────────────────────────────────────
# dark_bg/bar_bg/seg_purple/seg_blue: background depth ramp (terminal /
# topbar / panel / deepest panel), all kept near-black on purpose.
# text/text_dim: primary and secondary foreground.
# primary: the theme's signature accent (focused border, cursor, workspace
# underline). neon_*: full accent palette. muted/muted2/border_*: chrome.
declare -A THEMES

THEMES[Eldritch]="dark_bg=#12142a|bar_bg=#12142a|seg_purple=#1a1c38|seg_blue=#15172e|text=#ebfafa|text_dim=#a4a9c0|primary=#37f499|neon_green=#37f499|neon_cyan=#04d1f9|neon_magenta=#a48cf2|neon_pink=#f265b5|neon_yellow=#f1fc79|red=#f16c75|blue=#04d1f9|muted=#7081d0|muted2=#4b5480|border_normal=#242640|border_unfocused=#3a3d5c"

THEMES[Tokyo\ Night]="dark_bg=#0d0e14|bar_bg=#13141c|seg_purple=#181926|seg_blue=#16161e|text=#c0caf5|text_dim=#9aa5ce|primary=#7aa2f7|neon_green=#9ece6a|neon_cyan=#7dcfff|neon_magenta=#bb9af7|neon_pink=#f7768e|neon_yellow=#e0af68|red=#f7768e|blue=#7aa2f7|muted=#565f89|muted2=#3b3f51|border_normal=#1f2233|border_unfocused=#414868"

THEMES[Cyberpunk\ Neon]="dark_bg=#050508|bar_bg=#0a0a12|seg_purple=#0f0f1c|seg_blue=#0a0e1a|text=#e0e0ff|text_dim=#9a9ac2|primary=#ff2079|neon_green=#00ff9f|neon_cyan=#00f0ff|neon_magenta=#ff00ff|neon_pink=#ff2079|neon_yellow=#fcee0c|red=#ff2a6d|blue=#00b8ff|muted=#6c6c8a|muted2=#3a3a52|border_normal=#1a1a2e|border_unfocused=#33334d"

THEMES[Gruvbox]="dark_bg=#141617|bar_bg=#1a1c1d|seg_purple=#1d2021|seg_blue=#282828|text=#ebdbb2|text_dim=#bdae93|primary=#fe8019|neon_green=#b8bb26|neon_cyan=#8ec07c|neon_magenta=#d3869b|neon_pink=#fb4934|neon_yellow=#fabd2f|red=#fb4934|blue=#83a598|muted=#928374|muted2=#665c54|border_normal=#3c3836|border_unfocused=#504945"

THEMES[Kanagawa]="dark_bg=#0d0c0b|bar_bg=#131211|seg_purple=#181616|seg_blue=#1f1f28|text=#dcd7ba|text_dim=#b8b4a8|primary=#7e9cd8|neon_green=#76946a|neon_cyan=#6a9589|neon_magenta=#957fb8|neon_pink=#d27e99|neon_yellow=#c0a36e|red=#c34043|blue=#7e9cd8|muted=#727169|muted2=#54546d|border_normal=#2a2a37|border_unfocused=#54546d"

THEMES[Monokai]="dark_bg=#19181a|bar_bg=#221f22|seg_purple=#2d2a2e|seg_blue=#403e41|text=#fcfcfa|text_dim=#c1c0b8|primary=#ff6188|neon_green=#a9dc76|neon_cyan=#78dce8|neon_magenta=#ab9df2|neon_pink=#ff6188|neon_yellow=#ffd866|red=#ff6188|blue=#78dce8|muted=#939293|muted2=#727072|border_normal=#403e41|border_unfocused=#5b595c"

THEMES[Dracula]="dark_bg=#14141c|bar_bg=#1b1c28|seg_purple=#21222c|seg_blue=#282a36|text=#f8f8f2|text_dim=#c2c2dc|primary=#ff79c6|neon_green=#50fa7b|neon_cyan=#8be9fd|neon_magenta=#bd93f9|neon_pink=#ff79c6|neon_yellow=#f1fa8c|red=#ff5555|blue=#8be9fd|muted=#6272a4|muted2=#44475a|border_normal=#2c2e3d|border_unfocused=#44475a"

THEMES[Nord]="dark_bg=#14171d|bar_bg=#1c212b|seg_purple=#242933|seg_blue=#2e3440|text=#d8dee9|text_dim=#9aa4b8|primary=#88c0d0|neon_green=#a3be8c|neon_cyan=#88c0d0|neon_magenta=#b48ead|neon_pink=#d08770|neon_yellow=#ebcb8b|red=#bf616a|blue=#81a1c1|muted=#7b88a1|muted2=#4c566a|border_normal=#3b4252|border_unfocused=#4c566a"

THEME_ORDER=("Eldritch" "Tokyo Night" "Cyberpunk Neon" "Gruvbox" "Kanagawa" "Monokai" "Dracula" "Nord")

get_val() {
    local theme_data="$1" key="$2"
    echo "$theme_data" | tr '|' '\n' | grep "^${key}=" | head -1 | cut -d= -f2
}

# ── Resolve chosen theme ─────────────────────────────────────────────────────
if [[ "$1" == "--apply" && -n "$2" ]]; then
    chosen="$2"
else
    menu_entries=""
    for name in "${THEME_ORDER[@]}"; do
        if [[ "$name" == "$current_theme" ]]; then
            menu_entries+="$name (current)\n"
        else
            menu_entries+="$name\n"
        fi
    done
    chosen=$(echo -e "$menu_entries" | sed '/^$/d' | rofi -dmenu -i -p "Theme")
    [[ -z "$chosen" ]] && exit 0
    chosen="${chosen% (current)}"
fi

if [[ -z "${THEMES[$chosen]}" ]]; then
    notify-send "Theme Chooser" "Unknown theme: $chosen" -u critical
    exit 1
fi

echo "$chosen" > "$THEME_FILE"
T="${THEMES[$chosen]}"

dark_bg=$(get_val "$T" "dark_bg")
bar_bg=$(get_val "$T" "bar_bg")
seg_purple=$(get_val "$T" "seg_purple")
seg_blue=$(get_val "$T" "seg_blue")
text=$(get_val "$T" "text")
text_dim=$(get_val "$T" "text_dim")
primary=$(get_val "$T" "primary")
neon_green=$(get_val "$T" "neon_green")
neon_cyan=$(get_val "$T" "neon_cyan")
neon_magenta=$(get_val "$T" "neon_magenta")
neon_pink=$(get_val "$T" "neon_pink")
neon_yellow=$(get_val "$T" "neon_yellow")
red=$(get_val "$T" "red")
blue=$(get_val "$T" "blue")
muted=$(get_val "$T" "muted")
muted2=$(get_val "$T" "muted2")
border_normal=$(get_val "$T" "border_normal")
border_unfocused=$(get_val "$T" "border_unfocused")

# ── xmonad (borders + xmobarPP colors, read at startup by xmonad.hs) ────────
cat > "$XMONAD_THEME" <<EOF
# Auto-generated by theme-chooser - Theme: $chosen
NORMAL_BORDER=$border_normal
FOCUSED_BORDER=$primary
WS_CURRENT=$primary
WS_VISIBLE=$primary
WS_HIDDEN=$neon_magenta
WS_HIDDEN_NOWIN=$muted
WS_URGENT=$red
LAYOUT=$neon_magenta
UNDERLINE=$neon_pink
EOF

# ── xmobar ────────────────────────────────────────────────────────────────
sed \
    -e "s|@@BG@@|$bar_bg|g" \
    -e "s|@@FG@@|$text|g" \
    -e "s|@@RED@@|$red|g" \
    -e "s|@@WARN@@|$neon_yellow|g" \
    -e "s|@@MUTED@@|$muted|g" \
    -e "s|@@GREEN@@|$neon_green|g" \
    -e "s|@@CYAN@@|$neon_cyan|g" \
    -e "s|@@MAGENTA@@|$neon_magenta|g" \
    -e "s|@@PINK@@|$neon_pink|g" \
    -e "s|@@PRIMARY@@|$primary|g" \
    "$XMOBAR_TEMPLATE" \
    > "$XMOBAR_RC"

# ── dunst ─────────────────────────────────────────────────────────────────
if [[ -f "$DUNST_TEMPLATE" ]]; then
    sed \
        -e "s|@@PRIMARY@@|$primary|g" \
        -e "s|@@BORDER_NORMAL@@|$border_normal|g" \
        -e "s|@@MUTED_TEXT@@|$text_dim|g" \
        -e "s|@@BAR_BG@@|$bar_bg|g" \
        -e "s|@@CYAN@@|$neon_cyan|g" \
        -e "s|@@TEXT@@|$text|g" \
        -e "s|@@SEG_PURPLE@@|$seg_purple|g" \
        -e "s|@@RED@@|$red|g" \
        "$DUNST_TEMPLATE" \
        > "$DUNST_RC"
fi

# ── kitty ─────────────────────────────────────────────────────────────────
cat > "$KITTY_THEME" <<EOF
# Auto-generated by theme-chooser - Theme: $chosen
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

# ── alacritty ─────────────────────────────────────────────────────────────
cat > "$ALACRITTY_THEME" <<EOF
# Auto-generated by theme-chooser - Theme: $chosen

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

# ── eww ───────────────────────────────────────────────────────────────────
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

# ── rofi ──────────────────────────────────────────────────────────────────
mkdir -p "${ROFI_THEME%/*}"
cat > "$ROFI_THEME" <<EOF
/* Auto-generated by theme-chooser - Theme: $chosen */

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
}

mainbox {
    children: [ inputbar, message, listview, mode-switcher ];
    spacing:  0;
    padding:  0;
    background-color: @bg;
}

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

scrollbar {
    width:            4px;
    handle-width:     4px;
    handle-color:     @surface1;
    background-color: transparent;
    border-radius:    4px;
}
EOF

# ── Apply live ────────────────────────────────────────────────────────────
# THEME_DRY_RUN=1 regenerates every config file above but skips restarting
# anything -- useful to preview a theme's output before disrupting the
# running session.
if [[ "$THEME_DRY_RUN" == "1" ]]; then
    echo "Dry run: files regenerated for $chosen, nothing restarted."
    exit 0
fi

# xmonad: re-exec picks up the new theme.conf (no recompile needed, since
# xmonad.hs reads it at runtime in `main`).
xmonad --restart 2>/dev/null

# xmobar: no live-reload, kill + respawn.
"$XMOBAR_RESTART" &disown

# dunst: runs as a systemd --user service.
systemctl --user restart dunst.service 2>/dev/null || (pkill dunst 2>/dev/null; dunst -config "$DUNST_RC" &disown)

# kitty: auto-reloads theme.conf on file change (modern kitty), SIGUSR1 kept
# as a harmless nudge for older builds.
pkill -SIGUSR1 kitty 2>/dev/null

# alacritty: live_config_reload is on by default, but touch to be safe.
touch "$ALACRITTY_THEME"

# eww: explicit reload.
if command -v eww >/dev/null 2>&1; then
    eww reload 2>/dev/null || true
fi

(sleep 1; notify-send "Theme Chooser" "Applied theme: $chosen" -t 3000) &disown
