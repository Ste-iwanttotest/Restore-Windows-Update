*** This installer uses code originally written for Legacy Update installer ***

This readme is for user who want to know how this method of restoring Windows Update works.
Users who simply want to use it should read the readme outside this folder.

1. BUILDING THE INSTALLER
	To build this installer, use NSIS with setup.nsh.
	You can't build this as it is. You'll have to add some files:
	- msxml4-kb954430-enu.exe (you'll find it online)
	- msxml3.dll (extract any x86 Windows Update Agent to find it)
	- muweb.dll (you'll find it online, any version is OK)
	- rootsupd.exe (download from the Microsoft Update Catalog)
	- updroots.exe (extract from rootsupd.exe)
	- wuweb.dll (extract any x86 Windows Update Agent to find it)
	Pay attention: you need BOTH rootsupd.exe and updroots.exe, even if one contains the other. They have different usages.
	I can't include these files because they are Microsoft's.

2. INSTALLER'S BEHAVIOUR (refer to Legacy Update documentation for any unspecified behaviour
	The installer perform various tasks based on various sections. Here's a description of each of them.
	- Windows 2000 Service Pack 4
		This is shown only on Windows 2000 RTM, SP1 and SP2 and it's mandatory, because Windows Update v6 doesn't work on these systems.
		If the system has SP3, the option isn't shown (it is not necessary to upgrade).
		It basically download and install the Service Pack from Microsoft, then reboots the system.
	- Windows 2000 Patches
		This is shown on any system with Windows 2000 and it's mandatory.
		This option installs MSXML 4.0 SP2 (required to run proxycfg), copies winhttp.dll as winhttp5.dll in system32 (to avoid a bug in proxycfg), run rootsupd.exe (Windows Update requires updated root certificates, Windows 2000 default don't work) and copies msxml3.dll in system32 (to avoid a bug installing the Agent)
		Although it is always shown on Windows 2000, this option only does what's needed (some thinghs, which are immediate, are done every time)
	- Internet Explorer 6.0 SP1
		This is shown only on Windows 2000 if Internet Explorer 6.0 SP1 isn't installed.
		It is mandatory, because having installed it is needed (you can uninstall it then and Windows Update won't stop working)
		It basically download and run IE6.0 SP1 installer, then reboots the system.
	- Windows Vista Servicing Stack Update
		This is shown only on Windows Vista SP2 and it's mandatory.
		It installs KB3205638, KB4012583, KB4015195, KB4015380 which are required to allow Windows Update to complete a scan.
		Although it's always shown, updates get installed only if they're missing from the system.
	- Windows Update Agent update
		This is shown on any system whose Windows Update Agent version is not 7.4.7600.226 (see section 3 to see why this version)
		This option is mandatory if it's shown.
		If the system detect a more recent version of Windows Update Agent on Windows Vista and 7, it downloads version 7.6.7600.256 and runs it with /uninstall parameter, to restore OS's default version.
		Then it downloads version 7.4.7600.226 and runs it with /WUforce parameter (to allow a downgrade on XP).
		In the end it reboots the system if necessary.
		This is always shown ojìn Windows 7 SP1 because it comes by default with version 7.5.7600.325, but it doesn't create any problems.
	- Restore Windows Update
		This is always shown (not mandatory, but it's the core of the program). It:
		1) Runs updroots -l CA.sst to add to Trusted Roots the proxy CA.crt
		2) Adds some keys to the registry to properly configure the proxy in Internet Explorer
		3) Copies muweb.dll and wuweb.dll into system32 and registers them (required to access Microsoft Update)
		4) Runs proxycfg -u (on NT 5) or netsh winhttp set proxy proxy-address="https=IP:PORT" (on NT6) to apply the proxy system-wide
		5) Copies Microsoft Update (website) and Windows Update (website) links to the desktop.

3. HOW THE RESTORE SYSTEM WORKS
Microsoft has blocked Windows Update on older OSes in three ways:
1) update.microsoft.com causes an infinite loop.
2) The site doesn't allow TLS1.0 connections
3) wuredir.xml specifies a no more functional URL to scan for updates (www.update.microsoft.com)
This is solved in the following ways:
1) Adding g_sconsumersite=1 as a query of the URL let the website open, that's the purpose of desktop's links.
    Desktop links are different on NT6 because they need to be run as Administrator
2) This is solved using ProxHTTPSProxy located on the proxy server. It acts as a HTTPS server (with TLS1.0 encryption) to the client and pass the request to Requestly (still on the proxy server).
    But that generates another problem: Windows Update Agent doesn't allow non-Microsoft secure connections from version 7.6.7600.256. That's why I included an older version as mandatory.
    To avoid Windows Update selfupdating (default behaviour, can't be disabled), I use Requestly to redirect any request for "wuident.cab", the file which specify for any Windows version the URL to check for selfupdate.
    I provide it a version from 2006 which doesn't include an URL to update Windows Update Agent 3.0 (it raises 0x00000000 error but goes on scanning).
3) This is solved using Requestly which redirects www.update.microsoft.com requests to fe2.update.microsoft.com
		