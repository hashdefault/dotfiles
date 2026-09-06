import XMonad
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (avoidStruts, docks, ToggleStruts (..))
import XMonad.Hooks.DynamicLog (xmonadPropLog')
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.SimpleFloat (simpleFloat)
import XMonad.Layout.Renamed (renamed, Rename (Replace))
import XMonad.Hooks.StatusBar.PP
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Util.EZConfig (additionalKeys)
import Graphics.X11.ExtraTypes.XF86
  ( xF86XK_AudioRaiseVolume
  , xF86XK_AudioLowerVolume
  , xF86XK_AudioMute
  )
import System.Exit (exitSuccess)
import System.Environment (setEnv, lookupEnv)
import Control.Exception (catch, SomeException)
import Data.List (elemIndex, stripPrefix)
import Data.Maybe (fromMaybe, listToMaybe)
import qualified XMonad.StackSet as W
import XMonad.Actions.Warp (warpToScreen)

myTerminal :: String
myTerminal = "alacritty"

myModMask :: KeyMask
myModMask = mod4Mask

myBorderWidth :: Dimension
myBorderWidth = 2

myLauncher :: String
myLauncher = "$HOME/.local/bin/rofi-launcher"

-- Colors that theme-chooser.sh rewrites on every theme switch (see
-- ~/.config/xmonad/scripts/theme-chooser.sh and ~/.config/xmonad/theme.conf).
-- Kept as a runtime-read record rather than top-level constants so that
-- `xmonad --restart` alone (no recompile) picks up a new theme -- the
-- theme-chooser calls exactly that after regenerating theme.conf.
data Theme = Theme
  { themeNormalBorder  :: String
  , themeFocusedBorder :: String
  , themeWsCurrent     :: String
  , themeWsVisible     :: String
  , themeWsHidden      :: String
  , themeWsHiddenNoWin :: String
  , themeWsUrgent      :: String
  , themeLayout        :: String
  , themeUnderline     :: String
  }

-- Eldritch, matching theme.conf's default -- used if the file is missing or
-- a key is absent, so a bad/partial theme.conf never breaks startup.
defaultTheme :: Theme
defaultTheme = Theme
  { themeNormalBorder  = "#3b3b4f"
  , themeFocusedBorder = "#00ff99"
  , themeWsCurrent     = "#00ff99"
  , themeWsVisible     = "#00ff99"
  , themeWsHidden      = "#a48cf2"
  , themeWsHiddenNoWin = "#6c77ab"
  , themeWsUrgent      = "#f0313e"
  , themeLayout        = "#a48cf2"
  , themeUnderline     = "#f265b5"
  }

-- Reads ~/.config/xmonad/theme.conf (simple KEY=VALUE lines, written by
-- theme-chooser.sh), falling back to defaultTheme per-key on any read
-- error or missing key.
readTheme :: IO Theme
readTheme = do
  mhome <- lookupEnv "HOME"
  case mhome of
    Nothing -> return defaultTheme
    Just home -> do
      contents <- readFile (home ++ "/.config/xmonad/theme.conf") `catch` onErr
      let valueFor key def' = fromMaybe def' $ listToMaybe
            [ trim rest
            | l <- lines contents
            , Just rest <- [stripPrefix (key ++ "=") (trim l)]
            ]
      return Theme
        { themeNormalBorder  = valueFor "NORMAL_BORDER"  (themeNormalBorder defaultTheme)
        , themeFocusedBorder = valueFor "FOCUSED_BORDER" (themeFocusedBorder defaultTheme)
        , themeWsCurrent     = valueFor "WS_CURRENT"     (themeWsCurrent defaultTheme)
        , themeWsVisible     = valueFor "WS_VISIBLE"     (themeWsVisible defaultTheme)
        , themeWsHidden      = valueFor "WS_HIDDEN"      (themeWsHidden defaultTheme)
        , themeWsHiddenNoWin = valueFor "WS_HIDDEN_NOWIN" (themeWsHiddenNoWin defaultTheme)
        , themeWsUrgent      = valueFor "WS_URGENT"      (themeWsUrgent defaultTheme)
        , themeLayout        = valueFor "LAYOUT"         (themeLayout defaultTheme)
        , themeUnderline     = valueFor "UNDERLINE"      (themeUnderline defaultTheme)
        }
  where
    onErr :: SomeException -> IO String
    onErr _ = return ""
    trim :: String -> String
    trim = f . f
      where f = reverse . dropWhile (`elem` " \t")

myWorkspaces :: [String]
myWorkspaces = ["dev", "web", "search", "chat", "music", "docs", "misc"]

-- Cycled with mod+space (XMonad's default NextLayout binding -- not
-- overridden anywhere in myKeys, so it already works as-is). Tile and float
-- are the two used day-to-day, so they're first: one mod+space press from
-- the default startup layout (tiled) reaches float; Mirror/Full are the
-- rarely-needed extra two, kept for symmetry with the old 3-layout set.
-- Each is wrapped in `renamed` so ppLayout (myXmobarPP below) prints a short
-- clean name in the bar instead of the raw modifier-stack description
-- (e.g. "Spacing 5 Tall" or "SimpleFloat").
myLayout = avoidStruts
  ( renamed [Replace "Tile"] (spacing 5 tiled)
      ||| renamed [Replace "Float"] simpleFloat
      ||| renamed [Replace "Mirror"] (spacing 5 (Mirror tiled))
      ||| renamed [Replace "Full"] Full
  )
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1 / 2
    delta   = 3 / 100

-- Mirrors whatever cursor theme lxappearance most recently wrote to
-- ~/.Xresources into XCURSOR_THEME/XCURSOR_SIZE, so clients that only ever
-- check the environment (rofi, alacritty, trayer, ...) match lxappearance's
-- current choice. A name hardcoded here instead of read from Xresources
-- would silently go stale and override lxappearance on every login --
-- exactly the "have to reopen lxappearance every time" bug this replaces.
applyCursorEnvFromXresources :: X ()
applyCursorEnvFromXresources = io $ do
  mhome <- lookupEnv "HOME"
  case mhome of
    Nothing -> return ()
    Just home -> do
      contents <- readFile (home ++ "/.Xresources") `catch` onErr
      let valueFor key = listToMaybe
            [ trim rest
            | l <- lines contents
            , Just rest <- [stripPrefix (key ++ ":") (trim l)]
            ]
      maybe (return ()) (setEnv "XCURSOR_THEME") (valueFor "Xcursor.theme")
      maybe (return ()) (setEnv "XCURSOR_SIZE") (valueFor "Xcursor.size")
  where
    onErr :: SomeException -> IO String
    onErr _ = return ""
    trim :: String -> String
    trim = f . f
      where f = reverse . dropWhile (`elem` " \t")

myStartupHook :: X ()
myStartupHook = do
  applyCursorEnvFromXresources
  -- Picks which connected output is primary (DisplayPort > HDMI > VGA,
  -- verified per-output via EDID rather than trusting the xrandr port name
  -- -- an active DP/HDMI-to-VGA adapter still negotiates a real digital
  -- link with the GPU, so it reports as "DP-1"/digital same as a genuine DP
  -- monitor; the script instead also checks the EDID's Display Product Name
  -- text for "VGA", which is how the work rig's adapter actually gives
  -- itself away -- needs v4l-utils installed for that check, degrades to
  -- name-based guessing without it) and puts the winner at x=1920
  -- (physically on the right); the other connected output, if any, goes to
  -- x=0 (left). See the script for the full story -- this hardware varies
  -- across the two rigs this config runs on (home: real DP-1 right, HDMI-1
  -- left; work: HDMI right, VGA-riding-a-DP-named-port left), but the
  -- priority-based primary selection lands on the correct physical side
  -- either way. Downstream bits (trayer's --monitor primary,
  -- myScreenXOffset below) depend on primary always ending up at x=1920.
  spawnOnce "$HOME/.config/xmonad/scripts/setup-monitors.sh"
  spawnOnce "xrdb -merge $HOME/.Xresources"
  spawnOnce "xsetroot -cursor_name left_ptr"
  spawnOnce "sh -c 'command -v feh >/dev/null 2>&1 && feh --bg-fill \"$(find \"$HOME\"/Pictures/wallpapers -type f \\( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" \\) | shuf -n1)\"'"
  spawnOnce "picom --config $HOME/.config/picom/picom.conf -b"
  -- Fixed pixel width (not --widthtype request) so trayer's window can
  -- never grow past what xmobar has reserved for it (myTrayerWidth below) --
  -- avoids needing a live watcher to keep the two in sync. Trade-off: icons
  -- beyond what fits in that width get silently clipped instead of the bar
  -- shrinking to make room.
  spawnOnce ("trayer --edge top --align right --widthtype pixel --width " ++ show myTrayerWidth ++ " --expand false --height 24 --transparent true --alpha 0 --tint 0x121222 --distance 0 --SetDockType true --SetPartialStrut true --monitor primary")
  spawnOnce "blueman-applet"
  spawnOnce "sh -c 'command -v nm-applet >/dev/null 2>&1 && nm-applet'"
  -- Keeps /tmp/forecast_*day_* fed for the eww weather widget's 5-day
  -- forecast row; loops itself every 2h (see the script), flock-guarded
  -- against duplicate loops across restarts.
  spawnOnce "$HOME/.config/xmonad/scripts/forecast-updater.sh"
  -- Keep monitors on while idle, including while the screen is locked.
  spawn "xset s off -dpms"
  -- Auto-locks after 20m idle (betterlockscreen wraps i3lock-color with the
  -- cached blurred wallpaper already generated per-output under
  -- ~/.cache/betterlockscreen). -detectsleep also locks immediately on
  -- suspend/resume. MOD+x / MOD+shift+x (myKeys) trigger the same locker
  -- on demand.
  spawnOnce "xautolock -time 20 -locker \"betterlockscreen -l\" -detectsleep"
  -- Clipboard history: watches the X11 CLIPBOARD selection (via clipnotify,
  -- event-driven, no polling) and appends changes to
  -- ~/.cache/clipboard-history/history.jsonl. MOD+v (myKeys) opens the rofi
  -- picker to browse/restore past entries.
  spawnOnce "$HOME/.local/bin/clipboard daemon"
  spawn "xset r rate 200 35"
  -- One xmobar instance per physical monitor (pinned via `-x <screen>`), spawned
  -- directly here via spawnOnce instead of through XMonad.Hooks.StatusBar's
  -- dynamicSBs: dynamicSBs's bar bookkeeping doesn't survive `xmonad --restart`
  -- cleanly on this system (every restart re-triggers xmonad's own
  -- recompile-and-replace-itself dance, which orphans whatever bar process
  -- dynamicSBs was tracking and crashes with an uncaught `waitForProcess: does
  -- not exist (No child processes)`, silently killing the bar). Plain
  -- spawnOnce doesn't have that problem, same as trayer/picom above.
  -- Trade-off: the bar no longer auto-rebuilds on monitor hotplug, only at
  -- startup; acceptable since this is a fixed two-monitor setup (the xrandr
  -- call above pins the layout on every start anyway).
  -- XMOBAR_SCREEN is inherited by the eww click actions in xmobarrc so each
  -- bar's widgets (calendar_full, weather, storagemon) open via `eww --screen`
  -- on the same physical monitor the bar (and the click) is on. eww's numeric
  -- screen index follows the same Xinerama/RandR order as xmonad's ScreenId.
  spawnOnce (xmobarCmd (S 0))
  spawnOnce (xmobarCmd (S 1))

