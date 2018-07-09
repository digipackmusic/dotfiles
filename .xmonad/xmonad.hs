import XMonad
import XMonad.Config.Desktop
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run

myTerminal = "konsole"
myModMask = mod4Mask

myWorkspaces = ["1:main", "2:web", "3:edit", "4:chat", "5:misc"]

myXmonadBar = "dzen2 -x '0' -y '0' -h '24' -w '700' -ta 'l' -fg '#FFFFFF' -bg '#1B1D1E'"
myStatusBar = "conky -c /home/luke/.xmonad/conky_dzen | dzen2 -x '900' -w '920' -h '24' -ta 'r' -bg '#1B1D1E' -fg '#FFFFFF' -y '0'"
myPomoBar =  "conky -c /home/luke/.xmonad/conky_pomo | dzen2 -x '700' -y '0' -h '24' -w '200' -ta 'l' -bg '#1B1D1E'"
 
myBitmapsDir = "/home/luke/.xmonad/dzen2"

main = do
    dzenLeftBar <- spawnPipe myXmonadBar
    dzenCenterBar <- spawnPipe myPomoBar
    dzenRightBar <- spawnPipe myStatusBar
    xmonad $ desktopConfig
        {
            terminal        = myTerminal
        ,   workspaces      = myWorkspaces
        ,   modMask         = myModMask
        ,   logHook         = myLogHook dzenLeftBar
        ,   borderWidth     = 2
        }
        `additionalKeys`
            [
                ((myModMask, xK_p),         spawn "dmenu_run -i -p '>'")
            ,   ((myModMask .|. shiftMask, xK_l),         spawn "xscreensaver-command -lock")
            ,   ((0,         xK_Print),     spawn "scrot -e 'mv $f ~/screenshots/'")
            ,   ((myModMask, xK_n),         spawn "touch ~/.pomodoro_session")  -- new pomodoro
            ,   ((myModMask, xK_c),         spawn "rm ~/.pomodoro_session")     -- cancel pomodoro
            ,   ((0,         0x1008ff12),   spawn "amixer -q sset Master toggle")        -- XF86AudioMute
            ,   ((0,         0x1008ff11),   spawn "amixer -q sset Master 5%-")   -- XF86AudioLowerVolume
            ,   ((0,         0x1008ff13),   spawn "amixer -q sset Master 5%+")   -- XF86AudioRaiseVolume
            ]

myLogHook h = dynamicLogWithPP $ def
    {
      ppCurrent           =   dzenColor "#ebac54" "#1B1D1E" . pad
    , ppVisible           =   dzenColor "white" "#1B1D1E" . pad
    , ppHidden            =   dzenColor "white" "#1B1D1E" . pad
    , ppHiddenNoWindows   =   dzenColor "#7b7b7b" "#1B1D1E" . pad
    , ppUrgent            =   dzenColor "black" "red" . pad
    , ppWsSep             =   " "
    , ppSep               =   "  |  "
    , ppLayout            =   dzenColor "#ebac54" "#1B1D1E" .
                              (\x -> case x of
                                  "Tall"             ->      "^i(" ++ myBitmapsDir ++ "/tall.xbm)"
                                  "Mirror Tall"      ->      "^i(" ++ myBitmapsDir ++ "/mtall.xbm)"
                                  "Full"                      ->      "^i(" ++ myBitmapsDir ++ "/full.xbm)"
                                  "Simple Float"              ->      "~"
                                  _                           ->      x
                              )
    , ppTitle             =  (" " ++) . dzenColor "white" "#1B1D1E" . dzenEscape . shorten 20
    , ppOutput            =   hPutStrLn h
    }
