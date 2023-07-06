; This file is a modified version of Legacy Update installer one (by kirb)

Function DetermineWUAVersion
	; Hardcoded special case for XP Home SP3, because the WUA 7.6.7600.256 setup SFX is seriously
	; broken on it, potentially causing an unbootable Windows install due to it entering an infinite
	; loop of creating folders in the root of C:.
		GetWinVer $1 Major
		GetWinVer $2 Minor
		GetWinVer $3 ServicePack
		StrCpy $1 "$1.$2"

	StrCpy $0 ""

	ClearErrors
	ReadINIStr $2 $PLUGINSDIR\Patches.ini WUA $1
	${If} ${Errors}
		Return
	${EndIf}

	${GetFileVersion} "$SYSDIR\wuaueng.dll" $1
	${VersionCompare} $1 $2 $3
	${If} $3 != 0
		Call GetArch
		Pop $0
		ReadINIStr $8 $PLUGINSDIR\Patches.ini WUA $2-$0
	${EndIf}
FunctionEnd

Function DownloadWUA
	Call DetermineWUAVersion
	${If} $8 != ""
	
		GetWinVer $1 Major
		${If} $1 == 6
		${AndIf} $3 == 1
				ReadINIStr $9 $PLUGINSDIR\Patches.ini WUA $2-UN-$0
				!insertmacro DownloadAndInstall "Windows Update Agent" "$9" "WindowsUpdateAgentUninstall.exe" "/uninstall /quiet /norestart"
				Call RebootIfRequired
		${EndIf}
		!insertmacro DownloadAndInstall "Windows Update Agent" "$8" "WindowsUpdateAgent.exe" "/WUForce /quiet /norestart"
	${EndIf}
FunctionEnd
