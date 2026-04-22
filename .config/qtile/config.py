import os
import subprocess
import time
from sys import byteorder

from libqtile import bar, hook, layout, qtile, widget
from libqtile.backend.wayland import inputs
from libqtile.config import Click, Drag, Group, Key, Match, Rule, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = guess_terminal('ghostty')

COLORSCHEMES = {
    "Cyberpunk": {
        "neon_green": "#00ff41",
        "neon_cyan": "#00f0ff",
        "neon_magenta": "#ff00ff",
        "neon_pink": "#ff2079",
        "neon_pink_dim": "#cc77aa",
        "neon_yellow": "#ffc75f",
        "dark_bg": "#0a0a0a",
        "border_normal": "#1a1a2e",
        "border_unfocused": "#317aaa",
        "border_focus": "#ff2079",
        "border_focus_dim": "#cc77aa",
        "border_stack": "#e75480",
        "bar_bg": "#0a0a14",
        "seg_purple": "#1a0a2e",
        "seg_blue": "#0a1a2e",
        "text": "#e0e0ff",
        "text_soft": "#d7e6ff",
        "text_softer": "#e3edff",
        "text_softest": "#f1f6ff",
        "muted": "#6c6c8a",
        "muted2": "#4a4a6a",
        "cyan_dim": "#27c6f5",
        "green_dim": "#8fe9b6",
        "red": "#e15656",
        "red_dim": "#f17f7f",
        "blue": "#9cb0ff",
        "pink_dim": "#ff0055",
        "primary": "#ff2079",
        "primary_dim": "#ff2079",
    },
    "Nord": {
        "neon_green": "#a3be8c",
        "neon_cyan": "#88c0d0",
        "neon_magenta": "#b48ead",
        "neon_pink": "#d08770",
        "neon_pink_dim": "#bf616a",
        "neon_yellow": "#ebcb8b",
        "dark_bg": "#2e3440",
        "border_normal": "#3b4252",
        "border_unfocused": "#4c566a",
        "border_focus": "#88c0d0",
        "border_focus_dim": "#81a1c1",
        "border_stack": "#b48ead",
        "bar_bg": "#2e3440",
        "seg_purple": "#3b4252",
        "seg_blue": "#434c5e",
        "text": "#d8dee9",
        "text_soft": "#e5e9f0",
        "text_softer": "#eceff4",
        "text_softest": "#f1f3f6",
        "muted": "#7b88a1",
        "muted2": "#616e88",
        "cyan_dim": "#8fbcbb",
        "green_dim": "#a3be8c",
        "red": "#bf616a",
        "red_dim": "#d08770",
        "blue": "#81a1c1",
        "pink_dim": "#bf616a",
        "primary": "#88c0d0",
        "primary_dim": "#88c0d0",
    },
    "Tokyo Night": {
        "neon_green": "#66c43e",
        "neon_cyan": "#7dcfff",
        "neon_magenta": "#a05ee0",
        "neon_pink": "#e04870",
        "neon_pink_dim": "#ff9e64",
        "neon_yellow": "#e0af68",
        "dark_bg": "#1a1b26",
        "border_normal": "#24283b",
        "border_unfocused": "#414868",
        "border_focus": "#7dcfff",
        "border_focus_dim": "#2ac3de",
        "border_stack": "#c0caf5",
        "bar_bg": "#1a1b26",
        "seg_purple": "#24283b",
        "seg_blue": "#1f2335",
        "text": "#c0caf5",
        "text_soft": "#c0caf5",
        "text_softer": "#a9b1d6",
        "text_softest": "#d5d6f3",
        "muted": "#565f89",
        "muted2": "#414868",
        "cyan_dim": "#2ac3de",
        "green_dim": "#66c43e",
        "red": "#f7768e",
        "red_dim": "#db4b4b",
        "blue": "#4e84e8",
        "pink_dim": "#e04870",
        "primary": "#38a0d8",
        "primary_dim": "#38a0d8",
    },
    "Everforest": {
        "neon_green": "#7ab358",
        "neon_cyan": "#7fbbb3",
        "neon_magenta": "#c474a8",
        "neon_pink": "#de6878",
        "neon_pink_dim": "#e67e80",
        "neon_yellow": "#dbbc7f",
        "dark_bg": "#1e2326",
        "border_normal": "#343f44",
        "border_unfocused": "#3d484d",
        "border_focus": "#a7c080",
        "border_focus_dim": "#7ab358",
        "border_stack": "#7ab358",
        "bar_bg": "#1e2326",
        "seg_purple": "#272e33",
        "seg_blue": "#2d353b",
        "text": "#d3c6aa",
        "text_soft": "#d3c6aa",
        "text_softer": "#cbbda0",
        "text_softest": "#e0d8c0",
        "muted": "#7a8478",
        "muted2": "#5c6a72",
        "cyan_dim": "#5a9e96",
        "green_dim": "#7ab358",
        "red": "#e67e80",
        "red_dim": "#c36064",
        "blue": "#52a8a8",
        "pink_dim": "#de6878",
        "primary": "#7ab358",
        "primary_dim": "#7ab358",
    },
    "Rose Pine": {
        "neon_green": "#9ccfd8",
        "neon_cyan": "#31748f",
        "neon_magenta": "#c4a7e7",
        "neon_pink": "#eb6f92",
        "neon_pink_dim": "#d05070",
        "neon_yellow": "#f6c177",
        "dark_bg": "#191724",
        "border_normal": "#26233a",
        "border_unfocused": "#403d52",
        "border_focus": "#31748f",
        "border_focus_dim": "#26607a",
        "border_stack": "#c4a7e7",
        "bar_bg": "#1f1d2e",
        "seg_purple": "#1f1d2e",
        "seg_blue": "#26233a",
        "text": "#e0def4",
        "text_soft": "#d9d7ee",
        "text_softer": "#cccbe8",
        "text_softest": "#eae8f8",
        "muted": "#6e6a86",
        "muted2": "#524f67",
        "cyan_dim": "#26607a",
        "green_dim": "#9ccfd8",
        "red": "#eb6f92",
        "red_dim": "#c85070",
        "blue": "#9ccfd8",
        "pink_dim": "#d05070",
        "primary": "#31748f",
        "primary_dim": "#31748f",
    },
    "Verde": {
        "neon_green": "#3a8a52",
        "neon_cyan": "#52a870",
        "neon_magenta": "#3a8a52",
        "neon_pink": "#1a4d26",
        "neon_pink_dim": "#163822",
        "neon_yellow": "#6ee7b7",
        "dark_bg": "#060e08",
        "border_normal": "#163822",
        "border_unfocused": "#265c38",
        "border_focus": "#3ddb6a",
        "border_focus_dim": "#3ddb6a",
        "border_stack": "#3a8a52",
        "bar_bg": "#0a1a0d",
        "seg_purple": "#0e2916",
        "seg_blue": "#091c10",
        "text": "#edfaef",
        "text_soft": "#d9f5dc",
        "text_softer": "#c8f0cc",
        "text_softest": "#f2fdf3",
        "muted": "#376648",
        "muted2": "#1e4230",
        "cyan_dim": "#3a8a52",
        "green_dim": "#3a8a52",
        "red": "#52a870",
        "red_dim": "#3a8a52",
        "blue": "#1c5c3e",
        "pink_dim": "#1a4d26",
        "primary": "#1e5c30",
        "primary_dim": "#1e5c30",
    },
    "Doom One": {
        "neon_green": "#98c379",
        "neon_cyan": "#56b6c2",
        "neon_magenta": "#c678dd",
        "neon_pink": "#e06c75",
        "neon_pink_dim": "#c9545d",
        "neon_yellow": "#e5c07b",
        "dark_bg": "#21252b",
        "border_normal": "#3e4451",
        "border_unfocused": "#4f5666",
        "border_focus": "#61afef",
        "border_focus_dim": "#4a90d9",
        "border_stack": "#c678dd",
        "bar_bg": "#282c34",
        "seg_purple": "#2c313a",
        "seg_blue": "#21252b",
        "text": "#f8f8f2",
        "text_soft": "#f0f0e8",
        "text_softer": "#e8e8e0",
        "text_softest": "#fafaf5",
        "muted": "#5c6370",
        "muted2": "#4b5263",
        "cyan_dim": "#46a6b2",
        "green_dim": "#98c379",
        "red": "#e06c75",
        "red_dim": "#c9545d",
        "blue": "#4a90d9",
        "pink_dim": "#e06c75",
        "primary": "#4a90d9",
        "primary_dim": "#4a90d9",
    },
}

