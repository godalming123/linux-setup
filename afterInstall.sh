#!/usr/bin/env bash
clear

declare -A codeToInstallThemes
codeToInstallThemes[Zorin]=`git clone https://github.com/ZorinOS/zorin-desktop-themes.git
sudo cp -r zorin-desktop-themes/Z\* /usr/share/themes`

select themeToInstall in "${!codeToINstallThemes[@]}"; do
    codeToInstallThemes["$themeToInstall"]
done


#=========basic functions=========
runIfBool(){
    read -p "$1 y/N: " response
    if [ $response == "y" ]; then $2; fi
}

bannerMessage(){
    sideDashes=$(($($(tput cols) - ${#$1}) / 2))
    
    tput cup 0 $sideDashes
    tput bold
    tput smul
    setaf 2
    
    echo $1
    
    tput sgr0
    tput cup $( tput lines ) 0
}
# =========test bannerMessage function=========
# tput cup $sideDashes
# tput bold
# tput setaf 2
# echo "hello"
# bannerMessage "test"

# =========get packadge manager=========
select packadgeManager in apt-get pacman dnf custom unsopartedPackadge; do
    customPackadgeManger(){
        read -p "Command to install packadge (no need to add sudo): " $installPackCommand
        read -p "Command to update system (no need to add sudo): " $updateSystCommand
    }
    
    case $packadgeManager in
        apt-get)
            installPackCommand="apt-get install"
            updateSystCommand="apt-get upgrade"
            break
        ;;
        pacman)
            installPackCommand="pacman -S"
            updateSystCommand="pacman -U"
            break
        ;;
        dnf)
            installPackCommand="dnf install"
            updateSystCommand="dnf upgrade"
            break
        ;;
        custom)
            customPackadgeManger
            break
        ;;
        *)
            echo "This packadge manager does not have specified commands to install packadges and update the sytem so you must enter the cammands manually."
            customPackadgeManger
            break
        ;;
    esac
done

read -p "pacadge manager: " packadgeManager

installApp(){
    runIfBool "install $1?" "sudo $packadgeManager install $1"
}

update(){
    sudo $packadgeManager update
}


#apps
echo "==============================UPDATING SYSTEM=============================="
update

echo "==============================INSTALLING APPS=============================="
installApp gnome-tweak-tool
installApp tilda
installApp python3-pip
sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=gitlab.com_paulcarroty_vscodium_repo\nbaseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg" |sudo tee -a /etc/yum.repos.d/vscodium.repo
installApp codium

echo "====================INSTALLING GNOME SHELL EXTENSIONS======================"
installApp gnome-shell-extension-gsconnect

#flutter (code from: https://flutter.dev/docs/get-started/install/linux#additional-linux-requirements)
runIfBool "install flutter?" '
  sudo snap install flutter --classic
  installApp "clang cmake ninja-build pkg-config libgtk-3-dev"
'

