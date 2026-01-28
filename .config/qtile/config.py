import os
import subprocess
from sys import byteorder

from libqtile import bar, hook, layout, qtile, widget
from libqtile.backend.wayland import inputs
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = guess_terminal('ghostty')

# Cyberpunk color scheme - neon green primary
cyberpunk = {
    "neon_green": "#00ff41",
    "neon_cyan": "#00ffff",
    "neon_magenta": "#ff00ff",
    "neon_pink": "#ff0080",
    "neon_pink_dim": "#cc77aa",
    "dark_bg": "#0a0a0a",
    "border_normal": "#1a1a2e",
    "border_unfocused": "#317aaa",
    "border_focus": "#00ffaa",
    "border_focus_dim": "#3f7c68",
    "border_stack": "#e75480",
}


@hook.subscribe.startup_once
def autostart():
    subprocess.Popen(["kanshi"])
    os.system("dunst -config ~/.config/dunst/dunstrc &")
    os.system("waypaper --restore &")
    os.system("wlsunset -t 4300 &")
    os.system("syncthing --no-browser &")
    os.system("swayidle -w timeout 900 'swaylock-screen' &")
    os.system("~/.config/dunst/scripts/nowplaying_notify.sh &")
    os.system("~/.local/bin/welcome-notify.sh &")




keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "tab", lazy.next_screen()),
    Key([mod], "space", lazy.window.toggle_floating(), desc="Toggle floating"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
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
    Key([mod, "shift"], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "v", lazy.spawn("clipboard-dmenu.sh"), desc="Clipboard menu"),
    Key([mod], "q", lazy.spawn("powermenu-dmenu.sh"), desc="Power menu"),
    Key([mod], "x", lazy.spawn("swaylock-screen"), desc="Lock screen"),
    Key([mod], "n", lazy.spawn("list_notes_dmenu"), desc="List notes"),
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
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([], "Print", lazy.spawn("screenshot"), desc="Take screenshot"),
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


groups = [Group(i) for i in "123456789"]

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

layouts = [
    layout.MonadTall(
        border_focus=cyberpunk["border_focus"],
        border_normal=cyberpunk["border_normal"],
        border_width=3,
        margin=8,
        single_margin=0,
    ),
    layout.Columns(
        border_focus=cyberpunk["border_focus"],
        border_normal=cyberpunk["border_normal"],
        border_focus_stack=[cyberpunk["neon_green"], cyberpunk["border_stack"]],
        border_normal_stack=[cyberpunk["dark_bg"], cyberpunk["border_normal"]],
        border_width=3,
        margin=8,
        margin_on_single=0,
    ),
    layout.Max(),
    layout.Tile(
        border_focus=cyberpunk["border_focus"],
        border_normal=cyberpunk["border_normal"],
        border_width=3,
        margin=8,
    ),
]

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

def separator():
    return widget.TextBox(text='|', foreground='#555', padding=8)

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(
                    highlight_method='line',
                    this_current_screen_border=cyberpunk["border_focus"],
                    this_screen_border=cyberpunk["border_focus_dim"],
                    other_current_screen_border=cyberpunk["border_focus"],
                    other_screen_border=cyberpunk['border_focus_dim'],
                    active=cyberpunk['neon_cyan'],
                    inactive=cyberpunk['border_unfocused']
                ),
                separator(),
                widget.CurrentLayout(),
                separator(),
                widget.Prompt(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.GenPollText(
                    func=lambda: subprocess.check_output('getweather').decode().strip(),
                    update_interval=600,
                    foreground='#ccc',
                ),
                separator(),
                widget.CPU(
                    foreground='#ccc',
                    format='cpu: {load_percent}%',
                ),
                separator(),
                widget.Memory(
                    foreground='#ccc',
                    fmt='mem:{}',
                    measure_mem='G',
                ),
                separator(),
                widget.DF(
                    foreground='#ccc',
                    partition='/',
                    visible_on_warn=False,
                    format='dsk: {uf}{m}/{s}{m} ({r:.0f}%)',
                ),
                separator(),
                widget.Volume(foreground='#ccc',fmt='Volume: {}'),
                separator(),
                widget.Clock(
                    foreground='#ccc',
                    format="%Y, %B %d %a %I:%M %p",
                    mouse_callbacks={'Button1': lambda: qtile.spawn('sh -c "notify-send \"$(cal -3)\""')},
                ),
                widget.Systray(),
            ],
            24,
            background=cyberpunk['border_normal'],
        ),
        background=cyberpunk['border_normal'],
    ),
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(
                    highlight_method='line',
                    this_current_screen_border=cyberpunk["border_focus"],
                    this_screen_border=cyberpunk["border_focus_dim"],
                    other_current_screen_border=cyberpunk["border_focus"],
                    other_screen_border=cyberpunk['border_focus_dim'],               
                    active=cyberpunk['neon_cyan'],
                    inactive=cyberpunk['border_unfocused']
                ),
                separator(),
                widget.CurrentLayout(),
                separator(),
                widget.Prompt(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.GenPollText(
                    func=lambda: subprocess.check_output('getweather').decode().strip(),
                    update_interval=600,
                    foreground='#ccc',
                ),
                separator(),
                widget.CPU(
                    foreground='#ccc',
                    format='cpu: {load_percent}%',
                ),
                separator(),
                widget.Memory(
                    foreground='#ccc',
                    fmt='mem:{}',
                    measure_mem='G',
                ),
                separator(),
                widget.DF(
                    foreground='#ccc',
                    partition='/',
                    visible_on_warn=False,
                    format='dsk: {uf}{m}/{s}{m} ({r:.0f}%)',
                ),
                separator(),
                widget.Volume(foreground='#ccc',fmt='Volume: {}'),
                separator(),
                widget.Clock(
                    foreground='#ccc',
                    format="%Y, %B %d %a %I:%M %p",
                    mouse_callbacks={'Button1': lambda: qtile.spawn('sh -c "notify-send \"$(cal -3)\""')},
                ),
            ],
            24,
            background=cyberpunk['border_normal'],
        ),
        background=cyberpunk['border_normal'],
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=cyberpunk["neon_cyan"],
    border_normal=cyberpunk["border_normal"],
    border_width=2,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="dialog"),  # gitk
        Match(wm_class="utility"),  # gitk
        Match(title="Picture-in-Picture"),
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(wm_class="pinentry"),  # GPG key password entry
    ]
)

PIP_WIDTH = 420
PIP_HEIGHT = 230
PIP_MARGIN = 20  # distância da borda da tela

pip_window = None

@hook.subscribe.client_managed
def gpg_pinentry_float(window):
    # app_id mais comuns do pinentry
    if window.wm_class in {
        "pinentry-gtk-2",
        "pinentry-qt",
    }:
        window.floating = True
        window.center()
        return

    # fallback por título (caso distro/custom)
    if window.name and "pinentry" in window.name.lower():
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


@hook.subscribe.setgroup
def keep_pip_on_screen():
    if pip_window and pip_window.group:
        pip_window.toscreen(0)


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
wl_input_rules = {
    "type:keyboard": inputs.InputConfig(
        kb_layout="us",
        kb_variant="altgr-intl",
        kb_repeat_rate=35,
        kb_repeat_delay=200
    ),
}
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