THEME_FILE = os.path.expanduser("~/.config/hypr/current-theme.txt")
LEGACY_THEME_FILE = os.path.expanduser("~/.config/qtile/colorscheme.txt")
ROFI_THEME_FILE = os.path.expanduser("~/.config/rofi/themes/qtile-theme.rasi")

def normalize_theme_name(name):
    return name

def load_theme_name():
    for path in (THEME_FILE, LEGACY_THEME_FILE):
        try:
            with open(path, "r", encoding="utf-8") as f:
                name = normalize_theme_name(f.read().strip())
                if name in COLORSCHEMES:
                    return name
        except FileNotFoundError:
            pass
        except Exception:
            pass
    return "Cyberpunk"

THEME_NAME = load_theme_name()
theme = COLORSCHEMES[THEME_NAME]

def _theme_vars(t):
    return {
        "bg": t["bar_bg"],
        "bg_alt": t["seg_purple"],
        "bg_panel": t["seg_blue"],
        "fg": t["text"],
        "fg_soft": t["text_soft"],
        "fg_softer": t["text_softer"],
        "fg_softest": t["text_softest"],
        "muted": t["muted"],
        "muted2": t["muted2"],
        "cyan": t["neon_cyan"],
        "cyan_dim": t["cyan_dim"],
        "green": t["green_dim"],
        "pink": t["primary"],
        "pink_dim": t["primary_dim"],
        "magenta": t["neon_magenta"],
        "yellow": t["neon_yellow"],
        "blue": t["blue"],
        "red": t["red"],
        "red_dim": t["red_dim"],
    }

