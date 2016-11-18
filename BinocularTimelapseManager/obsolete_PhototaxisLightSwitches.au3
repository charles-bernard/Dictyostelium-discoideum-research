#include <FileConstants.au3>
;Unfortunately, I think it is impossible to pass variables
;from autoit to arduino
;Thus, if one wants to test different brightness of light sources
;please, modify the according arduino scripts

;Initiate Script
Main()

Func Main()
   Local const $nbPositions = 2
   ;Set the number of White Leds to be switched during the experiment
   ;So far, nbPositions must be <= 3 since there are only 3 white leds on the Arduino

   Local $switchPosition = 0
   ;The switchPosition determines which white led is currently turned on

   Local const $dark = False
   ;Boolean to test weither or not the slugs keep the memory of their direction
   ;when the light is turned off

   Local const $pictureTime = 10
   ;The pictureTime (in min) determines the intervall of time that separates two pictures

   Local const $lightTime = 120
   ;The switchTime (in min) determines the amount of time recquired
   ;to switch from one white led to one another

   Local const $firstLightTime = lightTime
   ;This variable determines the first switch Time. It should be longer than the usual one
   ;in order to let the slugs find a way out the inoculation site

   Local const $darkTime = 60 * 6
   ;The darkTime (in min) determines the amount of time for which the slugs are in the dark
   ;Only relevant if $dark = True

   Local $switchTime = $firstLightTime
   ;Please, Make sure that $pictureTime < $lightTime && $pictureTime < $darkTime

   Local $currentMin = 0

   Local $outputFile = "C:\Documents and Settings\sand\Mes documents\phototaxisProcedure.txt"
   FileDelete($outputFile)
   FileWriteLine($outputFile, @MDAY & "." & @MON & "." & @YEAR & @CRLF)
   FileWriteLine($outputFile, @CRLF)
   Filewrite($outputFile, "PHOTOTAXIS PROCEDURE:" & @CRLF)
   FileWriteLine($outputFile, "Picture every " & $pictureTime & " min" & @CRLF)
   FileWriteLine($outputFile, "Number of led(s) = " & $nbPositions & @CRLF)
   FileWriteLine($outputFile, "Led period = " & $lightTime & " min" & @CRLF)
   FileWriteLine($outputFile, "Dark = " & $dark & @CRLF)
   If $dark = True Then
	  FileWriteLine($outputFile, "Dark period = " & $darkTime & " min" & @CRLF)
   EndIf
   FileWriteLine($outputFile, @CRLF)
   FileWriteLine($outputFile, "LEGEND:" & @CRLF)
   FileWriteLine($outputFile, "Switch Position 0: No light" & @CRLF)
   FileWriteLine($outputFile, "Switch Position 1: Analogic White Led on Arduino port 3  (East)" & @CRLF)
   FileWriteLine($outputFile, "Switch Position 2: Analogic White Led on Arduino port 11 (South)" & @CRLF)
   FileWriteLine($outputFile, "Switch Position 3: Digital  White Led on Arduino port 2  (North)"& @CRLF)
   FileWriteLine($outputFile, @CRLF)
   FileWriteLine($outputFile, "__________________________________________________________________" & @CRLF)
   FileWriteLine($outputFile, "HH:MM:SS" & @TAB & "|minCounter" & @TAB & "|Switch Position" & @TAB & "|Snapshot" & @CRLF)

   While 1
   ;The Program runs until the user exits it manually
	  If mod($currentMin, $switchTime) <> 0 AND mod($currentMin, $pictureTime) <> 0 Then
	  	 Sleep(59900)
	  Else
		 If mod($currentMin, $switchTime) = 0 Then
			If $switchPosition = 0 Then
			   $switchPosition += 1
			   If $currentMin = 0 Then
				  $switchTime = $currentMin + $firstLightTime
			   Else
				  $switchTime = $currentMin + $lightTime
			   EndIf
			ElseIf $switchPosition < $nbPositions Then
			   $switchPosition += 1
			   $switchTime = $currentMin + $lightTime
			Else
			   Switch $dark
				  case True
					 $switchPosition = 0
					 $switchTime = $currentMin + $darkTime
				  case False
					 $switchPosition = 1
					 $switchTime = $currentMin + $lightTime
			   EndSwitch
			Endif
			If mod($currentMin, $pictureTime) <> 0 Then
			   controlLeds($switchPosition, "experiment")
			   Sleep(59900)
			   FileWriteLine($outputFile, @HOUR & ":" & @MIN & ":" & @SEC & @TAB & "|" & $currentMin & @TAB & @TAB & "|" & $switchPosition & @TAB & @TAB & @TAB & "|No" & @CRLF)
			EndIf
		 EndIf

		 If mod($currentMin, $pictureTime) = 0 Then
			ShellExecute("C:\Program Files\Snappixx\Snappixx")
			Sleep(11000)

			controlLeds($switchPosition, "picture")
			Sleep(2000)

			WinActivate("Snappixx")
			ControlClick("Snappixx","&Connect",30)
			Sleep(8000)

			controlLeds($switchPosition, "experiment")

			WinActivate("Snappixx")
			ControlCommand("Snappixx","",1,"ShowDropDown")
			ControlCommand("Snappixx","",1,"SelectString",'4 sec')
			ControlClick("Snappixx","&Snap",28)
			Sleep(18000)

			WinActivate("Snappixx")
			ControlClick("Snappixx","Disconnect",29)
			Sleep(3000)

			WinActivate("Snappixx")
			WinClose("Snappixx")
			Sleep(17500)
			;16000

			FileWriteLine($outputFile, @HOUR & ":" & @MIN & ":" & @SEC & @TAB & "|" & $currentMin & @TAB & @TAB & "|" & $switchPosition & @TAB & @TAB & @TAB & "|Yes" & @CRLF)
		 EndIf
	  EndIf
	  $currentMin += 1
   WEnd
