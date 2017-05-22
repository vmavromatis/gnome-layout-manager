#!/bin/bash

   #################################################################
   #                                                               #
   #                 GNOME Layout Manager              		   #
   #           Copyright (C) 2017 Bill Mavromatis                  #
   #       Licensed under the GNU General Public License 3.0       #
   #                                                               #
   #  https://github.com/bill-mavromatis/gnome-layout-manager      #
   #                                                               #
   #################################################################


# Check tools availability (zenity, wget, unzip)
ZENITY=true
command -v zenity >/dev/null 2>&1 || { ZENITY=false; }
command -v unzip >/dev/null 2>&1 || {
    if [[ $ZENITY == true ]]; then
      zenity --error --text="Please install unzip!"
    else
      echo -e "\e[31m\e[1mPlease install unzip!\e[0m"
    fi;
    exit 1;
}
command -v wget >/dev/null 2>&1 || {
    if [[ $ZENITY == true ]]; then
      zenity --error --text="Please install wget!"
    else
      echo -e "\e[31m\e[1mPlease install wget!\e[0m"
    fi;
    exit 1;
}
command -v curl >/dev/null 2>&1 || {
    if [[ $ZENITY == true ]]; then
      zenity --error --text="Please install curl!"
    else
      echo -e "\e[31m\e[1mPlease install curl!\e[0m"
    fi;
    exit 1;
}

# Set gnome shell extension site URL
GNOME_SITE="https://extensions.gnome.org"

# Get current GNOME version (major and minor only)
GNOME_VERSION="$(DISPLAY=":0" gnome-shell --version | tr -cd "0-9." | cut -d'.' -f1,2)"

# Default installation path for default mode (user mode, no need of sudo)
EXTENSION_PATH="$HOME/.local/share/gnome-shell/extensions"


PICTURES_FOLDER=$(xdg-user-dir PICTURES)
dirs=( $(find /usr/share/gnome-shell/extensions $HOME/.local/share/gnome-shell/extensions -maxdepth 1 -type d -printf '%P\n') )


declare -a EXT_UNITY=('dash-to-dock@micxgx.gmail.com' 'TopIcons@phocean.net' 'user-theme@gnome-shell-extensions.gcampax.github.com' 'Move_Clock@rmy.pobox.com' 'appindicatorsupport@rgcjonas.gmail.com' 'gnomeGlobalAppMenu@lestcape' 'Hide_Activities@shay.shayel.org' 'RemoveAppMenu@rastersoft.com' 'pixel-saver@deadalnix.me')
declare -a EXT_WINDOWS=('TopIcons@phocean.net' 'appindicatorsupport@rgcjonas.gmail.com' 'user-theme@gnome-shell-extensions.gcampax.github.com' 'dash-to-panel@jderose9.github.com' 'gnomenu@panacier.gmail.com' 'remove-dropdown-arrows@mpdeimos.com')
declare -a EXT_MACOS=('dash-to-dock@micxgx.gmail.com' 'TopIcons@phocean.net' 'appindicatorsupport@rgcjonas.gmail.com' 'Move_Clock@rmy.pobox.com' 'user-theme@gnome-shell-extensions.gcampax.github.com')

LAYOUT=""