def _write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def _persist_theme_name(theme_name):
    theme_name = normalize_theme_name(theme_name)
    _write_file(THEME_FILE, theme_name)
    _write_file(LEGACY_THEME_FILE, theme_name)

def _write_rofi_theme(t):
    vars = _theme_vars(t)
    content = f"""/* Auto-generated by qtile colorscheme */

* {{
    bg:           {vars['bg']};
    bg-alt:       {vars['bg_alt']};
    bg-selected:  {vars['bg_panel']};
    fg:           {vars['fg']};
    fg-dim:       {vars['muted']};
    neon-pink:    {vars['pink']};
    neon-cyan:    {vars['cyan']};
    neon-purple:  {vars['magenta']};
    neon-yellow:  {vars['yellow']};
    border-neon:  {vars['pink']};
    urgent:       {vars['red']};

    background-color: @bg;
    text-color:       @fg;
    margin:           0;
    padding:          0;
    spacing:          0;
}}

window {{
    location:         center;
    width:            600px;
    height:           600px;
    border:           0;
    border-radius:    16px;
    background-color: @bg;
}}

mainbox {{
    children: [ inputbar, message, listview ];
    spacing:  0;
}}

inputbar {{
    children:         [ prompt, entry ];
    padding:          14px 18px;
    background-color: @bg-alt;
    border:           0;
}}

prompt {{
    text-color:       @neon-cyan;
    background-color: @bg-alt;
    padding:          0 12px 0 0;
    font:             "JetBrains Mono Nerd Font Bold 13";
}}

entry {{
    text-color:        @fg;
    placeholder:       "Search...";
    placeholder-color: @fg-dim;
    border-radius:     5px;
    background-color:  @bg-alt;
    cursor:            text;
    padding:           3px;
}}

message {{
    padding:          10px 18px;
    background-color: @bg-alt;
    border:           0;
}}

textbox {{
    text-color: @neon-yellow;
}}

listview {{
    lines:      8;
    columns:    1;
    fixed-height: true;
    padding:    8px 0;
    background-color: @bg;
}}

element {{
    padding:       10px 18px;
    spacing:       12px;
    border-radius: 10px;
}}

element normal.normal {{
    background-color: @bg;
    text-color:       @fg;
}}

element normal.urgent {{
    background-color: @bg;
    text-color:       @urgent;
}}

element normal.active {{
    background-color: @bg;
    text-color:       @neon-cyan;
}}

element selected.normal {{
    background-color: @bg-selected;
    text-color:       @neon-pink;
}}

element selected.urgent {{
    background-color: @bg-selected;
    text-color:       @urgent;
}}

element selected.active {{
    background-color: @bg-selected;
    text-color:       @neon-cyan;
}}

element alternate.normal {{
    background-color: @bg;
    text-color:       @fg;
}}

element alternate.urgent {{
    background-color: @bg;
    text-color:       @urgent;
}}

element alternate.active {{
    background-color: @bg;
    text-color:       @neon-cyan;
}}

element-icon {{
    size: 24px;
}}

element-text {{
    text-color: inherit;
    vertical-align: 0.5;
}}

element-text selected.normal {{
    background-color: @bg-selected;
}}

element-icon selected.normal {{
    background-color: @bg-selected;
}}
"""
    _write_file(ROFI_THEME_FILE, content)