-- EWMH desktop indices (as consumed by `wmctrl -s`) follow the same order
-- as myWorkspaces, so a tag can be turned into the index wmctrl needs.
wsIndex :: String -> Int
wsIndex ws = fromMaybe 0 (elemIndex ws myWorkspaces)

-- Makes a workspace label clickable: left-click switches to it via wmctrl,
-- since EWMH (enabled by `ewmh` in main) keeps _NET_CURRENT_DESKTOP in sync.
wsAction :: String -> String -> String
wsAction ws body =
  "<action=`wmctrl -s " ++ show (wsIndex ws) ++ "` button=1>" ++ body ++ "</action>"

myXmobarPP :: Theme -> PP
myXmobarPP theme = def
  { ppCurrent         = \ws ->
      wsAction ws
        ( "<box type=Bottom width=3 mb=1 color=" ++ themeUnderline theme ++ ">"
            ++ xmobarColor (themeWsCurrent theme) "" ws
            ++ "</box>"
        )
  , ppVisible         = \ws -> wsAction ws (xmobarColor (themeWsVisible theme) "" ws)
  , ppHidden          = \ws -> wsAction ws (xmobarColor (themeWsHidden theme) "" ws)
  , ppHiddenNoWindows = \ws -> wsAction ws (xmobarColor (themeWsHiddenNoWin theme) "" ws)
  , ppUrgent          = \ws -> wsAction ws (xmobarColor (themeWsUrgent theme) "" (wrap "!" "!" ws))
  , ppLayout          = xmobarColor (themeLayout theme) ""
  , ppSep             = " | "
  , ppWsSep           = " "
  , ppTitle           = const ""
  , ppOrder           = \(ws : l : _) -> [ws, l]
  }

