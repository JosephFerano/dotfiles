
; This AutoHotkey script is to Open, Restore or Minimize the desires Apps using the configured shortcuts key (hotkeys) you want.
; There are three functions you can use for this: 
;
;
; a) OpenOrShowAppBasedOnExeName(AppAddress) //Useful for regular Window Apps

; b) OpenOrShowAppBasedOnWindowTitle(WindowTitleWord, AppAddress)  //Specially useful for Chrome Apps and Chrome Shortcuts 

; c) OpenOrShowAppBasedOnAppModelUserID(AppTitle, AppModelUserID) //Useful for Windows Store Apps (contained in the "shell:AppsFolder\")


; Additionally, pressing Alt + ` (key above Tab key) you can switch between open Windows of the same "type" and same App (.exe)
; The "type" checking is based on the App's Title convention that stipulates that the App name should be at the end of the Window title (Eg: New Document - Word )


/* ;
 *****************************
 ***** UTILITY FUNCTIONS *****
 *****************************
 */

CycleCurrentWindowOfSameApp()
{
    WinGet, ActiveProcess, ProcessName, A
        WinGet, OpenWindowsAmount, Count, ahk_exe %ActiveProcess%

        If OpenWindowsAmount = 1  ; If only one Window exist, do nothing
        Return

        Else
        {
            WinGetTitle, FullTitle, A
                AppTitle := ExtractAppTitle(FullTitle)

                SetTitleMatchMode, 2
                WinGet, WindowsWithSameTitleList, List, %AppTitle%

                If WindowsWithSameTitleList > 1 ; If several Window of same type (title checking) exist
                {
                    WinActivate, % "ahk_id " WindowsWithSameTitleList%WindowsWithSameTitleList%	; Activate next Window
                }
        }
    Return
}

#WinActivateForce ; Prevent task bar buttons from flashing when different windows are activated quickly one after the other.



; AppAddress: The address to the .exe (Eg: "C:\Windows\System32\SnippingTool.exe")

OpenOrShowAppBasedOnExeName(AppAddress)
{
AppExeName := SubStr(AppAddress, InStr(AppAddress, "\", false, -1) + 1)

    IfWinExist ahk_exe %AppExeName%
    {

        IfWinActive
        {
            CycleCurrentWindowOfSameApp()
                Return
        }
        else
        {
            WinActivate
                Return
        }

    }
    else
    {	
        Run, %AppAddress%, UseErrorLevel
            If ErrorLevel
            {
                Msgbox, File %AppAddress% Not Found
                    Return
            }
        else
        {
            WinWait, ahk_exe %AppExeName%
                WinActivate ahk_exe %AppExeName%			
                Return
        }			

    }
}


; WindowTitleWord: Usually the word at the end of the app window title (Eg: in: "New Document - Word" will be "Word")
; AppAddress: The address to the .exe (Eg: "C:\Windows\System32\SnippingTool.exe")

OpenOrShowAppBasedOnWindowTitle(WindowTitleWord)
{

    SetTitleMatchMode, 2
        IfWinExist, %WindowTitleWord%
        {    

            IfWinActive
            {
                ;			CycleCurrentWindowOfSameApp()
                    Return
            }
            else
            {
                WinActivate
                    Return
            }

        }
}



; AppTitle: Usually the word at the end of the app window title(Eg: in: "New Document - Word" will be "Word")
; AppModelUserID: A comprehensive guide on how to find the AppModelUserID of a windows store app can be found here: https://jcutrer.com/windows/find-aumid

OpenOrShowAppBasedOnAppModelUserID(AppTitle, AppModelUserID)
{

    SetTitleMatchMode, 2

        IfWinExist, %AppTitle%
        {    

            IfWinActive
            {
                Return
            }
            else
            {
                WinActivateBottom %AppTitle%
            }

        }
    else
    {

        Run, shell:AppsFolder\%AppModelUserID%, UseErrorLevel
            If ErrorLevel
            {
                Msgbox, File %AppModelUserID% Not Found
                    Return
            }

    }
}


ExtractAppTitle(FullTitle)
{
AppTitle := SubStr(FullTitle, InStr(FullTitle, " ", false, -1) + 1)
              Return AppTitle
}

#k::
WinSet, Style, -0x800000, A
return
;
#+k::
WinSet, Style, +0x800000, A
return
;


/* ;
 ***********************************
 ***** SHORTCUTS CONFIGURATION *****
 ***********************************
 */
; F7 - Open||Show "SnippingTool"
F7:: OpenOrShowAppBasedOnExeName("C:\Windows\System32\SnippingTool.exe")

; Terminal
#1:: OpenOrShowAppBasedOnExeName("C:\tools\alacritty\alacritty.exe")
; Firefox
#2:: OpenOrShowAppBasedOnExeName("C:\Program Files (x86)\Mozilla Firefox\firefox.exe")
; Slack (now Teams)
#s:: OpenOrShowAppBasedOnExeName("C:\Users\josep\AppData\Local\Microsoft\Teams\current\Teams.exe")
; Youtube Music
#m:: OpenOrShowAppBasedOnExeName("C:\Users\josep\AppData\Local\Programs\youtube-music-desktop-app\YouTube Music Desktop App.exe")
; Rider
#3:: OpenOrShowAppBasedOnExeName("C:\Program Files\JetBrains\JetBrains Rider 2019.3.4\bin\rider64.exe")
; Whatsapp
#w:: OpenOrShowAppBasedOnWindowTitle("WhatsApp")
; Mail
#t:: OpenOrShowAppBasedOnWindowTitle("Thunderbird")
; Discord
#d:: OpenOrShowAppBasedOnWindowTitle("Discord")

#+d::WinMinimizeAll

; Alt + ` -  Activate NEXT Window of same type (title checking) of the current APP
#`::CycleCurrentWindowOfSameApp()
#q::Send !{F4}

F5::Send {Volume_Down 2}
F6::Send {Volume_Up 2}
F3::Send {Volume_Mute}

>!n::Send  { Asc 164  }
>!a::Send  { Asc 160  }
>!e::Send  { Asc 130  }
>!i::Send  { Asc 161  }
>!o::Send  { Asc 162  }
>!u::Send  { Asc 163  }
>!+n::Send { Asc 165  }
>!+a::Send { Asc 0193 }
>!+e::Send { Asc 144  }
>!+i::Send { Asc 0205 }
>!+o::Send { Asc 0211 }
>!+u::Send { Asc 0218 }

>!h::Send  { Left  }
>!j::Send  { Down  }
>!k::Send  { Up    }
>!l::Send  { Right }


#+r::
Reload
TrayTip, AutoHotKey, Config Reloaded, 2, 48
return
;

*RAlt::
Send {Blind}{RAlt Down}
rAltDown := A_TickCount
Return

*RAlt up::
If ((A_TickCount-rAltDown)<200)  ; Modify press time as needed (milliseconds)
Send {Blind}{RAlt Up}{Esc}
Else
Send {Blind}{RAlt Up}
Return