def _write_dunst_theme(t):
    vars = _theme_vars(t)
    content = f"""[global]
frame_color = \"{vars['cyan']}\"
separator_color = auto

[urgency_low]
foreground = \"{vars['fg']}\"
background = \"{vars['bg']}\"

[urgency_normal]
foreground = \"{vars['fg']}\"
background = \"{vars['bg']}\"

[urgency_critical]
foreground = \"{vars['fg']}\"
background = \"{vars['bg']}\"
"""
    _write_file(os.path.expanduser("~/.config/dunst/theme.conf"), content)

def _write_eww_theme(t):
    v = _theme_vars(t)
    content = """/* Auto-generated by qtile colorscheme */
$bg: {bg};
$bg_alt: {bg_alt};
$bg_panel: {bg_panel};
$fg: {fg};
$fg_soft: {fg_soft};
$fg_softer: {fg_softer};
$fg_softest: {fg_softest};
$muted: {muted};
$muted2: {muted2};
$cyan: {cyan};
$cyan_dim: {cyan_dim};
$green: {green};
$pink: {pink};
$pink_dim: {pink_dim};
$magenta: {magenta};
$yellow: {yellow};
$blue: {blue};
$red: {red};
$red_dim: {red_dim};
""".format(**v)
    _write_file(os.path.expanduser("~/.config/eww/theme.scss"), content)

def apply_external_themes(theme_name):
    theme_name = normalize_theme_name(theme_name)
    t = COLORSCHEMES[theme_name]
    _write_rofi_theme(t)
    _write_dunst_theme(t)
    _write_eww_theme(t)
    try:
        subprocess.run(["dunstctl", "reload"], check=False)
    except FileNotFoundError:
        pass
    try:
        subprocess.run(["eww", "reload"], check=False)
    except FileNotFoundError:
        pass

def run_once(cmd):
    """Spawn command without invoking a shell."""
    if isinstance(cmd, list):
        subprocess.Popen(cmd)
    else:
        subprocess.Popen(cmd.split())

