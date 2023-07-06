; This file is a modified version of Legacy Update installer one (by kirb)
; Product
!define NAME               "Restore Windows Update"
!define DOMAIN             "google.com"

; Version
!define VERSION            "1.0.0.0"

; Main URLs
!define WEBSITE            "http://legacyupdate.net/"
!define UPDATE_URL         "http://legacyupdate.net/windowsupdate/v6/"
!define UPDATE_URL_HTTPS   "https://legacyupdate.net/windowsupdate/v6/"
!define WSUS_SERVER        "http://legacyupdate.net/v6"
!define WSUS_SERVER_HTTPS  "https://legacyupdate.net/v6"
!define TRUSTEDR           "http://download.windowsupdate.com/msdownload/update/v3/static/trustedr/en"
!define WIN81UPGRADE_URL   "https://go.microsoft.com/fwlink/?LinkId=798437"

; RunOnce
!define RUNONCE_USERNAME   "RestoreWindowsUpdateTemp"
!define RUNONCE_PASSWORD   "RestWin_Update0"

; Registry keys
!define REGPATH_RESTOREWINDOWSUPDATE_SETUP "Software\ItCoder\Restore Windows Update\Setup"
!define REGPATH_UNINSTSUBKEY       "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define REGPATH_WUPOLICY           "Software\Policies\Microsoft\Windows\WindowsUpdate"
!define REGPATH_WUAUPOLICY         "${REGPATH_WUPOLICY}\AU"
!define REGPATH_WU                 "Software\Microsoft\Windows\CurrentVersion\WindowsUpdate"
!define REGPATH_INETSETTINGS       "Software\Microsoft\Windows\CurrentVersion\Internet Settings"
!define REGPATH_ZONEDOMAINS        "${REGPATH_INETSETTINGS}\ZoneMap\Domains"
!define REGPATH_ZONEESCDOMAINS     "${REGPATH_INETSETTINGS}\ZoneMap\EscDomains"
!define REGPATH_WINLOGON           "Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
!define REGPATH_SCHANNEL_PROTOCOLS "System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols"
!define REGPATH_RUNONCE            "Software\Microsoft\Windows\CurrentVersion\RunOnce"
!define REGPATH_PACKAGEINDEX       "Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackageIndex"
!define REGPATH_SERVICING_SHA2     "Software\Microsoft\Windows\CurrentVersion\Servicing\Codesigning\SHA2"
!define REGPATH_COMPONENT_THEMES   "Software\Microsoft\Active Setup\Installed Components\{2C7339CF-2B09-4501-B3F3-F3508C9228ED}"

; Win32 constants
!define EWX_REBOOT       0x02
!define EWX_FORCE        0x04

!define TDCBF_YES_BUTTON 0x2
!define TDCBF_NO_BUTTON  0x4

!define TD_WARNING_ICON  65535

!define IDYES            6

!define PF_XMMI64_INSTRUCTIONS_AVAILABLE    10

!define ES_CONTINUOUS      0x80000000
!define ES_SYSTEM_REQUIRED 0x00000001

; WinHTTP constants
!define WINHTTP_FLAG_SECURE_PROTOCOL_TLS1   0x00000080
!define WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_1 0x00000200
!define WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2 0x00000800

!define ERROR_INTERNET_OPERATION_CANCELLED  12017

; Windows Update constants
!define WU_S_ALREADY_INSTALLED 2359302     ; 0x00240006
!define WU_E_NOT_APPLICABLE    -2145124329 ; 0x80240017
