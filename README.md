*Notice: This software is alpha and under development. Please use at your own risk.*

# GNOME Layout Manager
A bash script that batch installs and tweaks GNOME extensions as well as GTK/Shell themes. There are currently three options available: Unity, Windows and macOS.
<img src="http://i.imgur.com/6Qgf2Cc.png" width="600" align="middle">

#### Update:
Added Global Menu for Unity Layout! A new [fork](https://github.com/bill-mavromatis/Gnome-Global-AppMenu) was made based on [lestcape's excellent extension](https://github.com/lestcape/Gnome-Global-AppMenu) where I added some tweaks to the css file to improve padding and fixed the conflict with Pixel Saver. To run it you need the unity gtk module:  
<img src="https://cdn2.iconfinder.com/data/icons/metro-uinvert-dock/256/OS_Ubuntu.png" height="20" align="left">Ubuntu/Mint: ```sudo apt-get install unity-gtk2-module unity-gtk3-module```  
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Archlinux-icon-crystal-64.svg/2000px-Archlinux-icon-crystal-64.svg.png" height="20" align="left"> Arch/Antergos/Manjaro: ```yaourt -S unity-gtk-module-standalone-bzr```  
<img src="https://cdn1.iconfinder.com/data/icons/system-shade-circles/512/fedora-512.png" height="20" align="left">Fedora: ```sudo dnf install unity-gtk-modules``` 

Coming soon: [HUD](https://github.com/p-e-w/plotinus) (currently [resolving](https://github.com/p-e-w/plotinus/issues/25) non-root installation). Feel free to open any issues/pull requests if you have any ideas.

#### Required Packages:
```zenity wget curl unzip```  

#### Install Instructions:
Download and run the script as user (no root required):
```
wget https://raw.githubusercontent.com/bill-mavromatis/gnome-layout-manager/master/layoutmanager.sh
chmod +x layoutmanager.sh
./layoutmanager.sh
```
#### Install folders:
Extensions: ```~/.local/share/gnome-shell/extensions```   
Themes: ```~/.local/share/themes```  
Icons: ```~/.local/share/icons```  
Schemas: ```~/.local/share/glib-2.0/schemas```  
Wallpaper: ```~/Pictures``` (or as set by xdg-user-dir)  
Backup: ```~/.config/gnome-layout-manager```  

## Unity

Preview: 
![Unity](http://i.imgur.com/He66ZsK.png)

| <img style="float: left;" src="http://i.imgur.com/He66ZsK.png" height="200" > | Extensions: |
- [Dash to dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
- [TopIcons Plus](https://extensions.gnome.org/extension/1031/topicons/)
- [AppIndicator](https://extensions.gnome.org/extension/615/appindicator-support/)
- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
- [Hide Activities](https://extensions.gnome.org/extension/744/hide-activities-button/)
- [Frippery Move Clock](https://extensions.gnome.org/extension/2/move-clock/)
- [Pixel Saver (fork - added United theme)](https://github.com/bill-mavromatis/pixel-saver)
- [Global Menu (fork - fixed padding and conflict with Pixel Siaver)](https://github.com/bill-mavromatis/Gnome-Global-AppMenu)

Theme:
- [United (GTK+Shell+Wallpaper)](https://www.gnome-look.org/p/1174889) by [@godlyranchdressing](https://github.com/godlyranchdressing) Licence: GPLv2
- [Humanity icon theme](https://launchpad.net/humanity) by Canonical, Licence: GPLv2


## Windows

Preview: 
![Windows](http://i.imgur.com/c4EY20U.png)

Extensions:
- Dash to panel
- TopIcons Plus
- AppIndicator
- GnoMenu
- User Themes

Theme:
- [Windows-10](https://github.com/B00merang-Project/Windows-10) (GTK+Shell+Icons) by [@B00merang-Project](https://github.com/B00merang-Project), Licence: GPLv3
- Wallpaper: [Blue Dark Blue Flat Windows](https://www.pexels.com/photo/blue-dark-blue-flat-windows-337685/) (License: [Creative Commons 0 Licence](https://creativecommons.org/publicdomain/zero/1.0/), Author: [Santiago Paz](https://www.pexels.com/u/santiago-paz-109124/)) 

## macOS

Preview: 
![macOS](http://i.imgur.com/aYAfZxQ.png)

Extensions:
- Dash to dock
- TopIcons Plus
- AppIndicator
- User Themes
- Frippery Move Clock

Theme:
- [Gnome-OSX-II-NT](https://www.gnome-look.org/p/1171688/) (GTK) by [@PAULXFCE](https://www.gnome-look.org/member/455718/), Licence: [Creative Commons](https://creativecommons.org/licenses/by-sa/3.0/) 
- [Human](https://www.gnome-look.org/p/1171095/) (Shell) by [@UMAYANGA](https://www.gnome-look.org/member/434822/) Licence: GPLv3
- [La-Capitaine icons](https://github.com/keeferrourke/la-capitaine-icon-theme) by [@keeferrourke](https://github.com/keeferrourke)
- Wallpaper: [Aurora](http://www.panoramio.com/photo/9384842) (License: [Creative Commons Attribution-ShareAlike 3.0 Unported](https://creativecommons.org/licenses/by-sa/3.0/), Author: [denbol](http://www.panoramio.com/photo/9384842)) 

### FAQ: 

#### -My GNOME shell freezes when I run the script.
In some occasions your GNOME session might seem to freeze while running the script, however the script is probably still running in the background (you can see the light of your Hard Drive of your computer flashing intensely). Please allow a full 1 minute for the script to complete. Once it completes the shell will appear to restart and you may close the terminal. Your programs will not be lost, but it'd be safe to save your work before running the script.

#### -I'm getting various errors on the console while running the script.
This is normal, most of commands are verbose, and some errors occur because you may already have the extensions that the script is trying to download. Please ignore them and allow the script about 1 minute to complete. If the script is interrupted, you can re-run it. When done, close the console, and if you have any issues hit Alt+F2 and type "r" (this will restart X).

#### -Global menu when?
I'm keeping a very close look at [this extension](https://github.com/lestcape/Gnome-Global-AppMenu) and will add it once it's stable enough.

#### -Any new layouts being added?
If you have any ideas, feel free to open an issue or make a pull request.

Licence: GPL 3.0

Author: Bill Mavromatis

Credits: Original extension manager script by Nicolas Bernaerts http://bernaerts.dyndns.org/, United theme by @godlyranchdressing, other credits show on the layout descriptions.
