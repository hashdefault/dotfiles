import XMonad
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (avoidStruts, docks, ToggleStruts (..))
import XMonad.Hooks.DynamicLog (xmonadPropLog')
import XMonad.Layout.Spacing (spacing)
import XMonad.Hooks.StatusBar.PP
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Util.EZConfig (additionalKeys)
import Graphics.X11.ExtraTypes.XF86
  ( xF86XK_AudioRaiseVolume
  , xF86XK_AudioLowerVolume
  , xF86XK_AudioMute
  )
import System.Exit (exitSuccess)
import System.Environment (setEnv)
import System.Directory (listDirectory)
import System.IO (readFile')
import Control.Exception (SomeException, try)
import Data.Char (isDigit)
import Data.List (elemIndex)
import Data.Maybe (fromMaybe)

myTerminal :: String
myTerminal = "alacritty"

myModMask :: KeyMask
myModMask = mod4Mask

myBorderWidth :: Dimension
myBorderWidth = 2

myNormalBorderColor, myFocusedBorderColor :: String
myNormalBorderColor  = "#3b3b4f"
myFocusedBorderColor = "#00ff99"

myLauncher :: String
myLauncher = "$HOME/.local/bin/rofi-launcher"

myWorkspaces :: [String]
myWorkspaces = ["dev", "web", "search", "chat", "music", "docs", "misc"]

myLayout = avoidStruts (spacing 5 tiled ||| spacing 5 (Mirror tiled) ||| Full)
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1 / 2
    delta   = 3 / 100

myStartupHook :: X ()
myStartupHook = do
  -- Set globally so every spawned child (rofi, alacritty, trayer, ...)
  -- inherits the cursor theme, in addition to the Xresources merge below.
  io $ setEnv "XCURSOR_THEME" "Hackneyed-24px"
  io $ setEnv "XCURSOR_SIZE" "24"
  -- Two 1920x1080 outputs: DisplayPort-1 is primary and physically on the
  -- right (x=1920), HDMI-A-0 is on the left (x=0). Set explicitly on every
  -- start since RandR's auto layout/primary pick isn't reliable across
  -- boots/hotplugs, and downstream bits (trayer's --monitor primary,
  -- myScreenXOffset below) depend on this exact arrangement.
  spawnOnce "xrandr --output DisplayPort-1 --primary --mode 1920x1080 --pos 1920x0 --output HDMI-A-0 --mode 1920x1080 --pos 0x0"
  spawnOnce "xrdb -merge $HOME/.Xresources"
  spawnOnce "xsetroot -cursor_name left_ptr"
  spawnOnce "sh -c 'command -v feh >/dev/null 2>&1 && feh --bg-fill \"$(find \"$HOME\"/Pictures/wallpapers -type f \\( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" \\) | shuf -n1)\"'"
  spawnOnce "picom --config $HOME/.config/picom/picom.conf -b"
  spawnOnce "trayer --edge top --align right --widthtype request --height 24 --transparent true --alpha 0 --tint 0x121222 --distance 0 --SetDockType true --SetPartialStrut true --monitor primary"
  spawnOnce "blueman-applet"
  spawnOnce "sh -c 'command -v nm-applet >/dev/null 2>&1 && nm-applet'"
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
  hasTrayer <- io isTrayerRunning
  spawnOnce (xmobarCmd (S 0) hasTrayer)
  spawnOnce (xmobarCmd (S 1) hasTrayer)

-- EWMH desktop indices (as consumed by `wmctrl -s`) follow the same order
-- as myWorkspaces, so a tag can be turned into the index wmctrl needs.
wsIndex :: String -> Int
wsIndex ws = fromMaybe 0 (elemIndex ws myWorkspaces)

-- Makes a workspace label clickable: left-click switches to it via wmctrl,
-- since EWMH (enabled by `ewmh` in main) keeps _NET_CURRENT_DESKTOP in sync.
wsAction :: String -> String -> String
wsAction ws body =
  "<action=`wmctrl -s " ++ show (wsIndex ws) ++ "` button=1>" ++ body ++ "</action>"

myXmobarPP :: PP
myXmobarPP = def
  { ppCurrent         = \ws -> wsAction ws (xmobarColor "#00ff99" "" ws)
  , ppVisible         = \ws -> wsAction ws (xmobarColor "#a48cf2" "" ws)
  , ppHidden          = \ws ->
      wsAction ws
        ( "<box type=Bottom width=3 mb=1 color=#f265b5>"
            ++ xmobarColor "#7081d0" "" ws
            ++ "</box>"
        )
  , ppHiddenNoWindows = \ws -> wsAction ws (xmobarColor "#6c77ab" "" ws)
  , ppUrgent          = \ws -> wsAction ws (xmobarColor "#f0313e" "" (wrap "!" "!" ws))
  , ppSep             = "  "
  , ppWsSep           = " "
  , ppTitle           = const ""
  , ppOrder           = \(ws : _) -> [ws]
  }

