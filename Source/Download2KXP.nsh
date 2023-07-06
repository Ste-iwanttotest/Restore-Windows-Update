; This file is a modified version of Legacy Update installer one (by kirb)

Function GetUpdateLanguage
	ReadRegStr $0 HKLM "Hardware\Description\System" "Identifier"
	${If} $0 == "NEC PC-98"
		Push "NEC98"
	${Else}
		ReadRegStr $0 HKLM "System\CurrentControlSet\Control\Nls\Language" "InstallLanguage"
		ReadINIStr $0 $PLUGINSDIR\Patches.ini Language $0
		Push $0
	${EndIf}
FunctionEnd

!macro NeedsSPHandler name os sp
	Function Needs${name}
		${If} ${Is${os}}
		${AndIf} ${AtMostServicePack} ${sp}
			Push 1
		${Else}
			Push 0
		${EndIf}
	FunctionEnd
!macroend

!macro NeedsFileVersionHandler name file version
	Function Needs${name}
		${GetFileVersion} "$SYSDIR\${file}" $0
		${VersionCompare} $0 ${version} $1
		${If} $1 == 2 ; Less than
			Push 1
		${Else}
			Push 0
		${EndIf}
	FunctionEnd
!macroend

!macro PatchHandler kbid title params
	Function Download${kbid}
		Call Needs${kbid}
		Pop $0
		${If} $0 == 1
			Call GetUpdateLanguage
			Call GetArch
			Pop $1
			Pop $0
			ReadINIStr $0 $PLUGINSDIR\Patches.ini "${kbid}" $0-$1
			!insertmacro DownloadAndInstall "${title}" "$0" "${kbid}.exe" "${params}"
		${EndIf}
	FunctionEnd
!macroend

!insertmacro NeedsSPHandler "W2KSP4"  "Win2000"   2

!insertmacro NeedsFileVersionHandler "IE6"      "mshtml.dll"   "6.0.2600.0"
!insertmacro NeedsFileVersionHandler "MSXML"		"winhttp5.dll"	"5.0.2613.0"

!insertmacro PatchHandler "W2KSP4"   "Windows 2000 Service Pack 4"                       "-u -z"
Function InstallMSXML
	Call NeedsMSXML
	Pop $0
	${If} $0 == 1
		File "msxml4-kb954430-enu.exe"
		!insertmacro ExecWithErrorHandling 'MSXML 4.0 SP2' '"msxml4-kb954430-enu.exe"' 0
	${Endif}
FunctionEnd

Function DownloadIE6
	Call NeedsIE6
	Pop $0
	${If} $0 == 1
		Call GetUpdateLanguage
		Call GetArch
		Pop $1
		Pop $0
		ReadINIStr $0 $PLUGINSDIR\Patches.ini "W2KIE6" $0-$1
		!insertmacro DownloadIfNeeded "Internet Explorer 6 SP1" "$0" "ie6sp1.cab"
		!insertmacro DetailPrint "Extracting Internet Explorer 6 SP1..."
		ExecShellWait "" "$WINDIR\system32\expand.exe" '"$0" -F:ie6setup.exe "$PLUGINSDIR"' SW_HIDE
		ExecShellWait "" "$WINDIR\system32\expand.exe" '"$0" -F:iebatch.txt "$PLUGINSDIR"' SW_HIDE
		!insertmacro DetailPrint "Installing Internet Explorer 6 SP1..."
		!insertmacro ExecWithErrorHandling 'Internet Explorer 6 SP1' '"$PLUGINSDIR\ie6setup.exe" /q' 0
	${EndIf}
FunctionEnd
