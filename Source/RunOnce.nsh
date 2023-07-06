; This file is a modified version of Legacy Update installer one (by kirb)

!define IsRunOnce     `"" HasFlag "/runonce"`
!define IsPostInstall `"" HasFlag "/postinstall"`
!define NoRestart     `"" HasFlag "/norestart"`

!macro -PromptReboot
	SetErrorLevel ${ERROR_SUCCESS_REBOOT_REQUIRED}

	${If} ${NoRestart}
		; Prompt for reboot
		${IfNot} ${Silent}
			System::Call 'shell32::RestartDialog(p 0, \
				t "Windows will be restarted to complete installation of prerequisite components. Setup will resume after the restart.", \
				i ${EWX_REBOOT})'
		${EndIf}
	${Else}
		; Reboot immediately
		Reboot
	${EndIf}
!macroend

!macro -RegisterRunOnce flags
	WriteRegStr HKLM "${REGPATH_RUNONCE}" "RestoreWindowsUpdate" '"$INSTDIR\RestoreWindowsUpdate.exe" ${flags}'
!macroend

Function RegisterRunOnce
	!insertmacro -RegisterRunOnce "/runonce"
FunctionEnd

Function un.RegisterRunOnce
	; Unused, just needs to exist to make the compiler happy
FunctionEnd

Function RegisterRunOncePostInstall
	!insertmacro -RegisterRunOnce "/postinstall"
FunctionEnd

!macro -WriteRegStrWithBackup root key name value
	; Backup the key if it exists
	ClearErrors
	ReadRegStr $0 ${root} "${key}" "${name}"
	${IfNot} ${Errors}
		WriteRegStr ${root} "${key}" "RestoreWindowsUpdate_${name}" $0
	${EndIf}

	WriteRegStr ${root} "${key}" "${name}" "${value}"
!macroend

!macro -RestoreRegStr root key name
	; Restore the key if it exists
	ClearErrors
	ReadRegStr $0 ${root} "${key}" "RestoreWindowsUpdate_${name}"
	${If} ${Errors}
		DeleteRegValue ${root} "${key}" "${name}"
	${Else}
		WriteRegStr ${root} "${key}" "${name}" $0
		DeleteRegValue ${root} "${key}" "RestoreWindowsUpdate_${name}"
	${EndIf}
!macroend

!macro -RebootIfRequired un
	${If} ${RebootFlag}
		${IfNot} ${IsRunOnce}
		${AndIfNot} ${NoRestart}
			!insertmacro DetailPrint "Preparing to restart..."

			; Copy to a local path, just in case the installer is on a network share
			CreateDirectory "$INSTDIR"
			CopyFiles /SILENT "$EXEPATH" "$INSTDIR\RestoreWindowsUpdate.exe"
		${EndIf}

		Call ${un}RegisterRunOnce
		!insertmacro -PromptReboot
		Quit
	${EndIf}
!macroend

Function RebootIfRequired
	!insertmacro -RebootIfRequired ""
FunctionEnd

Function un.RebootIfRequired
	!insertmacro -RebootIfRequired "un."
FunctionEnd

Function OnRunOnceLogon
	; Trick winlogon into thinking the shell has started, so it doesn't appear to be stuck at
	; "Welcome" (XP) or "Preparing your desktop..." (Vista+)
	; https://social.msdn.microsoft.com/Forums/WINDOWS/en-US/ca253e22-1ef8-4582-8710-9cd9c89b15c3
	${If} ${AtLeastWinVista}
		StrCpy $0 "ShellDesktopSwitchEvent"
	${Else}
		StrCpy $0 "msgina: ShellReadyEvent"
	${EndIf}

	System::Call 'kernel32::OpenEvent(i ${EVENT_MODIFY_STATE}, i 0, t "$0") i .r0'
	${If} $0 != 0
		System::Call 'kernel32::SetEvent(i r0)'
		System::Call 'kernel32::CloseHandle(i r0)'
	${EndIf}

	; Handle Safe Mode case. Runonce can still be processed in Safe Mode in some edge cases. If that
	; happens, just silently register runonce again and quit.
	${If} ${IsSafeMode}
		Call RegisterRunOnce
		Quit
	${EndIf}

	; Allow the themes component to be registered if necessary. This sets the theme to Aero Basic
	; rather than Classic in Vista/7.
	ClearErrors
	ReadRegStr $0 HKLM "${REGPATH_COMPONENT_THEMES}" "StubPath"
	${IfNot} ${Errors}
		ExecShellWait "" "$WINDIR\system32\cmd.exe" "/c $0" SW_HIDE
	${EndIf}
FunctionEnd

Function CleanUpRunOnce

	${If} ${IsRunOnce}
		; Clean up temporary setup exe if we created it (likely on next reboot)
		${If} ${FileExists} "$INSTDIR\RestoreWindowsUpdate.exe"
			Delete /REBOOTOK "$INSTDIR\RestoreWindowsUpdate.exe"
		${EndIf}

		; Be really really sure this is the right user before we nuke their profile and log out
	
			System::Call "user32::ExitWindowsEx(i ${EWX_FORCE} , i 0) i .r0"
	${EndIf}
FunctionEnd