-- Global X offset of each physical screen's origin. Screen 0 (xmonad's
-- ScreenId, which follows xrandr's primary-first Xinerama order) is always
-- the primary output at +1920+0 -- setup-monitors.sh guarantees that
-- regardless of which physical port (DP/HDMI/VGA) ends up primary, see
-- myStartupHook. Needed because xmobar's `OnScreen N Static {...}` shifts
-- where the bar is *drawn* but NOT the _NET_WM_STRUT_PARTIAL it publishes
-- (both instances advertised the same x=3..1916 strut), so ManageDocks only
-- ever reserved space on screen 0 and windows on screen 1 could cover the
-- bar. Using plain `Static` with the real global xpos sidesteps that: the
-- strut ends up correct on both.
myScreenXOffset :: ScreenId -> Int
myScreenXOffset (S 0) = 1920
myScreenXOffset _     = 0

-- Fixed width passed to trayer's --width (pixel widthtype, --expand false)
-- and mirrored into the bar-0 lane reservation below, so the two can never
-- disagree. ~23px/icon at height=24, so 200px comfortably fits ~8-9 icons;
-- bump this (and nothing else) if that's ever not enough.
myTrayerWidth :: Int
myTrayerWidth = 150

-- 5px breathing room between the bar's content and the tray lane.
myTrayerLaneWidth :: Int
myTrayerLaneWidth = myTrayerWidth + 5

