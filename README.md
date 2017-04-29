## Notice: This software is alpha and under development. Please use at your own risk.


# GNOME Layout Manager

![Menu](http://i.imgur.com/Zw1ByTr.png)

A bash script that batch installs and tweaks GNOME extensions as well as GTK/Shell themes. There are currently three options available: Unity, Windows and MacOS.

To get and run the script:
```
wget https://raw.githubusercontent.com/bill-mavromatis/gnome-layout-manager/master/layoutmanager.sh
chmod +x layoutmanager.sh
./layoutmanager.sh
```

## Unity

Preview: 
![Unity](http://i.imgur.com/He66ZsK.png)
Extensions:
- Dash to dock
- TopIcons Plus
- AppIndicator
- User Themes
- Hide Activities
- Frippery Move Clock

Theme:
- United (GTK+Shell+Wallpaper) by [@godlyranchdressing](https://github.com/godlyranchdressing)
- Humanity icons by Ubuntu

## Windows

Preview: 
![Windows](http://i.imgur.com/TTD4jGK.jpg)

Extensions:
- Dash to panel
- TopIcons Plus
- AppIndicator
- GnoMenu
- User Themes

Theme:
- Windows-10 (GTK+Shell+Icons) by [@B00merang-Project](https://github.com/B00merang-Project)

## macOS

Preview: 
![macOS](http://i.imgur.com/q4AmqOY.jpg)

Extensions:
- Dash to dock
- TopIcons Plus
- AppIndicator
- User Themes

Theme:
- Gnome-OSX-II-NT (GTK) by [@PAULXFCE](https://www.gnome-look.org/member/455718/)
- Human (Shell) by [@UMAYANGA](https://www.gnome-look.org/member/434822/)
- La-Capitaine icons by [@keeferrourke](https://github.com/keeferrourke)


### FAQ: 
#### -I'm getting various errors on the console while running the script.
This is normal, most of commands are verbose, and some errors occur because you may already have the extensions that the script is trying to download. Please ignore them and allow the script about 1 minute to complete. If the script is interrupted, you can re-run it. When done, close the console, and if you have any issues hit Alt+F2 and type "r" (this will restart X).

#### -Can I save my current layout?
This is currently being worked on.

#### -Any new layouts being added?
A Vanilla GNOME (no extensions) will be added soon, along with the user custom layout. Stay tuned. If you have any ideas, feel free to open an issue or make a pull request.


### Tested on: 
- Manjaro 3.22 X11
- Antergos 3.24 X11
- Fedora 3.22 Wayland (wayland needs to restart after script, and then re-run the script to work) [Preview](http://i.imgur.com/692LOkr.png "Fedora 25 Workstation") 
- Ubuntu 3.24 X11
- Arch Linux 3.24 Wayland

(needs more testing for Wayland)

Licence: GPL 3.0

Author: Bill Mavromatis

Credits: Original extension manager script by Nicolas Bernaerts http://bernaerts.dyndns.org/, United theme by @godlyranchdressing