def get_weather_safe():
    """Non-blocking weather fetch with timeout and error handling."""
    try:
        result = subprocess.run(
            ['getweather'],
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.stdout.strip() if result.returncode == 0 else "N/A"
    except (subprocess.TimeoutExpired, FileNotFoundError, Exception):
        return "N/A"

@lazy.function
def eww_open(qtile, anchor, pos, widget_name):
    """Open eww widget on the currently focused screen."""
    screen_idx = qtile.current_screen.index
    qtile.spawn(
        f'eww open --toggle --anchor "{anchor}" --pos {pos} --screen {screen_idx} {widget_name}'
    )

@lazy.function
def eww_click(qtile, anchor, pos, widget_name):
    """Mouse callback: open eww widget on the currently focused screen."""
    screen_idx = qtile.current_screen.index
    qtile.spawn(
        f'eww open --toggle --anchor "{anchor}" --pos {pos} '
        f'--screen {screen_idx} {widget_name}'
    )

@lazy.function
def choose_colorscheme(qtile):
    current = load_theme_name()
    options = []
    for name in COLORSCHEMES.keys():
        label = f"{name} (current)" if name == current else name
        options.append(label)
    menu = "\n".join(options)
    try:
        result = subprocess.run(
            ["rofi", "-dmenu", "-i", "-p", "Colorscheme", "-theme", ROFI_THEME_FILE],
            input=menu,
            text=True,
            capture_output=True,
        )
    except FileNotFoundError:
        return
    if result.returncode != 0:
        return
    choice = result.stdout.strip()
    if not choice:
        return
    selected = normalize_theme_name(choice.replace(" (current)", ""))
    if selected not in COLORSCHEMES:
        return
    if selected == current:
        return
    try:
        _persist_theme_name(selected)
        apply_external_themes(selected)
    except Exception:
        return
    qtile.reload_config()

@hook.subscribe.startup
def apply_themes_on_start():
    _persist_theme_name(THEME_NAME)
    apply_external_themes(THEME_NAME)

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~")

    subprocess.Popen(
        ["xrandr", "--output","HDMI-A-0","--mode","1920x1080","--pos","1920x0",
         "--output","DisplayPort-0","--mode","1920x1080","--pos","0x0"],
    )

    commands = [
        ["greenclip", "daemon"],
        ["dunst", "-config", f"{home}/.config/dunst/dunstrc"],
        ["picom", "--config", f"{home}/.config/picom/picom.conf"],
        ["redshift", "-O", "4200"],
        [f"{home}/.local/bin/getforecast"],
        [f"{home}/.local/bin/lock.sh"],
        [f"{home}/.config/eww/scripts/getforecast"],
        [f"{home}/.config/dunst/scripts/nowplaying_notify.sh"],
        [f"{home}/.local/bin/welcome-notify.sh"],
        ["setxkbmap", "-layout", "us", "-variant", "altgr-intl"],
        ["xset", "r", "rate", "200", "35"],
    ]

    for cmd in commands:
        run_once(cmd)

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows

    Key([mod], "m", eww_open("top left", "10x35", "sidemenu"), desc="Menu Eww Profile Widget"),
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "tab", lazy.next_screen()),
    Key([mod], "space", lazy.window.toggle_floating(), desc="Toggle floating"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "n", eww_open("top center", "0x35", "notifications"), desc="Menu Eww Notifications Widget"),
    Key([mod, "shift"], "e", lazy.window.to_group()),
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    #Key([mod, "shift"], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "v", lazy.spawn("clipboard-rofi.sh"), desc="Clipboard menu"),
    Key([mod], "q", eww_open("center", "0x0", "powermenu"), desc="Eww Power menu"),
    Key([mod], "x", lazy.spawn("lock.sh"), desc="Lock screen"),
    Key([mod], "n", lazy.spawn("list_notes"), desc="List notes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "p", lazy.spawn("dm-run"), desc="Launch dmenu"),
    # Toggle between different layouts as defined below
    Key([mod], "t", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "c", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn('rofi -show drun -modi run,drun,window'), desc="Spawn a command using a prompt widget"),
    Key([], "Print", lazy.spawn("flameshot gui"), desc="Take screenshot"),
    # Volume controls
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play or Pause media"),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Play Next"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Play Previous"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), desc="Raise volume"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), desc="Lower volume"),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), desc="Mute/unmute"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "12345678"]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )
swallow_matches = [
    Match(wm_class="feh"),
    Match(wm_class="imv"),
    Match(wm_class="sxiv"),
    Match(wm_class="nsxiv"),

    Match(wm_class="mpv"),
    Match(wm_class="vlc"),

    Match(wm_class="zathura"),
    Match(wm_class="evince"),
    Match(wm_class="okular"),

    Match(wm_class="libreoffice"),
    Match(wm_class="libreoffice-calc"),
    Match(wm_class="soffice"),

]
layouts = [
    layout.MonadTall(
        border_focus=theme["border_focus"],
        border_normal=theme["border_normal"],
        border_width=3,
        margin=10,
        single_margin=10,
        swallow_rules=swallow_matches,
            ),
    layout.Columns(
        border_focus=theme["border_focus"],
        border_normal=theme["border_normal"],
        border_focus_stack=[theme["neon_pink"], theme["border_stack"]],
        border_normal_stack=[theme["dark_bg"], theme["border_normal"]],
        border_width=3,
        margin=10,
        margin_on_single=10,
        swallow_rules=swallow_matches
    ),
    layout.Max(),
    layout.Tile(
        border_focus=theme["border_focus"],
        border_normal=theme["border_normal"],
        border_width=3,
        margin=10,
        swallow_rules=swallow_matches
    ),
]
dgroups_app_rules = [
    Rule(Match(wm_class="zathura")),
    Rule(Match(wm_class="evince")),
    Rule(Match(wm_class="okular")),

    Rule(Match(wm_class="libreoffice")),
    Rule(Match(wm_class="libreoffice-calc")),
    Rule(Match(wm_class="soffice")),

    Rule(Match(wm_class="feh")),
    Rule(Match(wm_class="qView")),
    Rule(Match(wm_class="imv")),
    Rule(Match(wm_class="sxiv")),
    Rule(Match(wm_class="nsxiv")),

    Rule(Match(wm_class="mpv")),
    Rule(Match(wm_class="vlc")),
]

FULLSCREEN_MATCHES = [
    Match(wm_class="feh"),
    Match(wm_class="imv"),
    Match(wm_class="sxiv"),
    Match(wm_class="nsxiv"),
    Match(wm_class="qView"),

    Match(wm_class="mpv"),
    Match(wm_class="vlc"),

    Match(wm_class="zathura"),
    Match(wm_class="evince"),
    Match(wm_class="okular"),

    Match(wm_class="libreoffice"),
    Match(wm_class="libreoffice-calc"),
    Match(wm_class="soffice"),
]
@hook.subscribe.client_new
def maximize_qview(window):
    wm_class = window.get_wm_class()
    if wm_class and any(x in str(wm_class).lower() for x in ['qview']):
        window.toggle_maximize()


@hook.subscribe.client_managed
def force_fullscreen(window):
    for m in FULLSCREEN_MATCHES:
        if m.compare(window):
            window.toggle_maximize()
            break



widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=13,
    padding=3,
)
extension_defaults = widget_defaults.copy()

