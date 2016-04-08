REM Volume Shadow Copy Management from CLI.
REM Part of the presentation "Lurking in the Shadows" by Mark Baggett and Tim "LaNMaSteR53" Tomes.
REM Co-developed by Mark Baggett (@MarkBaggett) and Tim Tomes (@lanmaster53).

Set args = WScript.Arguments

if args.Count < 1  Then
  wscript.Echo "Usage: cscript vssown.vbs [option]"
  wscript.Echo
  wscript.Echo "  Options:"
  wscript.Echo
  wscript.Echo "  /list                             - List current volume shadow copies."
  wscript.Echo "  /start                            - Start the shadow copy service."
  wscript.Echo "  /stop                             - Halt the shadow copy service."
  wscript.Echo "  /status                           - Show status of shadow copy service."
  wscript.Echo "  /mode                             - Display the shadow copy service start mode."
  wscript.Echo "  /mode [Manual|Automatic|Disabled] - Change the shadow copy service start mode."
  wscript.Echo "  /create [drive_letter]            - Create a shadow copy."
  wscript.Echo "  /delete [id|*]                    - Delete a specified or all shadow copies."
  wscript.Echo "  /mount [path] [device_object]     - Mount a shadow copy to the given path."
  wscript.Echo "  /execute [\path\to\file]          - Launch executable from within an umounted shadow copy."
  wscript.Echo "  /store                            - Display storage statistics."
  wscript.Echo "  /size [bytes]                     - Set drive space reserved for shadow copies."
  REM build_off
  wscript.Echo "  /build [filename]                 - Print pasteable script to stdout."REM no_build
  REM build_on
  wscript.Quit(0)
End If

strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Select Case args.Item(0)

  Case "/list"
    Wscript.Echo "SHADOW COPIES"
    Wscript.Echo "============="
    Wscript.Echo
    Set colItems = objWMIService.ExecQuery("Select * from Win32_ShadowCopy")
    For Each objItem in colItems
      Wscript.Echo "[*] ID:                  " & objItem.ID
      Wscript.Echo "[*] Client accessible:   " & objItem.ClientAccessible
      Wscript.Echo "[*] Count:               " & objItem.Count
      Wscript.Echo "[*] Device object:       " & objItem.DeviceObject
      Wscript.Echo "[*] Differential:        " & objItem.Differential
      Wscript.Echo "[*] Exposed locally:     " & objItem.ExposedLocally
      Wscript.Echo "[*] Exposed name:        " & objItem.ExposedName
      Wscript.Echo "[*] Exposed remotely:    " & objItem.ExposedRemotely
      Wscript.Echo "[*] Hardware assisted:   " & objItem.HardwareAssisted
      Wscript.Echo "[*] Imported:            " & objItem.Imported
      Wscript.Echo "[*] No auto release:     " & objItem.NoAutoRelease
      Wscript.Echo "[*] Not surfaced:        " & objItem.NotSurfaced
      Wscript.Echo "[*] No writers:          " & objItem.NoWriters
      Wscript.Echo "[*] Originating machine: " & objItem.OriginatingMachine
      Wscript.Echo "[*] Persistent:          " & objItem.Persistent
      Wscript.Echo "[*] Plex:                " & objItem.Plex
      Wscript.Echo "[*] Provider ID:         " & objItem.ProviderID
      Wscript.Echo "[*] Service machine:     " & objItem.ServiceMachine
      Wscript.Echo "[*] Set ID:              " & objItem.SetID
      Wscript.Echo "[*] State:               " & objItem.State
      Wscript.Echo "[*] Transportable:       " & objItem.Transportable
      Wscript.Echo "[*] Volume name:         " & objItem.VolumeName
      Wscript.Echo
    Next
    wscript.Quit(0)

  Case "/start"
    Set colListOfServices = objWMIService.ExecQuery("Select * from Win32_Service Where Name ='VSS'")
    For Each objService in colListOfServices
      objService.StartService()
      Wscript.Echo "[*] Signal sent to start the " & objService.Name & " service."
    Next
    wscript.Quit(0)

  Case "/stop"
    Set colListOfServices = objWMIService.ExecQuery("Select * from Win32_Service Where Name ='VSS'")
    For Each objService in colListOfServices
      objService.StopService()
      Wscript.Echo "[*] Signal sent to stop the " & objService.Name & " service."
    Next
    wscript.Quit(0)

  Case "/status"
    Set colListOfServices = objWMIService.ExecQuery("Select * from Win32_Service Where Name ='VSS'")
    For Each objService in colListOfServices
      Wscript.Echo "[*] " & objService.State
    Next
    wscript.Quit(0)

  Case "/mode"
    Set colListOfServices = objWMIService.ExecQuery("Select * from Win32_Service Where Name ='VSS'")
    For Each objService in colListOfServices
      if args.Count < 2 Then
        Wscript.Echo "[*] " & objService.Name & " service set to '" & objService.StartMode & "' start mode."        
      Else
        mode = LCase(args.Item(1))
        if mode = "manual" or mode = "automatic" or mode = "disabled" Then
          errResult = objService.ChangeStartMode(mode)
          Wscript.Echo "[*] " & objService.Name & " service set to '" & mode & "' start mode."
        Else
          Wscript.Echo "[*] '" & mode & "' is not a valid start mode."
        End If
      END If
    Next
    wscript.Quit(errResult)    

  Case "/create"
    VOLUME = args.Item(1) & ":\"
    Const CONTEXT = "ClientAccessible"
    Set objShadowStorage = objWMIService.Get("Win32_ShadowCopy")
    Wscript.Echo "[*] Attempting to create a shadow copy."
    errResult = objShadowStorage.Create(VOLUME, CONTEXT, strShadowID)
    wscript.Quit(errResult)

  Case "/delete"
    id = args.Item(1)
    Set colItems = objWMIService.ExecQuery("Select * From Win32_ShadowCopy")
    For Each objItem in colItems
      if objItem.ID = id Then
        Wscript.Echo "[*] Attempting to delete shadow copy with ID: " & id
        errResult = objItem.Delete_
      ElseIf id = "*" Then
        Wscript.Echo "[*] Attempting to delete shadow copy " & objItem.DeviceObject & "."
        errResult = objItem.Delete_
      End If
    Next
    wscript.Quit(errResult)

  Case "/mount"
    Set WshShell = WScript.CreateObject("WScript.Shell")
    link = args.Item(1)
    sc = args.Item(2) & "\"
    cmd = "cmd /C mklink /D " & link & " " & sc
    WshShell.Run cmd, 2, true
    Wscript.Echo "[*] " & sc & " has been mounted to " & link & "."
    wscript.Quit(0)

  Case "/execute"
    file = args.Item(1)
    Set colItems = objWMIService.ExecQuery("Select * From Win32_ShadowCopy")
    Set objProcess = objWMIService.Get("Win32_Process")
    For Each objItem in colItems
      path = Replace(objItem.DeviceObject,"?",".") & file
      intReturn = objProcess.Create(path)
      if intReturn <> 0 Then
        wscript.Echo "[*] Process could not be created from " & path & "."
        wscript.Echo "[*] ReturnValue = " & intReturn
      Else
        wscript.Echo "[!] Process created from " & path & "."
        wscript.Quit(0)
      End If
    Next
    wscript.Quit(0)

  Case "/store"
    Wscript.Echo "SHADOW STORAGE"
    Wscript.Echo "=============="
    Wscript.Echo
    Set colItems = objWMIService.ExecQuery("Select * from Win32_ShadowStorage")
    For Each objItem in colItems
        Wscript.Echo "[*] Allocated space:     " & FormatNumber(objItem.AllocatedSpace / 1000000,0) & "MB"
        Wscript.Echo "[*] Maximum size:        " & FormatNumber(objItem.MaxSpace / 1000000,0) & "MB"
        Wscript.Echo "[*] Used space:          " & FormatNumber(objItem.UsedSpace / 1000000,0) & "MB"
        Wscript.Echo
    Next
    wscript.Quit(0)

  Case "/size"
    storagesize = CDbl(args.Item(1))
    Set colItems = objWMIService.ExecQuery("Select * from Win32_ShadowStorage")
    For Each objItem in colItems
      objItem.MaxSpace = storagesize
      objItem.Put_
    Next
    Wscript.Echo "[*] Shadow storage space has been set to " & FormatNumber(storagesize / 1000000,0) & "MB."
    wscript.Quit(0)

  REM build_off
  Case "/build"
    build = 1
    Const ForReading = 1
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objTextFile = objFSO.OpenTextFile("vssown.vbs", ForReading)
    Do Until objTextFile.AtEndOfStream
      strNextLine = objTextFile.Readline
      if InStr(strNextLine,"REM build_off") = 3 Then
        build = 0
      End If
      if strNextLine <> "" and build = 1 Then
        strNextLine = Replace(strNextLine,"&","^&")
        strNextLine = Replace(strNextLine,">","^>")
        strNextLine = Replace(strNextLine,"<","^<")
        wscript.Echo "echo " & strNextLine & " >> " & args.Item(1)
      End If
      if InStr(strNextLine,"REM build_on") = 3 Then
        build = 1
      End If
    Loop
    wscript.Quit(0)
  REM build_on

End Select
