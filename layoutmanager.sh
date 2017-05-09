#!/bin/bash
# --------------------------------------------
# Downloads and installs GNOME extensions to match layout https://github.com/bill-mavromatis/gnome-layout-manager
# Licence: GPL 3.0
# Author: Bill Mavromatis
# Credits: Original extension manager script by Nicolas Bernaerts http://bernaerts.dyndns.org/, United theme by globalmenuwhen from gnome-look.org
#
# Revision history :
#   14/04/2017 - V1.0 : ALPHA release(use on a VM or liveUSB not on your main system, it may affect your extensions)
#   16/04/2017 - V1.1 : Tweaked gsettings, bugfixes
#   16/04/2017 - V1.2 : Added more extensions and themes for Unity
#   17/04/2017 - V1.3 : Fixed invalid URL for United, changed to United Light theme, more bugfixes
#   17/04/2017 - V1.4 : More bugfixing
#   19/04/2017 - V1.5 : Fixed broken URL, changed download directory to /tmp, bugfixes
#   20/04/2017 - V1.6 : Changed United to 1.74, in process of testing out dynamic panel transpareny and global menus
#   21/04/2017 - V1.7 : Placed title bar icons for macosx to the left, some minor bugfixing, United URL now on github
#   27/04/2017 - V1.8 : Added zenity dialogs (thanks to @JackHack96), added AppIndicator to go with TopIcons according to issue#2, made wgets verbose
#   27/04/2017 - V1.9 : Renamed MacOSX to macOS, removed dropdown arrows from windows layout
#   2/5/2017   - V2.0 : Added themes for Windows/macOS, added vanilla layout, save/load function
#   4/5/2017   - V2.1 : Fixed save/load function, added wallpapers, reverted commit (changed dconf back to gsettings loop)
#   7/5/2017   - V2.2 : Housekeeping, check if extensions/themes are installed, changed theme dir to the official one, removed local schemadirs, arguments work again, temp hack for ext800
# -------------------------------------------

ZENITY=true

# check tools availability
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

# install path (user and system mode)
USER_PATH="$HOME/.local/share/gnome-shell/extensions"
[ -f /etc/debian_version ] && SYSTEM_PATH="/usr/local/share/gnome-shell/extensions" || SYSTEM_PATH="/usr/share/gnome-shell/extensions"

# set gnome shell extension site URL
GNOME_SITE="https://extensions.gnome.org"

# get current gnome version (major and minor only)
GNOME_VERSION="$(DISPLAY=":0" gnome-shell --version | tr -cd "0-9." | cut -d'.' -f1,2)"

# default installation path for default mode (user mode, no need of sudo)
INSTALL_MODE="user"
EXTENSION_PATH="${USER_PATH}"
INSTALL_SUDO=""

PICTURES_FOLDER=$(xdg-user-dir PICTURES)

LAYOUT=""

# help message if no parameter
if [[ ${#} -eq 0 && $ZENITY == false ]]; then
    echo "Downloads and installs GNOME extensions from Gnome Shell Extensions site https://extensions.gnome.org/"
    echo "Parameters are :"
    echo "  --save                  Save current settings (all gsettings in /org/gnome/) to ~/.config/gnome-layout-manager/"
    echo "  --load                  Load settings (Please save your work as this may crash your gnome-shell)"
    echo "  --windows               Windows 10 layout (panel and no topbar)"
    echo "  --macosx                macOS layout (bottom dock /w autohide + topbar)"
    echo "  --unity                 Unity layout (left dock + topbar)"
    echo "  --vanilla               GNOME Vanilla (Adwaita theme + disable all extensions)"
    exit 1
else
    if [[ $# -eq 0 ]]; then   #if no argument given, start zenity
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
		"Unity layout") declare -a arr=("307" "1031" "19" "744" "2" "615" "723"); shift; LAYOUT="unity"; shift; ;;
		"GNOME Vanilla") declare -a arr=(); LAYOUT="vanilla"; shift; ;;
		"macOS layout") declare -a arr=("307" "1031" "615" "19" "2"); LAYOUT="macosx"; shift; ;;
		"Windows 10 layout") declare -a arr=("1160" "608" "1031" "615" "800" "19"); LAYOUT="windows"; shift; ;;
		*) exit 1
	    esac
    fi