# If no arguments given, show help
if [[ ${#} -eq 0 && $ZENITY == false ]]; then
    echo "Downloads and installs GNOME extensions from Gnome Shell Extensions site https://extensions.gnome.org/"
    echo "Parameters are :"
    echo "  --save                  Save current settings (all gsettings in /org/gnome/) to ~/.config/gnome-layout-manager/"
    echo "  --load                  Load settings (Please save your work as this may crash your gnome-shell)"
    echo "  --windows               Windows 10 layout (panel and no topbar)"
    echo "  --macos                 macOS layout (bottom dock /w autohide + topbar)"
    echo "  --unity                 Unity layout (left dock + topbar)"
    echo "  --vanilla               GNOME Vanilla (Adwaita theme + disable all extensions)"
    exit 1
else
    if [[ $# -eq 0 ]]; then   #if no argument given and zenity installed, start zenity
	    ANSWER=$(zenity --list --width=800 --height=400 --text "Please select the layout you want" --column "Option" --column "Details" \
	    "Save" "Save current settings (all gsettings in /org/gnome/) to ~/.config/gnome-layout-manager/"\
	    "Load" "Load settings (Please save your work as this may crash your gnome-shell)"\
	    " " " "\
	    "Unity layout" "(left dock + topbar)" \
	    "GNOME Vanilla" "(Adwaita theme + disable all extensions)" \
	    "macOS layout" "(bottom dock + topbar)" \
	    "Windows 10 layout" "(bottom panel and no topbar)")
	    case $ANSWER in
		"Save") declare -a arr=(); shift; LAYOUT="save"; shift; ;;
		"Load") declare -a arr=(); shift; LAYOUT="load"; shift; ;;
		"Unity layout") declare -a arr=( "${EXT_UNITY[@]}" ); shift; LAYOUT="unity"; shift; ;;
		"GNOME Vanilla") declare -a arr=(); LAYOUT="vanilla"; shift; ;;
		"macOS layout") declare -a arr=( "${EXT_MACOS[@]}" ); LAYOUT="macos"; shift; ;;
		"Windows 10 layout") declare -a arr=( "${EXT_WINDOWS[@]}" ); LAYOUT="windows"; shift; ;;
		*) exit 1
	    esac
    fi
fi

# Read arguments (if any)
while test ${#} -gt 0
do
  case $1 in
    --save) declare -a arr=(); LAYOUT="save"; shift; ;;
    --load) declare -a arr=(); LAYOUT="load"; shift; ;;
    --windows) declare -a arr=( "${EXT_WINDOWS[@]}" ); LAYOUT="windows"; shift; ;;
    --macos) declare -a arr=( "${EXT_MACOS[@]}" ); LAYOUT="macos"; shift; ;;
    --unity) declare -a arr=( "${EXT_UNITY[@]}" ); shift; LAYOUT="unity"; shift; ;;
    --vanilla) declare -a arr=(); shift; LAYOUT="vanilla"; shift; ;;
    *) echo "Unknown parameter $1"; shift; ;;
  esac
done

#Disable all current extensions
if [[ $LAYOUT == "windows" || $LAYOUT == "macos" || $LAYOUT == "unity" || $LAYOUT == "vanilla" ]]; then
	echo "Layout selected: $LAYOUT"
	echo "Disabling all current extensions"

	gsettings set org.gnome.shell enabled-extensions []
    	[[ -e ~/.local/share/themes ]] || mkdir -p ~/.local/share/themes  #Create theme and icon directory
	[[ -e ~/.local/share/icons ]] || mkdir -p ~/.local/share/icons 
fi 