-- Only screen 0 (DisplayPort-1) has a tray docked on it -- see
-- myStartupHook's trayer spawnOnce (--monitor primary --align right
-- --distance 0). Screen 1 always gets the full width.
myBarWidth :: ScreenId -> Int
myBarWidth (S 0) = 1920 - myTrayerLaneWidth
myBarWidth _     = 1920

-- eww's `--screen N` now enumerates monitors in the same order xmonad's
-- ScreenId does on this rig (re-confirmed empirically 2026-08-17: `eww open
-- --screen 0` lands on DisplayPort-1/right, `--screen 1` lands on
-- HDMI-A-0/left — same as xmonad's S 0/S 1, see myScreenXOffset). This used
-- to be inverted (hence this function used to swap 0/1), which was exactly
-- why clicking a bar on one monitor opened widgets on the other. XMOBAR_SCREEN
-- only feeds the `eww open --screen $XMOBAR_SCREEN` click actions in
-- xmobarrc (xmobar's own `-x` Xinerama flag below is separate and
-- unaffected); kept as a passthrough function rather than inlined so a future
-- re-inversion (monitor hotplug/reorder, eww update) only needs editing here.
ewwScreenFor :: ScreenId -> Int
ewwScreenFor (S sid) = sid

-- Builds the shell command that launches one screen's xmobar, mirroring what
-- dynamicSBs used to construct for statusBarPropTo. See myStartupHook for why
-- this is now spawned directly via spawnOnce instead. The bar itself runs
-- flush edge to edge (minus the trayer lane on screen 0); the breathing room
-- around its content is xmobarrc's own left/right padding, not a gap here.
xmobarCmd :: ScreenId -> String
xmobarCmd (S sid) =
  "env XMOBAR_SCREEN=" ++ show (ewwScreenFor (S sid))
    ++ " xmobar -x " ++ show sid
    ++ " -p \"Static { xpos = " ++ show (myScreenXOffset (S sid))
    ++ ", ypos = 0, width = " ++ show (myBarWidth (S sid)) ++ ", height = 24 }\""
    ++ " $HOME/.config/xmobar/xmobarrc"

myKeys :: [((KeyMask, KeySym), X ())]
myKeys =
  [ ((myModMask, xK_r), spawn myLauncher)
  , ((myModMask, xK_Return), spawn myTerminal)
  , ((myModMask .|. shiftMask, xK_r), spawn "xmonad --recompile && xmonad --restart")
  , ((myModMask, xK_b), sendMessage ToggleStruts)
  , ((myModMask, xK_c), kill)
  , ((myModMask, xK_q), spawn "eww open --toggle powermenu")
  , ((myModMask, xK_m), spawn "eww open --toggle sidemenu")
  , ((myModMask, xK_t), spawn "$HOME/.config/xmonad/scripts/theme-chooser.sh")
  , ((myModMask .|. shiftMask, xK_q), io exitSuccess)
  , ((0, xK_Print), spawn "$HOME/.local/bin/flameshot-active-screen")
  , ((myModMask, xK_x), spawn "betterlockscreen -l")
  , ((myModMask .|. shiftMask, xK_x), spawn "betterlockscreen -l")
  , ((myModMask, xK_v), spawn "$HOME/.local/bin/clipboard menu")
  , ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q sset Master 5%+ && ~/.local/bin/volume")
  , ((0, xF86XK_AudioLowerVolume), spawn "amixer -q sset Master 5%- && ~/.local/bin/volume")
  , ((0, xF86XK_AudioMute), spawn "amixer -q sset Master toggle && ~/.local/bin/volume")
  -- Move focus to the physically right/left screen, and warp the mouse
  -- there too: rofi (and anything else that picks its monitor by pointer
  -- position rather than xmonad's focused screen) otherwise keeps opening
  -- on whichever screen the mouse was last on. Per myScreenXOffset, S 0
  -- (DisplayPort-1) sits on the right and S 1 (HDMI-A-0) on the left.
  , ((myModMask, xK_l), do
      screenWorkspace 0 >>= flip whenJust (windows . W.view)
      warpToScreen 0 0.5 0.5)
  , ((myModMask, xK_h), do
      screenWorkspace 1 >>= flip whenJust (windows . W.view)
      warpToScreen 1 0.5 0.5)
  ]

myConfig theme =
  def
    { terminal           = myTerminal
    , workspaces          = myWorkspaces
    , modMask             = myModMask
    , borderWidth         = myBorderWidth
    , normalBorderColor   = themeNormalBorder theme
    , focusedBorderColor  = themeFocusedBorder theme
    , layoutHook          = myLayout
    , startupHook         = myStartupHook
    -- Publishes the pretty-printed workspace log to the _XMONAD_LOG property,
    -- which xmobar reads via `Run UnsafeXPropertyLog "_XMONAD_LOG"` in
    -- xmobarrc. Previously wired up implicitly by dynamicSBs; now explicit
    -- since the bar is spawned directly (see myStartupHook).
    , logHook             = dynamicLogString (myXmobarPP theme) >>= xmonadPropLog' "_XMONAD_LOG"
    }
    `additionalKeys` myKeys

main :: IO ()
main = do
  theme <- readTheme
  xmonad
    . ewmhFullscreen
    . ewmh
    . docks
    $ myConfig theme