BAR_BG = theme["bar_bg"]
SEG_A = theme["seg_purple"]
SEG_B = theme["seg_blue"]

def powerline(from_color, to_color):
    """Powerline right-arrow separator."""
    return widget.TextBox(
        text='\ue0b0',
        fontsize=28,
        padding=0,
        foreground=from_color,
        background=to_color,
    )

def make_widgets(systray=False):
    widgets = [
        widget.Spacer(length=6, background=BAR_BG),
        # ── Logo ──
        #widget.TextBox(
        #    text='  ',
        #    fontsize=20,
        #    foreground=theme["neon_cyan"],
        #    background=BAR_BG,
        #    padding=6,
        #),
        # ── Groups ──
        widget.GroupBox(
            highlight_method='line',
            rounded=False,
            highlight_color=[BAR_BG, BAR_BG],
            this_current_screen_border=theme["neon_cyan"],
            this_screen_border=theme["neon_cyan"],
            other_current_screen_border=theme["neon_magenta"],
            other_screen_border=theme["neon_pink_dim"],
            active=theme["neon_cyan"],
            inactive='#555577',
            urgent_border=theme["neon_yellow"],
            fontsize=13,
            padding_x=1,
            padding_y=1,
            margin_x=3,
            margin_y=3,
            disable_drag=True,
            background=BAR_BG,
        ),
        powerline(BAR_BG, SEG_A),
        # ── Layout ──
        widget.TextBox(
            text=' ',
            foreground=theme["neon_magenta"],
            background=SEG_A,
            fontsize=15,
            padding=2,
        ),
        widget.CurrentLayout(
            foreground=theme["neon_magenta"],
            background=SEG_A,
            padding=2,
        ),
        powerline(SEG_A, BAR_BG),
        # ── Prompt + Window Name ──
        widget.Prompt(background=BAR_BG),
        widget.WindowName(
            foreground=theme["neon_cyan"],
            background=BAR_BG,
            max_chars=50,
            format='{name}',
            empty_group_string='desktop',
        ),
        widget.Chord(
            chords_colors={
                "launch": (theme["neon_pink"], "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
            background=BAR_BG,
        ),
        # ── Right side: Weather ──
        powerline(BAR_BG, SEG_B),
        widget.TextBox(
            text='  ',
            foreground=theme["neon_yellow"],
            background=SEG_B,
            fontsize=15,
            padding=0,
        ),
        widget.GenPollText(
            func=get_weather_safe,
            update_interval=600,
            foreground=theme["neon_yellow"],
            background=SEG_B,
            padding=2,
            mouse_callbacks={
                'Button1': eww_click("top right", "0x35", "weather"),
            },
        ),
        powerline(SEG_B, SEG_A),
        # ── CPU ──
        widget.TextBox(
            text='  ',
            foreground=theme["neon_magenta"],
            background=SEG_A,
            fontsize=15,
            padding=0,
        ),
        widget.CPU(
            foreground=theme["neon_magenta"],
            background=SEG_A,
            format='{load_percent}%',
            padding=4,
            mouse_callbacks={
                'Button1': eww_click("top left", "10x35", "storagemon"),
            },
        ),
        powerline(SEG_A, SEG_B),
        # ── Memory ──
        widget.TextBox(
            text=' 󰍛 ',
            foreground=theme["neon_green"],
            background=SEG_B,
            fontsize=15,
            padding=0,
        ),
        widget.Memory(
            foreground=theme["neon_green"],
            background=SEG_B,
            fmt='{}',
            measure_mem='G',
            padding=2,
            mouse_callbacks={
                'Button1': eww_click("top left", "10x35", "storagemon"),
            },
        ),
        powerline(SEG_B, SEG_A),
        # ── Disk ──
        widget.TextBox(
            text=' 󰋊 ',
            foreground=theme["neon_pink"],
            background=SEG_A,
            fontsize=13,
            padding=0,
        ),
        widget.DF(
            foreground=theme["neon_pink"],
            background=SEG_A,
            partition='/',
            visible_on_warn=False,
            format='{uf}{m}/{s}{m}',
            padding=2,
        ),
        powerline(SEG_A, SEG_B),
        # ── Volume ──
        widget.TextBox(
            text=' 󰕾 ',
            foreground=theme["neon_cyan"],
            background=SEG_B,
            fontsize=15,
            padding=0,
        ),
        widget.Volume(
            foreground=theme["neon_cyan"],
            background=SEG_B,
            fmt='{}',
            padding=2,
        ),
        powerline(SEG_B, SEG_A),
        # ── Clock ──
        widget.TextBox(
            text='  ',
            foreground=theme["neon_magenta"],
            background=SEG_A,
            fontsize=15,
            padding=0,
        ),
        widget.Clock(
            foreground=theme["neon_magenta"],
            background=SEG_A,
            format='%b %d  %I:%M %p',
            padding=2,
            mouse_callbacks={
                'Button1': eww_click("top right", "0x35", "calendar_full"),
            },
        ),
        widget.TextBox(
            text=' Theme ',
            foreground=theme["neon_cyan"],
            background=SEG_A,
            padding=2,
            mouse_callbacks={
                'Button1': choose_colorscheme,
            },
        ),
    ]
    if systray:
        widgets.extend([
            powerline(SEG_A, BAR_BG),
            widget.Systray(background=BAR_BG, padding=4),
            widget.Spacer(length=10, background=BAR_BG),
        ])
    else:
        widgets.append(
            widget.Spacer(length=10, background=SEG_A),
        )
    return widgets

WALLPAPER = os.path.expanduser("~/Pictures/wallpapers/sunlight-landscape-forest-sky-park-snow-835255-wallhere.com.jpg")

screens = [
    Screen(
        top=bar.Bar(
            make_widgets(systray=True),
            30,
            background=BAR_BG,
            margin=[5, 10, 0, 10],
            opacity=0.92,
        ),
        wallpaper=WALLPAPER,
        wallpaper_mode="fill",
    ),
    Screen(
        top=bar.Bar(
            make_widgets(systray=False),
            30,
            background=BAR_BG,
            margin=[5, 10, 0, 10],
            opacity=0.92,
        ),
        wallpaper=WALLPAPER,
        wallpaper_mode="fill",
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False


floating_layout = layout.Floating(
    border_focus=theme["neon_cyan"],
    border_normal=theme["border_normal"],
    border_width=2,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="Picture-in-Picture"),
        # GPG pinentry
        Match(wm_class="pinentry"),
        Match(wm_class="pinentry-gtk"),
        Match(wm_class="Pinentry-gtk"),
        Match(wm_class="pinentry-gtk-2"),
        Match(wm_class="pinentry-qt"),
        Match(wm_class="pinentry-gnome3"),
        Match(wm_class="Pinentry"),
        # SSH askpass
        Match(wm_class="ssh-askpass"),
        Match(wm_class="gcr-prompter"),
        Match(wm_class="ksshaskpass"),
        # Dialogs and confirmations
        Match(wm_class="confirmreset"),
        Match(wm_class="dialog"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(title="branchdialog"),
        Match(title="confirm"),
        Match(wm_type="dialog"),
    ]
)

PIP_WIDTH = 420
PIP_HEIGHT = 230
PIP_MARGIN = 20  # distância da borda da tela

pip_window = None

@hook.subscribe.client_managed
def password_dialog_float(window):
    wm_class = window.get_wm_class() or []
    if isinstance(wm_class, str):
        wm_class = [wm_class]
    wm_class_lower = " ".join(wm_class).lower()

    if any(kw in wm_class_lower for kw in ("pinentry", "askpass", "gcr-prompter")):
        window.floating = True
        window.center()


@hook.subscribe.client_managed
def detect_pip(window):
    global pip_window

    if window.name and "Picture-in-Picture" in window.name:
        pip_window = window
        window.floating = True

        screen = window.qtile.current_screen
        x = screen.x + screen.width - PIP_WIDTH - PIP_MARGIN
        y = screen.y + screen.height - PIP_HEIGHT - PIP_MARGIN

        window.place(
            x=x,
            y=y,
            width=PIP_WIDTH,
            height=PIP_HEIGHT,
            borderwidth=0,
        )

@hook.subscribe.client_killed
def cleanup_pip(window):
    global pip_window
    if pip_window and window == pip_window:
        pip_window = None


@hook.subscribe.setgroup
def keep_pip_on_screen():
    global pip_window
    if pip_window is None:
        return
    try:
        # Validate window still exists and has a group
        if hasattr(pip_window, 'group') and pip_window.group:
            pip_window.toscreen(0)
    except Exception:
        # Window no longer valid, clear the reference
        pip_window = None


auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
#wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
#wl_xcursor_theme = "Bibata-Modern-Ice"
#wl_xcursor_size = 24
#wl_input_rules = {
#    "type:keyboard": inputs.InputConfig(
#        kb_layout="us",
#        kb_variant="altgr-intl",
#        kb_repeat_rate=35,
#        kb_repeat_delay=200
#    ),
#}
idle_inhibitors = []  # type: list

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
