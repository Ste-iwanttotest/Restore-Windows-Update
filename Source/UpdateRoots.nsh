; This file is a modified version of Legacy Update installer one (by kirb)

!macro -SetSecureProtocolsBitmask
	; If the value isn't yet set, ReadRegDword will return 0. This means TLSv1.1 and v1.2 will be the
	; only enabled protocols. This is intentional behavior, because SSLv2 and SSLv3 are not secure,
	; and TLSv1.0 is deprecated. The user can manually enable them in Internet Settings if needed.
	; On XP, we'll also enable TLSv1.0, given TLSv1.1 and v1.2 are only offered through an optional
	; POSReady 2009 update.
	${If} $0 == 0
		IntOp $0 $0 | ${WINHTTP_FLAG_SECURE_PROTOCOL_TLS1}
	${EndIf}
	IntOp $0 $0 | ${WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_1}
	IntOp $0 $0 | ${WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2}
!macroend

Function _ConfigureCrypto
	; Enable SChannel TLSv1.1 and v1.2
	WriteRegDword HKLM "${REGPATH_SCHANNEL_PROTOCOLS}\TLS 1.1\Client" "Enabled" 1
	WriteRegDword HKLM "${REGPATH_SCHANNEL_PROTOCOLS}\TLS 1.1\Client" "DisabledByDefault" 0
	WriteRegDword HKLM "${REGPATH_SCHANNEL_PROTOCOLS}\TLS 1.1\Server" "Enabled" 1
	WriteRegDword HKLM "${REGPATH_SCHANNEL_PROTOCOLS}\TLS 1.1\Server" "DisabledByDefault" 0
	WriteRegDword HKLM "${REGPATH_SCHANNEL_PROTOCOLS}\TLS 1.2\Client" "Enabled" 1
	WriteRegDword HKLM "${REGPATH_SCHANNEL_PROTOCOLS}\TLS 1.2\Client" "DisabledByDefault" 0
	WriteRegDword HKLM "${REGPATH_SCHANNEL_PROTOCOLS}\TLS 1.2\Server" "Enabled" 1
	WriteRegDword HKLM "${REGPATH_SCHANNEL_PROTOCOLS}\TLS 1.2\Server" "DisabledByDefault" 0

	; Enable IE TLSv1.1 and v1.2
	ReadRegDword $0 HKLM "${REGPATH_INETSETTINGS}" "SecureProtocols"
	!insertmacro -SetSecureProtocolsBitmask
	WriteRegDword HKLM "${REGPATH_INETSETTINGS}" "SecureProtocols" $0

	ReadRegDword $0 HKCU "${REGPATH_INETSETTINGS}" "SecureProtocols"
	!insertmacro -SetSecureProtocolsBitmask
	WriteRegDword HKCU "${REGPATH_INETSETTINGS}" "SecureProtocols" $0

	; Enable WinHTTP TLSv1.1 and v1.2
	ReadRegDword $0 HKLM "${REGPATH_INETSETTINGS}\WinHttp" "DefaultSecureProtocols"
	!insertmacro -SetSecureProtocolsBitmask
	WriteRegDword HKLM "${REGPATH_INETSETTINGS}\WinHttp" "DefaultSecureProtocols" $0

	ReadRegDword $0 HKCU "${REGPATH_INETSETTINGS}\WinHttp" "DefaultSecureProtocols"
	!insertmacro -SetSecureProtocolsBitmask
	WriteRegDword HKCU "${REGPATH_INETSETTINGS}\WinHttp" "DefaultSecureProtocols" $0

	; Enable .NET inheriting SChannel protocol config
	; .NET 3 uses the same registry keys as .NET 2.
	WriteRegDword HKLM "${REGPATH_DOTNET_V2}" "SystemDefaultTlsVersions" 1
	WriteRegDword HKLM "${REGPATH_DOTNET_V4}" "SystemDefaultTlsVersions" 1
FunctionEnd

Function ConfigureCrypto
	Call _ConfigureCrypto

	; Repeat in the WOW64 registry if needed
	${If} ${RunningX64}
		SetRegView 32
		Call _ConfigureCrypto
		SetRegView 64
	${EndIf}
FunctionEnd

!macro _DownloadSST name
	!insertmacro DownloadRequest "${TRUSTEDR}/${name}.sst" "${name}.sst" ""
	Pop $0
	!insertmacro DownloadWait $0 SILENT
	Pop $1
	Pop $0
	${If} $0 != "OK"
		${If} $1 != ${ERROR_INTERNET_OPERATION_CANCELLED}
			MessageBox MB_USERICON "Certificate Trust List failed to download.$\r$\n$\r$\n$0 ($1)" /SD IDOK
		${EndIf}
		SetErrorLevel 1
		Abort
	${EndIf}
!macroend

Function UpdateRoots
	File "updroots.exe"
	File "rootsupd.exe"
	File "CA.sst"
	!insertmacro DetailPrint "Updating Root Certificates..."
	!insertmacro ExecWithErrorHandling "Install Proxy" '$INSTDIR\updroots.exe -l "$INSTDIR\CA.sst"' 0
	GetWinVer $0 Major
	GetWinVer $1 Minor
	${If} $0 == 5
	${AndIf} $1 == 0
		!insertmacro ExecWithErrorHandling "Update Root Certificates" '"$INSTDIR\rootsupd.exe"' 0
	${EndIf}
FunctionEnd