-- Global X offset of each physical screen's origin, from
-- `xrandr --listactivemonitors` (0: DisplayPort-1 +1920+0, 1: HDMI-A-0
-- +0+0), which is also the order xmonad's ScreenId follows. Needed because
-- xmobar's
-- `OnScreen N Static {...}` shifts where the bar is *drawn* but NOT the
-- _NET_WM_STRUT_PARTIAL it publishes (both instances advertised the same
-- x=3..1916 strut), so ManageDocks only ever reserved space on screen 0 and
-- windows on screen 1 could cover the bar. Using plain `Static` with the
-- real global xpos sidesteps that: the strut ends up correct on both.
myScreenXOffset :: ScreenId -> Int
myScreenXOffset (S 0) = 1920
myScreenXOffset _     = 0

-- Screen 0 (DisplayPort-1) is xrandr's "primary" output, where trayer docks
-- its icons flush against the right edge (`--distance 0`). trayer's own
-- panel window is currently 46px (2 icons: nm-applet + flameshot's tray
-- icon, confirmed via the live window tree, not just guessed from icon
-- count) — 51 leaves 5px of breathing room. Static on purpose (querying
-- trayer's live width from startupHook isn't worth the added fragility for
-- a number that rarely changes), so it'll need bumping if icon count grows.
myTrayerLaneWidth :: Int
myTrayerLaneWidth = 51

-- When trayer is actually up, shrink that bar's width to leave it the lane
-- above so it stops sitting on top of the volume widget; if trayer isn't
-- running (crashed, not installed, disabled) that lane would just be dead
-- space, so fall back to the full width. The other screen has no tray and
-- always keeps the full 1920px.
-- Deliberately doesn't shell out to `pgrep`: spawning a subprocess and
-- waiting on it (as readProcessWithExitCode does) races xmonad's own global
-- SIGCHLD handler, which reaps `spawn`-launched children independently —
-- whichever waitpid gets there first "wins" and the other throws ECHILD
-- (surfaces as an uncaught `waitForProcess: does not exist`), which aborted
-- everything queued after this check in startupHook. Reading /proc directly
-- has no child process, so no such race.
isTrayerRunning :: IO Bool
isTrayerRunning = do
  pids <- filter (all isDigit) <$> listDirectory "/proc"
  or <$> mapM isTrayerPid pids
  where
    isTrayerPid pid = do
      result <- try (readFile' ("/proc/" ++ pid ++ "/comm")) :: IO (Either SomeException String)
      pure $ either (const False) ((== "trayer") . takeWhile (/= '\n')) result

myBarWidth :: ScreenId -> Bool -> Int
myBarWidth (S 0) hasTrayer = if hasTrayer then 1920 - myTrayerLaneWidth else 1920
myBarWidth _     _         = 1920

-- Builds the shell command that launches one screen's xmobar, mirroring what
-- dynamicSBs used to construct for statusBarPropTo. See myStartupHook for why
-- this is now spawned directly via spawnOnce instead. The bar itself runs
-- flush edge to edge (minus the trayer lane on screen 0); the breathing room
-- around its content is xmobarrc's own left/right padding, not a gap here.
xmobarCmd :: ScreenId -> Bool -> String
xmobarCmd (S sid) hasTrayer =
  "env XMOBAR_SCREEN=" ++ show sid
    ++ " xmobar -x " ++ show sid
    ++ " -p \"Static { xpos = " ++ show (myScreenXOffset (S sid))
    ++ ", ypos = 0, width = " ++ show (myBarWidth (S sid) hasTrayer) ++ ", height = 24 }\""
    ++ " $HOME/.config/xmobar/xmobarrc"

myKeys :: [((KeyMask, KeySym), X ())]
myKeys =
  [ ((myModMask, xK_r), spawn myLauncher)
  , ((myModMask, xK_Return), spawn myTerminal)
  , ((myModMask .|. shiftMask, xK_r), spawn "xmonad --recompile && xmonad --restart")
  , ((myModMask, xK_b), sendMessage ToggleStruts)
  , ((myModMask, xK_q), spawn "eww open --toggle powermenu")
  , ((myModMask, xK_m), spawn "eww open --toggle sidemenu")
  , ((myModMask .|. shiftMask, xK_q), io exitSuccess)
  , ((0, xK_Print), spawn "$HOME/.local/bin/flameshot-active-screen")
  , ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q sset Master 5%+ && ~/.local/bin/volume")
  , ((0, xF86XK_AudioLowerVolume), spawn "amixer -q sset Master 5%- && ~/.local/bin/volume")
  , ((0, xF86XK_AudioMute), spawn "amixer -q sset Master toggle && ~/.local/bin/volume")
  ]

myConfig =
  def
    { terminal           = myTerminal
    , workspaces          = myWorkspaces
    , modMask             = myModMask
    , borderWidth         = myBorderWidth
    , normalBorderColor   = myNormalBorderColor
    , focusedBorderColor  = myFocusedBorderColor
    , layoutHook          = myLayout
    , startupHook         = myStartupHook
    -- Publishes the pretty-printed workspace log to the _XMONAD_LOG property,
    -- which xmobar reads via `Run UnsafeXPropertyLog "_XMONAD_LOG"` in
    -- xmobarrc. Previously wired up implicitly by dynamicSBs; now explicit
    -- since the bar is spawned directly (see myStartupHook).
    , logHook             = dynamicLogString myXmobarPP >>= xmonadPropLog' "_XMONAD_LOG"
    }
    `additionalKeys` myKeys

main :: IO ()
main =
  xmonad
    . ewmhFullscreen
    . ewmh
    . docks
    $ myConfig
