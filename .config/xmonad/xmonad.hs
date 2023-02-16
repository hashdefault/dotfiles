import           System.Directory
import           System.Exit
import           System.IO

import qualified Codec.Binary.UTF8.String      as UTF8
import           Data.Maybe                     ( fromJust )
import           Data.Maybe                     ( isJust )
import           XMonad

import           XMonad.Actions.CycleWS
import           XMonad.Actions.GridSelect
import           XMonad.Actions.MouseResize
import           XMonad.Actions.Promote
import           XMonad.Actions.RotSlaves       ( rotAllDown
                                                , rotSlavesDown
                                                )
import qualified XMonad.Actions.Search         as S
import           XMonad.Actions.SpawnOn
import           XMonad.Actions.WindowGo        ( runOrRaise )
import           XMonad.Actions.WithAll         ( killAll
                                                , sinkAll
                                                )




import           XMonad.Config.Azerty
import           XMonad.Config.Desktop
import           XMonad.Hooks.DynamicLog
import           XMonad.Util.NamedActions
import           XMonad.Util.NamedScratchpad
import           XMonad.Util.Run                ( runProcessWithInput
                                                , safeSpawn
                                                , spawnPipe
                                                )
import           XMonad.Util.SpawnOnce

import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers     ( doCenterFloat
                                                , doFullFloat
                                                , isDialog
                                                , isFullscreen
                                                )
import           XMonad.Hooks.SetWMName

import           XMonad.Hooks.StatusBar
import           XMonad.Hooks.StatusBar.PP
import           XMonad.Hooks.UrgencyHook
import           XMonad.Hooks.WindowSwallowing
import           XMonad.Hooks.WorkspaceHistory
import           XMonad.Util.EZConfig           ( additionalKeys
                                                , additionalMouseBindings
                                                )



import           XMonad.Layout.Accordion
import           XMonad.Layout.GridVariants     ( Grid(Grid) )
-- Layouts modifiers
import           XMonad.Layout.LayoutModifier
import           XMonad.Layout.LimitWindows     ( decreaseLimit
                                                , increaseLimit
                                                , limitWindows
                                                )
--import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
--import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import           XMonad.Layout.Renamed
import           XMonad.Layout.Simplest
import           XMonad.Layout.SimplestFloat
import           XMonad.Layout.SubLayouts
--import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.Layout.ToggleLayouts   as T
                                                ( ToggleLayout(Toggle)
                                                , toggleLayouts
                                                )


import           XMonad.Layout.Cross            ( simpleCross )
import           XMonad.Layout.Fullscreen       ( fullscreenFull )
import           XMonad.Layout.Gaps
import           XMonad.Layout.IndependentScreens
import           XMonad.Layout.MultiToggle
import           XMonad.Layout.MultiToggle.Instances
import           XMonad.Layout.NoBorders
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.ShowWName
import           XMonad.Layout.Spacing
import           XMonad.Layout.Spiral           ( spiral )
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ThreeColumns
import           XMonad.Layout.WindowArranger   ( WindowArrangerMsg(..)
                                                , windowArrange
                                                )
import           XMonad.Layout.WindowNavigation


import           XMonad.Hooks.DynamicLog        ( PP(..)
                                                , dynamicLogWithPP
                                                , shorten
                                                , wrap
                                                , xmobarColor
                                                , xmobarPP
                                                )
import           XMonad.Layout.CenteredMaster   ( centerMaster )

import           Control.Monad                  ( liftM2 )
import qualified DBus                          as D
import qualified DBus.Client                   as D
import qualified Data.ByteString               as B
import qualified Data.Map                      as M
import           Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet               as W

   -- ColorScheme module (SET ONLY ONE!)
      -- Possible choice are:
      -- DoomOne
      -- Dracula
      -- GruvboxDark
      -- MonokaiPro
      -- Nord
      -- OceanicNext
      -- Palenight
      -- SolarizedDark
      -- SolarizedLight
      -- TomorrowNight
import           Colors.DoomOne

myStartupHook = do
  spawn "$HOME/.config/xmonad/scripts/autostart.sh"
  setWMName "LG3D"

-- colours
--normBord = "#4c566a"
--focdBord = "#5e81ac"
--fore = "#DEE3E0"
--back = "#282c34"
--winType = "#c678dd"

--mod4Mask= super key
--mod1Mask= alt key
--controlMask= ctrl key
--shiftMask= shift key

myFont :: String
myFont = "xft:Hack Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myBorderWidth :: Dimension
myBorderWidth = 2           -- Sets border width for windows

