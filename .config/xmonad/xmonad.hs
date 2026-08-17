import XMonad
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (avoidStruts, docks, ToggleStruts (..))
import XMonad.Layout.Spacing (spacing)
import XMonad.Hooks.StatusBar (StatusBarConfig, statusBarPropTo, dynamicSBs)
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
  spawnOnce "xrdb -merge $HOME/.Xresources"
  spawnOnce "xsetroot -cursor_name left_ptr"
  spawnOnce "sh -c 'command -v feh >/dev/null 2>&1 && feh --randomize --bg-fill \"$HOME\"/Pictures/wallpapers/*'"
  spawnOnce "picom --config $HOME/.config/picom/picom.conf -b"
  spawnOnce "trayer --edge top --align right --widthtype request --height 24 --transparent true --alpha 0 --tint 0x121222 --distance 0 --SetDockType true --SetPartialStrut true --monitor primary"
  spawnOnce "blueman-applet"
  spawnOnce "sh -c 'command -v nm-applet >/dev/null 2>&1 && nm-applet'"
  spawn "xset r rate 200 35"

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
  , ppHiddenNoWindows = \ws -> wsAction ws (xmobarColor "#3b4261" "" ws)
  , ppUrgent          = \ws -> wsAction ws (xmobarColor "#f0313e" "" (wrap "!" "!" ws))
  , ppSep             = "  "
  , ppWsSep           = " "
  , ppTitle           = const ""
  , ppOrder           = \(ws : _) -> [ws]
  }

-- Global X offset of each physical screen's origin, from
-- `xrandr --listactivemonitors` (0: HDMI-1 +1920+0, 1: DP-1 +0+0), which is
-- also the order xmonad's ScreenId follows. Needed because xmobar's
-- `OnScreen N Static {...}` shifts where the bar is *drawn* but NOT the
-- _NET_WM_STRUT_PARTIAL it publishes (both instances advertised the same
-- x=3..1916 strut), so ManageDocks only ever reserved space on screen 0 and
-- windows on screen 1 could cover the bar. Using plain `Static` with the
-- real global xpos sidesteps that: the strut ends up correct on both.
myScreenXOffset :: ScreenId -> Int
myScreenXOffset (S 0) = 1920
myScreenXOffset _     = 0

-- Screen 0 (HDMI-1) is xrandr's "primary" output, where trayer docks its
-- icons flush against the right edge (`--distance 0`). Shrink that bar's
-- width to leave trayer a lane so it stops sitting on top of the volume
-- widget; the other screen has no tray and keeps the full 1920px.
myBarWidth :: ScreenId -> Int
myBarWidth (S 0) = 1880
myBarWidth _     = 1920

-- One xmobar instance per physical monitor (pinned via `-x <screen>`),
-- so the bar follows both 1920x1080 outputs.
-- XMOBAR_SCREEN is inherited by the eww click actions in xmobarrc so each
-- bar's widgets (calendar_full, weather, storagemon) open via `eww --screen`
-- on the same physical monitor the bar (and the click) is on. eww's numeric
-- screen index follows the same Xinerama/RandR order as xmonad's ScreenId.
mySB :: ScreenId -> X StatusBarConfig
mySB (S sid) =
  pure $
    statusBarPropTo
      "_XMONAD_LOG"
      ( "env XMOBAR_SCREEN=" ++ show sid
          ++ " xmobar -x " ++ show sid
          ++ " -p \"Static { xpos = " ++ show (myScreenXOffset (S sid))
          ++ ", ypos = 0, width = " ++ show (myBarWidth (S sid)) ++ ", height = 24 }\""
          ++ " $HOME/.config/xmobar/xmobarrc"
      )
      (pure myXmobarPP)

myKeys :: [((KeyMask, KeySym), X ())]
myKeys =
  [ ((myModMask, xK_r), spawn myLauncher)
  , ((myModMask, xK_Return), spawn myTerminal)
  , ((myModMask .|. shiftMask, xK_r), spawn "xmonad --recompile && xmonad --restart")
  , ((myModMask, xK_b), sendMessage ToggleStruts)
  , ((myModMask, xK_q), io exitSuccess)
  , ((0, xK_Print), spawn "flameshot gui")
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
    }
    `additionalKeys` myKeys

main :: IO ()
main =
  xmonad
    . ewmhFullscreen
    . ewmh
    . docks
    . dynamicSBs mySB
    $ myConfig