fi

# iterate thru parameters
while test ${#} -gt 0
do
  case $1 in
    --save) declare -a arr=(); LAYOUT="save"; shift; ;;
    --load) declare -a arr=(); LAYOUT="load"; shift; ;;
    --windows) declare -a arr=("1160" "608" "1031" "615" "800" "19"); LAYOUT="windows"; shift; ;;
    --macosx) declare -a arr=("307" "1031" "615" "19" "2"); LAYOUT="macosx"; shift; ;;
    --unity) declare -a arr=("307" "1031" "19" "744" "2" "615" "723"); shift; LAYOUT="unity"; shift; ;;
    --vanilla) declare -a arr=(); shift; LAYOUT="vanilla"; shift; ;;
    *) echo "Unknown parameter $1"; shift; ;;
  esac
done

#disable all current extensions
if [[ $LAYOUT == "windows" || $LAYOUT == "macosx" || $LAYOUT == "unity" || $LAYOUT == "vanilla" ]]; then
	echo "Layout selected: $LAYOUT"
	echo "Disabling all current extensions"

	gsettings set org.gnome.shell enabled-extensions []
    	[[ -e ~/.local/share/themes ]] || mkdir -p ~/.local/share/themes  #create theme and icon directory
	[[ -e ~/.local/share/icons ]] || mkdir -p ~/.local/share/icons 
fi 