myNormColor :: String       -- Border color of normal windows
myNormColor = color15   -- This variable is imported from Colors.THEME

myFocusColor :: String      -- Border color of focused windows
myFocusColor = colorBack    -- This variable is imported from Colors.THEME

myBrowser = "brave"
myModMask = mod4Mask
encodeCChar = map fromIntegral . B.unpack
myFocusFollowsMouse = True

windowCount :: X (Maybe String)
windowCount =
  gets
    $ Just
    . show
    . length
    . W.integrate'
    . W.stack
    . W.workspace
    . W.current
    . windowset





--myWorkspaces =
 -- [ "\61612"
 -- , "\61899"
 -- , "\61947"
 -- , "\61635"
 -- , "\61502"
 -- , "\61501"
 -- , "\61705"
 -- , "\61564"
 -- , "\62150"
 -- , "\61872"
 -- ]
myWorkspaces =
  [ " dev "
  , " web "
  , " search "
  , " ftp "
  , " docs "
  , " adm "
  , " chat "
  , " music "
  , " model "
  , " enjoy "
  ]

--myWorkspaces    = ["I","II","III","IV","V","VI","VII","VIII","IX","X"]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1 ..] -- (,) == \x y -> (x,y)

clickable ws =
  "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where i = fromJust $ M.lookup ws myWorkspaceIndices

myBaseConfig = desktopConfig

-- window manipulations
myManageHook =
  composeAll
    . concat
    $ [ [isDialog --> doCenterFloat]
      , [ className =? c --> doCenterFloat | c <- myCFloats ]
      , [ title =? t --> doFloat | t <- myTFloats ]
      , [ resource =? r --> doFloat | r <- myRFloats ]
      , [ resource =? i --> doIgnore | i <- myIgnores ]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61612" | x <- my1Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61899" | x <- my2Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61947" | x <- my3Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61635" | x <- my4Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61502" | x <- my5Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61501" | x <- my6Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61705" | x <- my7Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61564" | x <- my8Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\62150" | x <- my9Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61872" | x <- my10Shifts]
      ]
 where
    -- doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift
  myCFloats =
    [ "Arandr"
    , "Arcolinux-calamares-tool.py"
    , "Archlinux-tweak-tool.py"
    , "Arcolinux-welcome-app.py"
    , "Galculator"
    , "mpv"
    ]
  myTFloats = ["Downloads", "Save As..."]
  myRFloats = []
  myIgnores = ["desktop_window"]
    -- my1Shifts = ["Chromium", "Vivaldi-stable", "Firefox"]
    -- my2Shifts = []
    -- my3Shifts = ["Inkscape"]
    -- my4Shifts = []
    -- my5Shifts = ["Gimp", "feh"]
    -- my6Shifts = ["vlc", "mpv"]
    -- my7Shifts = ["Virtualbox"]
    -- my8Shifts = ["Thunar"]
    -- my9Shifts = []
    -- my10Shifts = ["discord"]

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing
  :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing'
  :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall =
  renamed [Replace "tall"]
    $ limitWindows 5
    $ smartBorders
    $ windowNavigation
    $ addTabs shrinkText myTabTheme
    $ subLayout [] (smartBorders Simplest)
    $ mySpacing 8
    $ ResizableTall 1 (3 / 100) (1 / 2) []
monocle =
  renamed [Replace "monocle"]
    $ smartBorders
    $ windowNavigation
    $ addTabs shrinkText myTabTheme
    $ subLayout [] (smartBorders Simplest)
    $ Full
floats = renamed [Replace "floats"] $ smartBorders $ simplestFloat
grid =
  renamed [Replace "grid"]
    $ limitWindows 9
    $ smartBorders
    $ windowNavigation
    $ addTabs shrinkText myTabTheme
    $ subLayout [] (smartBorders Simplest)
    $ mySpacing 8
    $ mkToggle (single MIRROR)
    $ Grid (16 / 10)
spirals =
  renamed [Replace "spirals"]
    $ limitWindows 9
    $ smartBorders
    $ windowNavigation
    $ addTabs shrinkText myTabTheme
    $ subLayout [] (smartBorders Simplest)
    $ mySpacing' 8
    $ spiral (6 / 7)
threeCol =
  renamed [Replace "threeCol"]
    $ limitWindows 7
    $ smartBorders
    $ windowNavigation
    $ addTabs shrinkText myTabTheme
    $ subLayout [] (smartBorders Simplest)
    $ ThreeCol 1 (3 / 100) (1 / 2)
