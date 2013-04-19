import XMonad
import XMonad.Util.EZConfig
import XMonad.Util.Run (runInTerm, spawnPipe)

import XMonad.Actions.WindowGo (title, raiseMaybe, runOrRaise)

import XMonad.Hooks.DynamicHooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ICCCMFocus

import XMonad.Layout.NoBorders
import XMonad.Layout.IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Accordion
import XMonad.Layout.Grid
import XMonad.Layout.SimpleFloat
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import System.IO
 
import Data.Ratio ((%))
import Data.List
 
myLayout = avoidStruts . smartBorders
    $ mkToggle(FULL??EOT)
    $ onWorkspace "1" (imLayout)
--    $ onWorkspace "1" ( withIM (1/7) (Role "buddy_list") (Grid ||| Full ||| tiled ||| Mirror tiled))
    $ onWorkspace "2" ( Full ||| tiled ||| Mirror tiled )
    $ onWorkspace "3" ( Full ||| tiled ||| Mirror tiled )
    $ ( Grid ||| Full ||| tiled ||| Mirror tiled )
    where
      tiled = Tall nmaster delta ratio
      nmaster = 1
      ratio = 1/2
      delta = 3/100

imLayout = withIM (1/6) (Role "contact_list") Grid
-- imLayout = withIM (1%5) (Title "Pino")
--           (Or (Title "Buddy List")
--           (Or (Title "Pino")
--           (And (Resource "main") (ClassName "psi")))

myManageHook = composeAll . concat $
    [ [ manageHook defaultConfig
        , className =? "Unity-2d-panel" --> doIgnore
        , className =? "Unity-2d-launcher" --> doIgnore
      ]
    , [ className =? c --> doShift "2" | c <- myBrowsers ]
    , [ className =? "java-lang-Thread" --> doShift "3"
      , className =? "Pino" --> doShift "1"
      , className =? "Pidgin" --> doShift "1"
      , className =? "Skype" --> doShift "1"
      , className =? "Banshee" --> doShift "9"
      , className =? "Tomboy" --> doShift "8"
      ]
    ]
    where myBrowsers = ["Opera", "Google-chrome", "chromium-browser", "chromium-dev", "chromium"] 
 
myKeys = [ ("M-f", sendMessage $ Toggle FULL)
         , ("M-p", spawn "dmenu_run -i")
         , ("M-a", spawn "screenshot")
         , ("M-S-a", spawn "select-screenshot")
         , ("<XF86AudioLowerVolume>", spawn "amixer -q set Master 4%- unmute")
         , ("<XF86AudioRaiseVolume>", spawn "amixer -q set Master 4%+ unmute")
	 , ("<XF86AudioMute>", spawn "amixer -q set Master toggle")
         ] 

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobarrc"
    xmonad $ withUrgencyHook NoUrgencyHook defaultConfig
         { modMask = mod4Mask
         , terminal = "gnome-terminal"
         , manageHook = myManageHook
         , layoutHook = myLayout
         , logHook = takeTopFocus >> dynamicLogWithPP xmobarPP
             { ppOutput = hPutStrLn xmproc
             , ppTitle = xmobarColor "green" "" . shorten 50
             , ppUrgent = xmobarColor "red" "" . wrap " !*! " " !*! "
             }
         } `additionalKeysP` myKeys