#install all extensions from array
if [[ $LAYOUT == "windows" || $LAYOUT == "macos" || $LAYOUT == "unity" ]]; then
	for EXT_UUID in "${arr[@]}"
	do
		# if installed, skip
		if [[ " ${dirs[*]} " == *" $EXT_UUID "* ]]; then
			echo "Extension ${EXT_UUID} is already installed. Skipping."
		else
			if [[ ${EXT_UUID} == "remove-dropdown-arrows" ]]; then #For Dropdown Arrows fake 3.22
				GNOME_VERSION="3.22"
			fi

			TMP_ZIP=$(mktemp -t ext-XXXXXXXX.zip)

			JSON="${GNOME_SITE}/extension-info/?uuid=${EXT_UUID}&shell_version=${GNOME_VERSION}"
			EXTENSION_URL=${GNOME_SITE}$(curl -s "${JSON}" | sed -e 's/^.*download_url[\": ]*\([^\"]*\).*$/\1/') 

			# download extension archive
			if [[ ${EXT_UUID} == "gnomeGlobalAppMenu@lestcape" ]]; then #For Global Menu use GitHub instead
				EXTENSION_URL="https://github.com/bill-mavromatis/Gnome-Global-AppMenu/archive/master.zip"	
				wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${EXTENSION_URL}"		
				# unzip extension to installation folder
				mkdir -p "${EXTENSION_PATH}"/"${EXT_UUID}"
				unzip -o "${TMP_ZIP}" -d /tmp/
				cp -R "/tmp/Gnome-Global-AppMenu-master/gnomeGlobalAppMenu@lestcape/" -d "${EXTENSION_PATH}"
				chmod +r "${EXTENSION_PATH}"/"${EXT_UUID}"/*
			elif [[ ${EXT_UUID} == "pixel-saver@deadalnix.me" ]]; then #For Pixel Saver use GitHub instead
				EXTENSION_URL="https://github.com/bill-mavromatis/pixel-saver/archive/master.zip"	
				wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${EXTENSION_URL}"		
				# unzip extension to installation folder
				mkdir -p "${EXTENSION_PATH}"/"${EXT_UUID}"
				unzip -o "${TMP_ZIP}" -d /tmp/
				cp -R "/tmp/pixel-saver-master/pixel-saver@deadalnix.me/" -d "${EXTENSION_PATH}"
				chmod +r "${EXTENSION_PATH}"/"${EXT_UUID}"/*
			else    #for everything else use GNOME site
				wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${EXTENSION_URL}"		
				# unzip extension to installation folder
				mkdir -p "${EXTENSION_PATH}"/"${EXT_UUID}"
				unzip -oq "${TMP_ZIP}" -d "${EXTENSION_PATH}"/"${EXT_UUID}"
				chmod +r "${EXTENSION_PATH}"/"${EXT_UUID}"/*
			fi

		fi
		rm -f "${TMP_ZIP}" #remove temp files
	done
fi

#Move schema files to local dir and compile
[[ -e ~/.local/share/glib-2.0/schemas/ ]] || mkdir -p ~/.local/share/glib-2.0/schemas/
export XDG_DATA_DIRS=~/.local/share:/usr/share
find ~/.local/share/gnome-shell/extensions/ -name *gschema.xml -exec ln {} -sfn ~/.local/share/glib-2.0/schemas/ \;
glib-compile-schemas ~/.local/share/glib-2.0/schemas/

#apply layout
  case $LAYOUT in
    windows) 
   	gsettings set org.gnome.shell enabled-extensions "['TopIcons@phocean.net', 'appindicatorsupport@rgcjonas.gmail.com', 'remove-dropdown-arrows@mpdeimos.com', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'dash-to-panel@jderose9.github.com', 'gnomenu@panacier.gmail.com']"
	if [[ -e ~/.themes/Windows-10-master ]]; then 
		mv -v ~/.themes/Windows-10-master/ ~/.local/share/themes/Windows-10-master/    #move old files
	elif [[ ! -d ~/.local/share/themes/Windows-10-master ]]; then 
		cd /tmp && wget -N https://github.com/B00merang-Project/Windows-10/archive/master.zip && unzip -o master.zip -d ~/.local/share/themes/
	fi
	if [[ ! -f "$PICTURES_FOLDER"/wallpaper-windows.png ]]; then 
		cd /tmp && wget https://static.pexels.com/photos/337685/pexels-photo-337685.png && mv pexels-photo-337685.png "$PICTURES_FOLDER"/wallpaper-windows.png
	fi
	gsettings set org.gnome.desktop.background picture-uri file:///"$PICTURES_FOLDER"/wallpaper-windows.png
	if [[ ! -d ~/.local/share/icons/Windows-10-Icons-master  ]]; then 
	cd /tmp && wget -N  https://github.com/B00merang-Project/Windows-10-Icons/archive/master.zip && unzip -o master.zip -d ~/.local/share/icons/
	fi	
	gsettings set org.gnome.shell.extensions.topicons tray-pos 'Center'
	gsettings set org.gnome.shell.extensions.topicons tray-order '2'
	gsettings set org.gnome.shell.extensions.dash-to-panel panel-position 'BOTTOM'
	gsettings set org.gnome.shell.extensions.dash-to-panel location-clock 'STATUSRIGHT'
	gsettings set org.gnome.shell.extensions.gnomenu disable-activities-hotcorner 'true'
	gsettings set org.gnome.shell.extensions.gnomenu hide-panel-view 'true'
	gsettings set org.gnome.shell.extensions.gnomenu hide-panel-apps 'true'
	gsettings set org.gnome.shell.extensions.gnomenu panel-menu-label-text ["''"]
	gsettings set org.gnome.shell.extensions.gnomenu disable-panel-menu-keyboard 'true'
	gsettings set org.gnome.shell.extensions.gnomenu hide-shortcuts 'true'
	gsettings set org.gnome.shell.extensions.gnomenu hide-useroptions 'true'
	gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
	gsettings set org.gnome.desktop.interface icon-theme "Windows-10-Icons-master"
	gsettings set org.gnome.desktop.interface gtk-theme "Windows-10-master"
	gsettings set org.gnome.shell.extensions.user-theme name "Windows-10-master"
        gnome-shell --replace &>/dev/null & disown
	zenity --info --width=500 --height=200 --text "Layout applied successfully.\nIf you are experiencing any issues, please restart gnome-shell."
	;;
    macos) 
   	gsettings set org.gnome.shell enabled-extensions "['dash-to-dock@micxgx.gmail.com', 'TopIcons@phocean.net', 'appindicatorsupport@rgcjonas.gmail.com', 'Move_Clock@rmy.pobox.com', 'user-theme@gnome-shell-extensions.gcampax.github.com']"
	if [[ -e ~/.themes/Gnome-OSX-II-2-6-NT ]]; then 
		mv -v ~/.themes/Gnome-OSX-II-NT-2-6/ ~/.local/share/themes/Gnome-OSX-II-2-6-NT/    #move old files
	elif [[ ! -d ~/.local/share/themes/nome-OSX-II-2-6-NT ]]; then 
		cd /tmp && wget https://dl.opendesktop.org/api/files/download/id/1494791955/Gnome-OSX-II-2-6-NT.tar.gz && tar -xvzf Gnome-OSX-II-2-6-NT.tar.gz -C ~/.local/share/themes/
	fi
	if [[ ! -f "$PICTURES_FOLDER"/wallpaper-macos.jpg ]]; then 
		cd /tmp && wget https://upload.wikimedia.org/wikipedia/commons/9/9b/Aurora_-_panoramio.jpg && mv Aurora_-_panoramio.jpg "$PICTURES_FOLDER"/wallpaper-macos.jpg
	fi
	gsettings set org.gnome.desktop.background picture-uri file:///"$PICTURES_FOLDER"/wallpaper-macos.jpg
	if [[ ! -d ~/.local/share/icons/La-Capitaine ]]; then 
		cd /tmp && wget -N https://github.com/keeferrourke/la-capitaine-icon-theme/archive/master.zip && unzip -o master.zip -d ~/.local/share/icons && mv ~/.local/share/icons/la-capitaine-icon-theme-master ~/.local/share/icons/La-Capitaine
	fi
	if [[ -e ~/.themes/Human ]]; then 
		mv -v ~/.themes/Human/ ~/.local/share/themes/Human/    #move old files
	elif [[ ! -d ~/.local/share/themes/Human ]]; then 
	cd /tmp && wget https://dl.opendesktop.org/api/files/download/id/1495328098/Human.zip && unzip -o Human.zip -d ~/.local/share/themes/
	fi
	gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
	gsettings set org.gnome.shell.extensions.dash-to-dock intellihide 'false'
	gsettings set org.gnome.shell.extensions.dash-to-dock extend-height 'false'
	gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity '0.4'
	gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#FFFFFF'
	gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed 'true'
	gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
	gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top 'true'
	gsettings set org.gnome.shell.extensions.dash-to-dock show-running 'true'
	gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme 'false'
	gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
	gsettings set org.gnome.desktop.interface icon-theme "La-Capitaine"
	gsettings set org.gnome.desktop.interface gtk-theme "Gnome-OSX-II-2-6-NT"
	gsettings set org.gnome.shell.extensions.user-theme name "Human"
	gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/ShellShowsAppMenu': <1>}"
        gnome-shell --replace &>/dev/null & disown
	zenity --info --width=500 --height=200 --text "Layout applied successfully.\nIf you are experiencing any issues, please restart gnome-shell."
	;;
    unity) 
    gsettings set org.gnome.shell enabled-extensions "['dash-to-dock@micxgx.gmail.com', 'TopIcons@phocean.net', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'Hide_Activities@shay.shayel.org', 'Move_Clock@rmy.pobox.com', 'appindicatorsupport@rgcjonas.gmail.com', 'pixel-saver@deadalnix.me', 'RemoveAppMenu@rastersoft.com', 'gnomeGlobalAppMenu@lestcape']"
	gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
	gsettings set org.gnome.shell.extensions.dash-to-dock intellihide 'false'
	gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity '0.7'
	gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#2C001E'
	gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed 'true'
	gsettings set org.gnome.shell.extensions.dash-to-dock extend-height 'true'
	gsettings set org.gnome.shell.extensions.dash-to-dock show-running 'true'
	gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top 'true'
	if [[ -e ~/.themes/United ]]; then 
		mv -v ~/.themes/United* ~/.local/share/themes/    #move old files
	elif [[ ! -d ~/.local/share/themes/United ]]; then 
	cd /tmp && wget https://github.com/godlyranchdressing/United-GNOME/raw/master/United-Latest.tar.gz && tar -xvzf United-Latest.tar.gz -C ~/.local/share/themes/
	fi
	if [[ ! -f "$PICTURES_FOLDER"/wallpaper-united.png ]]; then 
	cd /tmp && wget https://raw.githubusercontent.com/godlyranchdressing/United-GNOME/master/Wallpaper.png && mv Wallpaper.png "$PICTURES_FOLDER"/wallpaper-united.png
	fi
	gsettings set org.gnome.desktop.background picture-uri file:///"$PICTURES_FOLDER"/wallpaper-united.png
	if [[ ! -d ~/.local/share/icons/Humanity ]]; then 
	wget https://launchpad.net/ubuntu/+archive/primary/+files/humanity-icon-theme_0.6.13.tar.xz && tar --xz -xvf humanity-icon-theme_0.6.13.tar.xz -C /tmp/ && mv /tmp/humanity-icon-theme-0.6.13/* ~/.local/share/icons
	fi
	gsettings set org.gnome.desktop.interface icon-theme "Humanity"
	gsettings set org.gnome.desktop.interface gtk-theme "United-Ubuntu"
	gsettings set org.gnome.shell.extensions.user-theme name "United-Ubuntu"
	gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
	gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/ShellShowsAppMenu': <1>}"	
        gnome-shell --replace &>/dev/null & disown
	zenity --info --width=500 --height=200 --text "Layout applied successfully.\nIf you are experiencing any issues, please restart gnome-shell."
	;;
    vanilla) 
	gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
	gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
	gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
	gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
	gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/gnome/adwaita-morning.jpg
	gnome-shell --replace &>/dev/null & disown
	zenity --info --width=500 --height=200 --text "Layout applied successfully.\nIf you are experiencing any issues, please restart gnome-shell."
	;;
    save) 
	[[ -e ~/.config/gnome-layout-manager ]] || mkdir ~/.config/gnome-layout-manager
	#dconf dump /org/gnome/desktop/ > ~/.config/gnome-layout-manager/dconf.txt
	#gsettings get org.gnome.shell enabled-extensions > ~/.config/gnome-layout-manager/extensions.txt
	rm ~/.config/gnome-layout-manager/backup.txt #remove old file
	set -x
	for schema in $(gsettings list-schemas | grep 'org.gnome.shell\|org.gnome.desktop')
	do
	    for key in $(gsettings list-keys $schema)
	    do
		value="$(gsettings get $schema $key)"
		echo gsettings set $schema $key $(printf '"')$value$(printf '"') >> ~/.config/gnome-layout-manager/backup.txt 
	    done
	done
	set +x
	
	if [[ $ZENITY == true && ${#} -ne 0 ]]; then
		zenity --info --text "Layout saved in ~/.config/gnome-layout-manager/"
		else
		echo -e "Layout saved in ~/.config/gnome-layout-manager/"
	fi;
	;;
    load) 
	#dconf load /org/gnome/desktop/ < ~/.config/gnome-layout-manager/dconf.txt
	#gsettings set org.gnome.shell enabled-extensions "$(cat ~/.config/gnome-layout-manager/extensions.txt)"	

	bash -x ~/.config/gnome-layout-manager/backup.txt	
	gnome-shell --replace &>/dev/null & disown
	if [[ $ZENITY == true && ${#} -ne 0 ]]; then
		zenity --info --text "Layout loaded from ~/.config/gnome-layout-manager/"
		else
		echo -e "Layout loaded from ~/.config/gnome-layout-manager/"
	fi;
	;;
  esac