EndFunc

Func controlLeds(ByRef $switchPosition, ByRef $condition)
   Switch $condition
	  case "experiment"
	  ;When one runs a new arduino script, the previous one closes
	  ;This way, the red leds are turned off when the white led script starts to run
		 Switch $switchPosition
			case 0
			   all_off()
			case 1
			   white1()
			case 2
			   white2()
			case 3
			   white3()
			   ;Be aware that this led is digital
			   ;You can set its brightness manually with the potentiometer on the arduino
		 EndSwitch
	  case "picture"
	  ;In order to take the picture, all the red leds are turned on
	  ;while the intensity of the current white led is lowered from 50 to 10 (excepting the digital one)
		 Switch $switchPosition
			case 0
			   allRed()
			case 1
			   allRed_white1()
			case 2
			   allRed_white2()
			case 3
			   allRed_white3()
		 EndSwitch
   Endswitch
EndFunc

;These following functions launch the according arduino scripts
Func white1()
	ShellExecute("C:\Program Files\Arduino\arduino", "--board arduino:avr:uno --port COM3 --upload ""C:\Documents and Settings\sand\Mes documents\Arduino\SWITCH_SCRIPTS\WHITE1\WHITE1.ino""")
EndFunc
Func white2()
	ShellExecute("C:\Program Files\Arduino\arduino", "--board arduino:avr:uno --port COM3 --upload ""C:\Documents and Settings\sand\Mes documents\Arduino\SWITCH_SCRIPTS\WHITE2\WHITE2.ino""")
EndFunc
Func white3()
	ShellExecute("C:\Program Files\Arduino\arduino", "--board arduino:avr:uno --port COM3 --upload ""C:\Documents and Settings\sand\Mes documents\Arduino\SWITCH_SCRIPTS\WHITE3\WHITE3.ino""")
EndFunc
Func allRed_white1()
	ShellExecute("C:\Program Files\Arduino\arduino", "--board arduino:avr:uno --port COM3 --upload ""C:\Documents and Settings\sand\Mes documents\Arduino\SWITCH_SCRIPTS\ALLRED_WHITE1\ALLRED_WHITE1.ino""")
EndFunc
Func allRed_white2()
	ShellExecute("C:\Program Files\Arduino\arduino", "--board arduino:avr:uno --port COM3 --upload ""C:\Documents and Settings\sand\Mes documents\Arduino\SWITCH_SCRIPTS\ALLRED_WHITE2\ALLRED_WHITE2.ino""")
EndFunc
Func allRed_white3()
	ShellExecute("C:\Program Files\Arduino\arduino", "--board arduino:avr:uno --port COM3 --upload ""C:\Documents and Settings\sand\Mes documents\Arduino\SWITCH_SCRIPTS\ALLRED_WHITE3\ALLRED_WHITE3.ino""")
EndFunc
Func allRed()
	ShellExecute("C:\Program Files\Arduino\arduino", "--board arduino:avr:uno --port COM3 --upload ""C:\Documents and Settings\sand\Mes documents\Arduino\SWITCH_SCRIPTS\ALLRED\ALLRED.ino""")
EndFunc
Func all_off()
	ShellExecute("C:\Program Files\Arduino\arduino", "--board arduino:avr:uno --port COM3 --upload ""C:\Documents and Settings\sand\Mes documents\Arduino\SWITCH_SCRIPTS\ALL_OFF\ALL_OFF.ino""")
EndFunc