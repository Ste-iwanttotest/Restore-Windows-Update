*** This program is built starting from Legacy Update installer code. You can find the license into the source folder ***

These are notes for users. If you want building and technical notes read readme file into the source folder.

To restore Windows Update as if Microsoft had never blocked it, simply run the installer with default options.
You'll get two prompt, simply click "Ok". I left it for debug reasons.

For Windows 2000 users:
	You'll be asked to install MSXML 4.0. This has to be done manually. Simply follow the guided procedure. Do not cancel installation.
	You'll get Service Pack 4 and Internet Explorer 6 installed. These are required for Windows Update to run. Do not uninstall Service Pack 4.
	You can uninstall Internet Explorer 6 if you want, but you won't be able to access the website (unless you install Internet Explorer 5.5). You'll still be able to use Automatic Updates.
	Access the website using the links on your desktop. Do not use Start Menu's links. They're broken.
	You may have Service Pack 3 installed instead of Service Pack 4. If you want Service Pack 4, download and install it manually.

For Windows XP and Server 2003 users:
	Access the website using the links on your desktop. Do not use Start Menu's links. They're broken.
	You can't upgrade to Service Pack 1 using Windows Update. Download and install it manually if you want.
	Service Pack 2 and 3 are regularly available from Windows Update.

For Windows Vista users:
	The links on your desktop take you to the old websites. You can anyway access Windows Update regularly from the Control Panel.
	If you upgrade from Service Pack 1 to Service Pack 2, run the installer again or Windows Update will stuck.
	Use Microsoft Update link on the desktop to enable it. The link in the Control Panel is broken.

For Windows 7 and Server 2008 users:
	The links on your desktop take you to the old websites. You can anyway access Windows Update regularly from the Control Panel.
	Use Microsoft Update link on the desktop to enable it. The link in the Control Panel is broken.
	Do not install KB3138612 but do not hide it. It will break Windows Update. Uninstalling it will restore Windows Update.
	After KB4474419 installation, follow below instructions to remove the restore system.

If you encounter errors from some applications on the system (it's rare but possible, especially on Windows 7), you have to partially uninstall the restore system.
To do so in Windows 2000, XP and Server 2003:
	Click Run in the Start Menu, type "proxycfg -d" and click OK.
To do so in Windows Vista, 7 and Server 2008:
	Open the Start Menu, look for cmd, right click it, select "run as Administrator" and confirm. Type "netsh winhttp reset proxy" and press ENTER. Close the window.
Remember that after this you will be able to use Windows Update only from the website (unless you use Windows 7 or Server 2008 and have KB4474419 installed)