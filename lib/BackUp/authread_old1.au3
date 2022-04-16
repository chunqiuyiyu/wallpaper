#cs ----------------------------------------------------------------------------
 AuThread
 written by Jefrey <jefrey[at]jefrey.ml>
#ce ----------------------------------------------------------------------------

Global Const $__AuThread_sTmpFile = @TempDir & "\" & @ScriptName & "_thread.tmp"

Func _AuThread_Startup()
  ; was this process called for a thread?
  If $CmdLine[0] = 2 And $CmdLine[1] = "--au-thread" Then
    AdlibRegister("__AuThread_Checkloop")
    Call($CmdLine[2])
    Exit
  Else
    ; it's the main thread
    OnAutoItExitRegister("__AuThread_OnExit")
    FileDelete($__AuThread_sTmpFile)
    IniWrite($__AuThread_sTmpFile, "main", "pid", @AutoItPID)
  EndIf
EndFunc

Func _AuThread_MainThread()
  Local $sRet = IniRead($__AuThread_sTmpFile, "main", "pid", False)
  If $sRet = "False" Then $sRet = False
  Return $sRet
EndFunc

Func _AuThread_StartThread($sCallback, $sMsg = Default)
  Local $iPID
  If @Compiled Then
    $iPID = Run(@ScriptFullPath & " --au-thread """ & $sCallback & """")
  Else
    $iPID = Run(@AutoItExe & ' "' & @ScriptFullPath & '" --au-thread "' & $sCallback & '"')
  EndIf
  If $sMsg <> Default Then _AuThread_SendMessage($iPID, $sMsg)
  Return $iPID
EndFunc

Func _AuThread_GetMessage()
  Local $sMsg = IniRead($__AuThread_sTmpFile, "msg", @AutoItPID, False)
  If $sMsg <> "False" Then
    IniDelete($__AuThread_sTmpFile, "msg", @AutoItPID)
    Return $sMsg
  Else
    Return False
  EndIf
EndFunc

Func _AuThread_SendMessage($iPid, $sMessage)
  Return IniWrite($__AuThread_sTmpFile, "msg", $iPid, $sMessage)
EndFunc

Func _AuThread_CloseThread($iPid)
  Return ProcessClose($iPid)
EndFunc

; ============= internal use only ============

Func __AuThread_Checkloop()
  ; check if main thread was closed (if so, close this one too)
  $iMainThreadPID = IniRead($__AuThread_sTmpFile, "main", "pid", False)
  If Not ProcessExists($iMainThreadPID) Then
    FileDelete($__AuThread_sTmpFile)
    Exit
  EndIf
EndFunc

Func __AuThread_OnExit()
  FileDelete($__AuThread_sTmpFile)
EndFunc