threeRow =
  renamed [Replace "threeRow"]
    $ limitWindows 7
    $ smartBorders
    $ windowNavigation
    $ addTabs shrinkText myTabTheme
    $ subLayout [] (smartBorders Simplest)
            -- Mirror takes a layout and rotates it by 90 degrees.
            -- So we are applying Mirror to the ThreeCol layout.
    $ Mirror
    $ ThreeCol 1 (3 / 100) (1 / 2)
tabs =
  renamed [Replace "tabs"]
            -- I cannot add spacing to this layout because it will
            -- add spacing between window and tabs which looks bad.
                           $ tabbed shrinkText myTabTheme
tallAccordion = renamed [Replace "tallAccordion"] $ Accordion
wideAccordion = renamed [Replace "wideAccordion"] $ Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = color15
                 , inactiveColor       = color08
                 , activeBorderColor   = color15
                 , inactiveBorderColor = colorBack
                 , activeTextColor     = colorBack
                 , inactiveTextColor   = color16
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def { swn_font    = "xft:Ubuntu:bold:size=60"
                       , swn_fade    = 1.0
                       , swn_bgcolor = "#1c1f24"
                       , swn_color   = "#ffffff"
                       }


myLayout =
  avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $ mkToggle
    (NBFULL ?? NOBORDERS ?? EOT)
    myDefaultLayout
--myLayout =
--  spacingRaw True (Border 0 8 8 8) True (Border 8 8 8 8) True
--    $   avoidStruts
--    $   mkToggle (NBFULL ?? NOBORDERS ?? EOT)
--    $   tiled
--    ||| Mirror tiled
--    ||| spiral (6 / 7)
--    ||| ThreeColMid 1 (3 / 100) (1 / 2)
--    ||| Full
-- where
--  tiled       = Tall nmaster delta tiled_ratio
--  nmaster     = 1
--  delta       = 3 / 100
--  tiled_ratio = 1 / 2

 where
  myDefaultLayout =
    withBorder myBorderWidth tall
      ||| noBorders monocle
      ||| floats
      ||| noBorders tabs
      ||| grid
      ||| spirals
      ||| threeCol
      ||| threeRow
      ||| tallAccordion
      ||| wideAccordion

