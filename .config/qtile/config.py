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
terminal = guess_terminal('alacritty')

# Cyberpunk color scheme - neon green primary
cyberpunk = {
    "neon_green": "#00ff41",
    "neon_cyan": "#00f0ff",
    "neon_magenta": "#ff00ff",
    "neon_pink": "#ff2079",
    "neon_pink_dim": "#cc77aa",
    "neon_yellow": "#f0e020",
    "dark_bg": "#0a0a0a",
    "border_normal": "#1a1a2e",
    "border_unfocused": "#317aaa",
    "border_focus": "#ff2079",
    "border_focus_dim": "#cc77aa",
    "border_stack": "#e75480",
    # Bar segment backgrounds
    "bar_bg": "#0a0a14",
    "seg_purple": "#1a0a2e",
    "seg_blue": "#0a1a2e",
}

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

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~")

    subprocess.run(
        ["xrandr", "--output","HDMI-A-0","--mode","1920x1080","--pos","0x0",
         "--output","DisplayPort-1","--mode","1920x1080","--pos","1920x0"],
    )

    commands = [
        ["greenclip", "daemon"],
        ["dunst", "-config", f"{home}/.config/dunst/dunstrc"],
        ["picom", "--config", f"{home}/.config/picom/picom.conf"],
        ["redshift", "-O", "4200"],
        ["syncthing", "--no-browser"],
        ["setxkbmap", "-layout", "us", "-variant", "altgr-intl"],
        ["xset", "r", "rate", "200", "35"],
        [f"{home}/.local/bin/getforecast"],
        [f"{home}/.local/bin/lock.sh"],
        [f"{home}/.config/eww/scripts/getforecast"],
        [f"{home}/.config/dunst/scripts/nowplaying_notify.sh"],
        [f"{home}/.local/bin/welcome-notify.sh"],
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
    Key([mod], "r", lazy.spawn('rofi -show drun '), desc="Spawn a command using a prompt widget"),
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
        border_focus=cyberpunk["border_focus"],
        border_normal=cyberpunk["border_normal"],
        border_width=3,
        margin=8,
        single_margin=0,
        swallow_rules=swallow_matches,
            ),
    layout.Columns(
        border_focus=cyberpunk["border_focus"],
        border_normal=cyberpunk["border_normal"],
        border_focus_stack=[cyberpunk["neon_pink"], cyberpunk["border_stack"]],
        border_normal_stack=[cyberpunk["dark_bg"], cyberpunk["border_normal"]],
        border_width=3,
        margin=8,
        margin_on_single=0,
        swallow_rules=swallow_matches
    ),
    layout.Max(),
    layout.Tile(
        border_focus=cyberpunk["border_focus"],
        border_normal=cyberpunk["border_normal"],
        border_width=3,
        margin=8,
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

BAR_BG = cyberpunk["bar_bg"]
SEG_A = cyberpunk["seg_purple"]
SEG_B = cyberpunk["seg_blue"]

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
        # ── Logo ──
        #widget.TextBox(
        #    text='  ',
        #    fontsize=20,
        #    foreground=cyberpunk["neon_cyan"],
        #    background=BAR_BG,
        #    padding=6,
        #),
        # ── Groups ──
        widget.GroupBox(
            highlight_method='line',
            rounded=False,
            highlight_color=[BAR_BG, BAR_BG],
            this_current_screen_border=cyberpunk["neon_cyan"],
            this_screen_border=cyberpunk["neon_cyan"],
            other_current_screen_border=cyberpunk["neon_magenta"],
            other_screen_border=cyberpunk["neon_pink_dim"],
            active=cyberpunk["neon_cyan"],
            inactive='#555577',
            urgent_border=cyberpunk["neon_yellow"],
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
            foreground=cyberpunk["neon_magenta"],
            background=SEG_A,
            fontsize=15,
            padding=2,
        ),
        widget.CurrentLayout(
            foreground=cyberpunk["neon_magenta"],
            background=SEG_A,
            padding=2,
        ),
        powerline(SEG_A, BAR_BG),
        # ── Prompt + Window Name ──
        widget.Prompt(background=BAR_BG),
        widget.WindowName(
            foreground=cyberpunk["neon_cyan"],
            background=BAR_BG,
            max_chars=50,
            format='{name}',
            empty_group_string='desktop',
        ),
        widget.Chord(
            chords_colors={
                "launch": (cyberpunk["neon_pink"], "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
            background=BAR_BG,
        ),
        # ── Right side: Weather ──
        powerline(BAR_BG, SEG_B),
        widget.TextBox(
            text='  ',
            foreground=cyberpunk["neon_yellow"],
            background=SEG_B,
            fontsize=15,
            padding=0,
        ),
        widget.GenPollText(
            func=get_weather_safe,
            update_interval=600,
            foreground=cyberpunk["neon_yellow"],
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
            foreground=cyberpunk["neon_magenta"],
            background=SEG_A,
            fontsize=15,
            padding=0,
        ),
        widget.CPU(
            foreground=cyberpunk["neon_magenta"],
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
            foreground=cyberpunk["neon_green"],
            background=SEG_B,
            fontsize=15,
            padding=0,
        ),
        widget.Memory(
            foreground=cyberpunk["neon_green"],
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
            foreground=cyberpunk["neon_pink"],
            background=SEG_A,
            fontsize=13,
            padding=0,
        ),
        widget.DF(
            foreground=cyberpunk["neon_pink"],
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
            foreground=cyberpunk["neon_cyan"],
            background=SEG_B,
            fontsize=15,
            padding=0,
        ),
        widget.Volume(
            foreground=cyberpunk["neon_cyan"],
            background=SEG_B,
            fmt='{}',
            padding=2,
        ),
        powerline(SEG_B, SEG_A),
        # ── Clock ──
        widget.TextBox(
            text='  ',
            foreground=cyberpunk["neon_magenta"],
            background=SEG_A,
            fontsize=15,
            padding=0,
        ),
        widget.Clock(
            foreground=cyberpunk["neon_magenta"],
            background=SEG_A,
            format='%b %d  %I:%M %p',
            padding=2,
            mouse_callbacks={
                'Button1': eww_click("top right", "0x35", "calendar_full"),
            },
        ),
    ]
    if systray:
        widgets.extend([
            powerline(SEG_A, BAR_BG),
            widget.Systray(background=BAR_BG, padding=4),
            widget.Spacer(length=8, background=BAR_BG),
        ])
    else:
        widgets.append(
            widget.Spacer(length=8, background=SEG_A),
        )
    return widgets

WALLPAPER = os.path.expanduser("~/Pictures/wallpapers/woman-glasses-neuro.jpg")

screens = [
    Screen(
        top=bar.Bar(
            make_widgets(systray=True),
            25,
            background=BAR_BG,
            margin=0,
            opacity=0.92,
        ),
        wallpaper=WALLPAPER,
        wallpaper_mode="fill",
    ),
    Screen(
        top=bar.Bar(
            make_widgets(systray=False),
            25,
            background=BAR_BG,
            margin=0,
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
    border_focus=cyberpunk["neon_cyan"],
    border_normal=cyberpunk["border_normal"],
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
    wm_class = window.wm_class or ""
    if isinstance(wm_class, list):
        wm_class = " ".join(wm_class)
    wm_class_lower = wm_class.lower()

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
wl_xcursor_theme = None
wl_xcursor_size = 24
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

