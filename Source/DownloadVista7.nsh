; This file is a modified version of Legacy Update installer one (by kirb)

Function GetComponentArch
	${If} ${IsNativeIA32}
		Push "x86"
	${ElseIf} ${IsNativeAMD64}
		Push "amd64"
	${ElseIf} ${IsNativeIA64}
		Push "ia64"
	${Else}
		Push ""
	${EndIf}
FunctionEnd

!macro SPHandler kbid title os sp
	!insertmacro NeedsSPHandler "${kbid}" "${os}" "${sp}"

	Function Download${kbid}
		Call Needs${kbid}
		Pop $0
		${If} $0 == 1
			Call GetArch
			Pop $0
			ReadINIStr $0 $PLUGINSDIR\Patches.ini "${kbid}" $0
			!insertmacro DownloadAndInstallSP "${title}" "$0" "${kbid}"
		${EndIf}
	FunctionEnd
!macroend

!macro MSUHandler kbid title packagename
	Function Needs${kbid}
		Call GetComponentArch
		Pop $0
		ClearErrors
		ReadRegStr $1 HKLM "${REGPATH_PACKAGEINDEX}\${packagename}~31bf3856ad364e35~$0~~0.0.0.0" ""
		${If} ${Errors}
			Push 1
		${Else}
			Push 0
		${EndIf}
	FunctionEnd

	Function Download${kbid}
		Call Needs${kbid}
		Pop $0
		${If} $0 == 1
			Call GetArch
			Pop $0
			ReadINIStr $1 $PLUGINSDIR\Patches.ini "${kbid}" $0
			!insertmacro DownloadAndInstallMSU "${kbid}" "${title}" "$1"
		${EndIf}
	FunctionEnd
!macroend

; Windows Vista post-SP2 update combination that fixes WU indefinitely checking for updates
!insertmacro MSUHandler "KB3205638" "Security Update for Windows Vista"                      "Package_for_KB3205638"
!insertmacro MSUHandler "KB4012583" "Security Update for Windows Vista"                      "Package_for_KB4012583"
!insertmacro MSUHandler "KB4015195" "Security Update for Windows Vista"                      "Package_for_KB4015195"
!insertmacro MSUHandler "KB4015380" "Security Update for Windows Vista"                      "Package_for_KB4015380"

Function NeedsVistaPostSP2
	Call NeedsKB3205638
	Call NeedsKB4012583
	Call NeedsKB4015195
	Call NeedsKB4015380
	Pop $0
	Pop $1
	Pop $2
	Pop $3
	${If} $0 == 1
	${OrIf} $1 == 1
	${OrIf} $2 == 1
	${OrIf} $3 == 1
		Push 1
	${Else}
		Push 0
	${EndIf}
FunctionEnd