myMouseBindings (XConfig { XMonad.modMask = modMask }) =
  M.fromList
    $

    -- mod-button1, Set the window to floating mode and move by dragging
      [ ( (modMask, 1)
        , (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)
        )

    -- mod-button2, Raise the window to the top of the stack
      , ((modMask, 2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
      , ( (modMask, 3)
        , (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)
        )
      ]


-- keys config

myKeys conf@(XConfig { XMonad.modMask = modMask }) =
  M.fromList
    $
  ----------------------------------------------------------------------
  -- SUPER + FUNCTION KEYS
       [ ((modMask, xK_c), kill)
       , ((modMask, xK_f), sendMessage $ Toggle NBFULL)
       , ( (modMask, xK_r)
         , spawn
         $  "dmenu_run -p 'exec:' -i -nb '"
         ++ colorBack
         ++ "' -nf '"
         ++ color16
         ++ "' -sb '"
         ++ color05
         ++ "' -sf '"
         ++ colorBack
         ++ "' -fn 'HackRegular:bold:pixelsize=14' "
         )
       , ((modMask, xK_v), spawn $ "pavucontrol")
       , ((modMask, xK_x), spawn $ "archlinux-logout")
       , ((modMask, xK_Escape), spawn $ "xkill")
       , ((modMask, xK_Return), spawn $ "alacritty")
       , ((modMask, xK_b), spawn $ myBrowser)
       , ((modMask, xK_F2), spawn $ "alacritty -e nvim")
       , ((modMask, xK_F4), spawn $ "gimp")
       , ((modMask, xK_F6), spawn $ "vlc --video-on-top")
       , ((modMask, xK_F7), spawn $ "virtualbox")
       , ((modMask, xK_F9), spawn $ "evolution")

  -- Move focus to the next window.
       , ((modMask, xK_j), windows W.focusDown)

  -- Move focus to the previous window.
       , ((modMask, xK_k), windows W.focusUp)


  -- FUNCTION KEYS
       , ((0, xK_F12), spawn $ "alacritty")

  -- SUPER + SHIFT KEYS
       , ((modMask .|. shiftMask, xK_Return), spawn $ "thunar")
         --, ((modMask, xK_d ), spawn $ "~/.xmonad/launcher/launcher.sh")
       , ( (modMask .|. shiftMask, xK_r)
         , spawn $ "xmonad --recompile && xmonad --restart"
         )
       , ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))
       , ((modMask .|. shiftMask, xK_y), spawn $ "youtube-music")
-- , ((modMask .|. shiftMask , xK_x ), io (exitWith ExitSuccess))
       , ((modMask .|. shiftMask, xK_c), spawn $ "conky-toggle")
       , ( (modMask .|. shiftMask, xK_h)
         , spawn $ "alacritty 'htop task manager' -e htop"
         )



  -- CONTROL + ALT KEYS
       , ((controlMask .|. mod1Mask, xK_Next), spawn $ "conky-rotate -n")
       , ((controlMask .|. mod1Mask, xK_Prior), spawn $ "conky-rotate -p")
       , ((controlMask .|. mod1Mask, xK_e), spawn $ "archlinux-tweak-tool")
       , ((controlMask .|. mod1Mask, xK_f), spawn $ "firefox")
       , ((controlMask .|. mod1Mask, xK_n), spawn $ "nitrogen")
       , ((controlMask .|. mod1Mask, xK_k), spawn $ "archlinux-logout")
       , ((controlMask .|. mod1Mask, xK_p), spawn $ "pamac-manager")
       , ((controlMask .|. mod1Mask, xK_u), spawn $ "pavucontrol")
       , ((controlMask .|. mod1Mask, xK_Return), spawn $ "alacritty")

  -- ALT + ... KEYS
       , ((mod1Mask, xK_r), spawn $ "xmonad --restart")

  --SCREENSHOTS
       , ((0, xK_Print), spawn $ "flameshot gui")

  --MULTIMEDIA KEYS

  -- Mute volume
       , ((0, xF86XK_AudioMute), spawn $ "amixer -q set Master toggle")

  -- Decrease volume
       , ((0, xF86XK_AudioLowerVolume), spawn $ "amixer -q set Master 5%-")

  -- Increase volume
       , ((0, xF86XK_AudioRaiseVolume), spawn $ "amixer -q set Master 5%+")

  -- Increase brightness
       , ((0, xF86XK_MonBrightnessUp), spawn $ "xbacklight -inc 5")

  -- Decrease brightness
       , ((0, xF86XK_MonBrightnessDown), spawn $ "xbacklight -dec 5")

  -- Alternative to increase brightness

  -- Increase brightness
  -- , ((0, xF86XK_MonBrightnessUp),  spawn $ "brightnessctl s 5%+")

  -- Decrease brightness
  -- , ((0, xF86XK_MonBrightnessDown), spawn $ "brightnessctl s 5%-")

--  , ((0, xF86XK_AudioPlay), spawn $ "mpc toggle")
--  , ((0, xF86XK_AudioNext), spawn $ "mpc next")
--  , ((0, xF86XK_AudioPrev), spawn $ "mpc prev")
--  , ((0, xF86XK_AudioStop), spawn $ "mpc stop")
       , ((0, xF86XK_AudioPlay), spawn $ "playerctl play-pause")
       , ((0, xF86XK_AudioNext), spawn $ "playerctl next")
       , ((0, xF86XK_AudioPrev), spawn $ "playerctl previous")
       , ((0, xF86XK_AudioStop), spawn $ "playerctl stop")


  --------------------------------------------------------------------
  --  XMONAD LAYOUT KEYS

  -- Cycle through the available layout algorithms.
       , ((modMask, xK_space), sendMessage NextLayout)

  --Focus selected desktop
       , ((mod1Mask, xK_Tab), nextWS)

  --Focus selected desktop
       , ((modMask, xK_Tab), nextWS)

  --Focus selected desktop
       , ((controlMask .|. mod1Mask, xK_Left), prevWS)

  --Focus selected desktop
       , ((controlMask .|. mod1Mask, xK_Right), nextWS)

  --  Reset the layouts on the current workspace to default.
       , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
  -- Move focus to the master window.
       , ((modMask .|. shiftMask, xK_m), windows W.focusMaster)

  -- Swap the focused window with the next window.
       , ((modMask .|. shiftMask, xK_j), windows W.swapDown)

  -- Swap the focused window with the next window.
       , ((controlMask .|. modMask, xK_Down), windows W.swapDown)

  -- Swap the focused window with the previous window.
       , ((modMask .|. shiftMask, xK_k), windows W.swapUp)

  -- Swap the focused window with the previous window.
       , ((controlMask .|. modMask, xK_Up), windows W.swapUp)

  -- Shrink the master area.
       , ((controlMask .|. shiftMask, xK_j), sendMessage MirrorShrink)

  -- Expand the master area.
       , ((controlMask .|. shiftMask, xK_k), sendMessage MirrorExpand)


  -- Shrink the master area.
       , ((controlMask .|. shiftMask, xK_h), sendMessage Shrink)

  -- Expand the master area.
       , ((controlMask .|. shiftMask, xK_l), sendMessage Expand)

  -- Push window back into tiling.
       , ((controlMask .|. shiftMask, xK_t), withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
       , ((controlMask .|. modMask, xK_Left), sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
       , ((controlMask .|. modMask, xK_Right), sendMessage (IncMasterN (-1)))
       ]
    ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
       [ ((m .|. modMask, k), windows $ f i)

  --Keyboard layouts
  --qwerty users use this line
       | (i, k) <- zip
         (XMonad.workspaces conf)
         [xK_1, xK_2, xK_3, xK_4, xK_5, xK_6, xK_7, xK_8, xK_9, xK_0]
       , (f, m) <-
         [ (W.greedyView                    , 0)
         , (W.shift                         , shiftMask)
         , (\i -> W.greedyView i . W.shift i, shiftMask)
         ]
       ]

    ++
  -- ctrl-shift-{w,e,r}, Move client to screen 1, 2, or 3
  -- [((m .|. controlMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  --    | (key, sc) <- zip [xK_w, xK_e] [0..]
  --    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
       [ ( (m .|. modMask, key)
         , screenWorkspace sc >>= flip whenJust (windows . f)
         )
       | (key, sc) <- zip [xK_Left, xK_Right] [0 ..]
       , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
       ]

 where
  nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
  nonEmptyNonNSP =
    WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))
main :: IO ()
main = do
  xmproc0 <- spawnPipe
    ("xmobar -x 0 $HOME/.config/xmobar/" ++ colorScheme ++ "-xmobarrc")
  xmproc1 <- spawnPipe
    ("xmobar -x 1 $HOME/.config/xmobar/" ++ colorScheme ++ "-xmobarrc")

  dbus <- D.connectSession
  -- Request access to the DBus name
  D.requestName
    dbus
    (D.busName_ "org.xmonad.Log")
    [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]


  xmonad . ewmh $ myBaseConfig
    { startupHook        = myStartupHook
    , layoutHook         = showWName' myShowWNameTheme $ myLayout
    , manageHook = manageSpawn <+> myManageHook <+> manageHook myBaseConfig
    , modMask            = myModMask
    , borderWidth        = myBorderWidth
    , handleEventHook    = handleEventHook myBaseConfig
    , focusFollowsMouse  = myFocusFollowsMouse
    , workspaces         = myWorkspaces
    , focusedBorderColor = myNormColor
    , normalBorderColor  = myFocusColor
    , keys               = myKeys
    , mouseBindings      = myMouseBindings
    , logHook            =
      dynamicLogWithPP $ filterOutWsPP [scratchpadWorkspaceTag] $ xmobarPP
        { ppOutput          = \x -> hPutStrLn xmproc0 x   -- xmobar on monitor 1
                                                        >> hPutStrLn xmproc1 x   -- xmobar on monitor 2
        , ppCurrent         = xmobarColor color06 ""
                                . wrap
                                    (  "<box type=Bottom width=2 mb=2 color="
                                    ++ color06
                                    ++ ">"
                                    )
                                    "</box>"
          -- Visible but not current workspace
        , ppVisible         = xmobarColor color06 "" . clickable
          -- Hidden workspace
        , ppHidden          = xmobarColor color05 ""
                              . wrap
                                  ("<box type=Top width=2 mt=2 color=" ++ color05 ++ ">")
                                  "</box>"
                              . clickable
          -- Hidden workspaces (no windows)
        , ppHiddenNoWindows = xmobarColor color05 "" . clickable
          -- Title of active window
        , ppTitle           = xmobarColor color16 "" . shorten 60
          -- Separator character
        , ppSep             = "<fc=" ++ color09 ++ "> <fn=1>|</fn> </fc>"
          -- Urgent workspace
        , ppUrgent          = xmobarColor color02 "" . wrap "!" "!"
          -- Adding # of windows on current workspace to the bar
        , ppExtras          = [windowCount]
          -- order of things in xmobar
        , ppOrder           = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t]
        }
    }
