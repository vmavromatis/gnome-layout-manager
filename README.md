## Notice: This software is alpha and under development. Please use at your own risk.


# GNOME Layout Manager

A bash script that batch installs and tweaks GNOME extensions as well as GTK/Shell themes. There are currently three options available:
--unity --windows & --macosx.

To get and run the script:
```
wget https://raw.githubusercontent.com/bill-mavromatis/gnome-layout-manager/master/layoutmanager.sh
chmod +x layoutmanager.sh
./layoutmanager.sh
```

## Unity (./layoutmanager.sh --unity)

Preview: 
![Unity](http://i.imgur.com/He66ZsK.png)
Extensions:
- Dash to dock
- TopIcons Plus
- User Themes
- Hide Activities
- Frippery Move Clock

Theme:
- United (GTK+Shell) v1.5 by globalmenuwhen

## Windows (WIP) (./layoutmanager.sh --windows)
- Dash to panel
- TopIcons Plus
- GnoMenu

## MacOSX (WIP) (./layoutmanager.sh --macosx)
- Dash to dock
- TopIcons Plus


### Tested on: 
- Manjaro 3.22 X11, 
- Antergos 3.24 X11, 
- Fedora 3.22 Wayland (wayland needs to restart after script, and then re-run the script to work) [Preview](http://i.imgur.com/692LOkr.png "Fedora 25 Workstation") 

Licence: GPL 3.0

Author: Bill Mavromatis

Credits: Original extension manager script by Nicolas Bernaerts http://bernaerts.dyndns.org/, United theme by globalmenuwhen @ gnome-look.org