#install all extensions from array
if [[ $LAYOUT == "windows" || $LAYOUT == "macosx" || $LAYOUT == "unity" ]]; then
	for EXTENSION_ID in "${arr[@]}"
	do
		# if no extension id, exit
		#[ "${EXTENSION_ID}" = "" ] && { echo "You must specify an extension ID"; exit; }

		# if no action, exit
		#[ "${ACTION}" = "" ] && { echo "You must specify a layout"; exit; }

		# if system mode, set system installation path and sudo mode
		#[ "${INSTALL_MODE}" = "system" ] && { EXTENSION_PATH="${SYSTEM_PATH}"; INSTALL_SUDO="sudo"; }

		# create temporary files
		TMP_DESC=$(mktemp -t ext-XXXXXXXX.txt)
		TMP_ZIP=$(mktemp -t ext-XXXXXXXX.zip)
		TMP_VERSION=$(mktemp -t ext-XXXXXXXX.ver)
		rm "${TMP_DESC}" "${TMP_ZIP}"

		# get extension description
		wget --header='Accept-Encoding:none' -O "${TMP_DESC}" "${GNOME_SITE}/extension-info/?pk=${EXTENSION_ID}"

		# get extension name
		EXTENSION_NAME=$(sed 's/^.*name[\": ]*\([^\"]*\).*$/\1/' "${TMP_DESC}")

		# get extension description
		EXTENSION_DESCR=$(sed 's/^.*description[\": ]*\([^\"]*\).*$/\1/' "${TMP_DESC}")

		# get extension UUID
		EXTENSION_UUID=$(sed 's/^.*uuid[\": ]*\([^\"]*\).*$/\1/' "${TMP_DESC}")

		# if ID not known
		if [ ! -s "${TMP_DESC}" ];
		then
		  echo "Extension with ID ${EXTENSION_ID} is not available from Gnome Shell Extension site."
		elif [[ -d ~/.local/share/gnome-shell/extensions/${EXTENSION_UUID} ]]; then
		  echo "Extension already installed."
		else
		# else, if installation mode
		#elif [ "${ACTION}" = "install" ];
		#then

		  # extract all available versions
		  sed "s/\([0-9]*\.[0-9]*[0-9\.]*\)/\n\1/g" "${TMP_DESC}" | grep "pk" | grep "version" | sed "s/^\([0-9\.]*\).*$/\1/" > "${TMP_VERSION}"

		  # check if current version is available
		  VERSION_AVAILABLE=$(grep "^${GNOME_VERSION}$" "${TMP_VERSION}")

		  # if version is not available, get the next one available
		  if [ "${VERSION_AVAILABLE}" = "" ]
		  then
		    echo "${GNOME_VERSION}" >> "${TMP_VERSION}"
		    VERSION_AVAILABLE=$(cat "${TMP_VERSION}" | sort -V | sed "1,/${GNOME_VERSION}/d" | head -n 1)
		  fi
		  
		  
		  if [[ ${EXTENSION_ID} -eq "800" ]]; then #Dirty hack for ext800 (temp)
		  	VERSION_AVAILABLE="3.22"
		  fi

		  # if still no version is available, error message
		  if [ "${VERSION_AVAILABLE}" = "" ]  
		  then
		    echo "Gnome Shell version is ${GNOME_VERSION}."
		    echo "Extension ${EXTENSION_NAME} is not available for this version."
		    echo "Available versions are :"
		    sed "s/\([0-9]*\.[0-9]*[0-9\.]*\)/\n\1/g" "${TMP_DESC}" | grep "pk" | grep "version" | sed "s/^\([0-9\.]*\).*$/\1/" | sort -V | xargs

		  # else, install extension
		  else
		    # get extension description
		    wget --header='Accept-Encoding:none' -O "${TMP_DESC}" "${GNOME_SITE}/extension-info/?pk=${EXTENSION_ID}&shell_version=${VERSION_AVAILABLE}"

		    # get extension download URL
		    EXTENSION_URL=$(sed 's/^.*download_url[\": ]*\([^\"]*\).*$/\1/' "${TMP_DESC}")

		    # download extension archive
		    wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${GNOME_SITE}${EXTENSION_URL}"

		    # unzip extension to installation folder
		    ${INSTALL_SUDO} mkdir -p "${EXTENSION_PATH}"/"${EXTENSION_UUID}"
		    ${INSTALL_SUDO} unzip -oq "${TMP_ZIP}" -d "${EXTENSION_PATH}"/"${EXTENSION_UUID}"
		    ${INSTALL_SUDO} chmod +r "${EXTENSION_PATH}"/"${EXTENSION_UUID}"/*

		    # list enabled extensions
		    EXTENSION_LIST=$(gsettings get org.gnome.shell enabled-extensions | sed 's/^.\(.*\).$/\1/')

		    # if extension not already enabled, declare it
		    EXTENSION_ENABLED=$(echo "${EXTENSION_LIST}" | grep "${EXTENSION_UUID}")
		    [ "$EXTENSION_ENABLED" = "" ] && gsettings set org.gnome.shell enabled-extensions "[${EXTENSION_LIST},'${EXTENSION_UUID}']"

		    # success message
		    echo "Gnome Shell version is ${GNOME_VERSION}."
		    echo "Extension ${EXTENSION_NAME} version ${VERSION_AVAILABLE} has been installed in ${INSTALL_MODE} mode (Id ${EXTENSION_ID}, Uuid ${EXTENSION_UUID})"
		    #echo "Restart Gnome Shell to take effect."

		  fi

		# else, it is remove mode
		#else

		    # remove extension folder
		    #${INSTALL_SUDO} rm -f -r "${EXTENSION_PATH}/${EXTENSION_UUID}"

		    # success message
		    #echo "Extension ${EXTENSION_NAME} has been removed in ${INSTALL_MODE} mode (Id ${EXTENSION_ID}, Uuid ${EXTENSION_UUID})"
		    #echo "Restart Gnome Shell to take effect."

		fi

		# remove temporary files
		rm -f "${TMP_DESC}" "${TMP_ZIP}" "${TMP_VERSION}"
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
	zenity --info --width=500 --height=200 --text "Layout applied successfully.\nIf you are experiencing any issues, please restart gnome-shell."
	;;
    macosx) 
   	gsettings set org.gnome.shell enabled-extensions "['dash-to-dock@micxgx.gmail.com', 'TopIcons@phocean.net', 'appindicatorsupport@rgcjonas.gmail.com', 'Move_Clock@rmy.pobox.com', 'user-theme@gnome-shell-extensions.gcampax.github.com']"
	if [[ -e ~/.themes/Gnome-OSX-II-NT-2-5-1 ]]; then 
		mv -v ~/.themes/Gnome-OSX-II-NT-2-5-1/ ~/.local/share/themes/Gnome-OSX-II-NT-2-5-1/    #move old files
	elif [[ ! -d ~/.local/share/themes/Gnome-OSX-II-NT-2-5-1 ]]; then 
		cd /tmp && wget https://dl.opendesktop.org/api/files/download/id/1489658553/Gnome-OSX-II-NT-2-5-1.tar.xz && tar -xvf Gnome-OSX-II-NT-2-5-1.tar.xz -C ~/.local/share/themes/
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
	cd /tmp && wget https://dl.opendesktop.org/api/files/download/id/1493629910/Human.zip && unzip -o Human.zip -d ~/.local/share/themes/
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
	gsettings set org.gnome.desktop.interface gtk-theme "Gnome-OSX-II-NT-2-5-1"
	gsettings set org.gnome.shell.extensions.user-theme name "Human"
	gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/ShellShowsAppMenu': <1>}"
	zenity --info --width=500 --height=200 --text "Layout applied successfully.\nIf you are experiencing any issues, please restart gnome-shell."
	;;
    unity) 
    gsettings set org.gnome.shell enabled-extensions "['dash-to-dock@micxgx.gmail.com', 'TopIcons@phocean.net', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'Hide_Activities@shay.shayel.org', 'Move_Clock@rmy.pobox.com', 'appindicatorsupport@rgcjonas.gmail.com', 'pixel-saver@deadalnix.me']"
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
	cd /tmp && wget https://github.com/godlyranchdressing/United-GNOME/raw/master/United-Latest.tar.gz && tar -xvzf United-Latest.tar.gz -C /tmp/ && mv /tmp/United-Latest-Ubuntu/* ~/.local/share/themes/
	fi
	if [[ ! -f "$PICTURES_FOLDER"/wallpaper-united.png ]]; then 
	cd /tmp && wget https://raw.githubusercontent.com/godlyranchdressing/United-GNOME/master/Wallpaper.png && mv Wallpaper.png "$PICTURES_FOLDER"/wallpaper-united.png
	fi
	gsettings set org.gnome.desktop.background picture-uri file:///"$PICTURES_FOLDER"/wallpaper-united.png
	if [[ ! -d ~/.local/share/icons/Humanity ]]; then 
	wget https://launchpad.net/ubuntu/+archive/primary/+files/humanity-icon-theme_0.6.13.tar.xz && tar --xz -xvf humanity-icon-theme_0.6.13.tar.xz -C /tmp/ && mv /tmp/humanity-icon-theme-0.6.13/* ~/.local/share/icons
	fi
	gsettings set org.gnome.desktop.interface icon-theme "Humanity"
	gsettings set org.gnome.desktop.interface gtk-theme "United"
	gsettings set org.gnome.shell.extensions.user-theme name "United"
	gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
	gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/ShellShowsAppMenu': <1>}"	
	zenity --info --width=500 --height=200 --text "Layout applied successfully.\nIf you are experiencing any issues, please restart gnome-shell."
	;;
    vanilla) 
	gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
	gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
	gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
	gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
	gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/gnome/adwaita-morning.jpg
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

	if [[ $ZENITY == true && ${#} -ne 0 ]]; then
		zenity --info --text "Layout loaded from ~/.config/gnome-layout-manager/"
		else
		echo -e "Layout loaded from ~/.config/gnome-layout-manager/"
	fi;
	;;
  esac
