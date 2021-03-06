#!/bin/bash

function print_border {
    local string=$1
    declare -i len
    len=${#string}
    len+=4
    printf "%0.s=" $(seq 1 $len)
    printf "\n"
    printf "| \033[01m$string\e[0m |\n"
    printf "%0.s=" $(seq 1 $len)
    printf "\n"
}

function list_all {
    local list=("$@")
    for i in "${list[@]}";
        do
            printf "==> $i\n"
        done
}

function install_all {
    local install=$1
    shift 1
    for i in "$@";
        do
            printf "\nInstalling $i...\n"
            $install "$i"
            printf "\e[5m\e[36m==>\e[0m $i installed. ✅ \n\n"
        done    
}

function validate_config {
    local positive=$1
    local action=$2
    local check=$3
    local config_test=$($check 2>&1)
    if [ "$config_test" != $positive ]
    then
        $($action)
        config_test=$($check 2>&1)
        if [ "$config_test" = $positive ]
        then
            printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m'$action' ✅ \n\n"
        else
            printf "\n\033[01m\e\033[91m [ERROR]\e[0m '$action' failed\e[0m ❌\n\n"
        fi
    else
        printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m'$action' ✅ \n\n"
    fi
}

clear
cat fig.txt
printf "\n"
print_border "Mac OS-X Setup Script"
printf "\n"
printf "This script will install various packages on the system. \n"
printf "It will also modify various OS settings.\n"
printf "Please refer to README.md for more information.\n\n"

read -p "Press 'CTRL+C' to quit, or any key to continue..."

###############################################################################
#  _                       
# | |__  _ __ _____      __
# | '_ \| '__/ _ \ \ /\ / /
# | |_) | | |  __/\ V  V / 
# |_.__/|_|  \___| \_/\_/ 
###############################################################################

# check internet connection
printf "\n\nChecking for network connection...\n\n"
ping -c 1 -q google.com >& /dev/null
if [ "$?" = 0 ]
then 
    printf "\e[5m\e[36m==>\e[0m Connected to network. ✅ \n\n"
else
    printf "\e[5m\e[36m==>\e[0m No network connection. ❌ \n"
    printf "Please check connection and retry later\n."
    exit 1
fi

# install homebrew unless homebrew install exists
printf "Checking for Homebrew 🍺 installation...\n"

while ! command -v brew &> /dev/null
do
    printf "==> Homebrew not installed. ❌\n\n"
    printf "Installing Homebrew 🍺...\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
done

if command -v brew &> /dev/null
then
    printf "\e[5m\e[36m==>\e[0m Homebrew installed. ✅ \n\n"
fi

# disable brew analytics and update
printf "Disabling Homebrew analytics...\n"
brew analytics off
brew analytics state

printf "Updating Homebrew...\n"
brew update

# install packages
homebrew_formulae=(
    "git"
    "wget"
    "syncthing"
    "coreutils"
    "node"
    "python"
    "pylint"
    "geckodriver"
    "figlet"
    "magic-wormhole"
    "ffmpeg"
    "imagemagick"
    "cowsay"
    "irssi"
    "sqlcipher"
    "sqlite"
    "sl"
)

homebrew_casks=(
    "little-snitch"
    "firefox"
    "gimp"
    "libreoffice"
    "adium"
    "macfuse"
    "veracrypt"
    "signal"
    "visual-studio-code"
)

printf "\nInstalling packages...\n"
install_all "brew install" "${homebrew_formulae[@]}"

printf "\nInstalling casks...\n"
install_all "brew install --cask" "${homebrew_casks[@]}"

printf "\nCleaning up...\n"
brew cleanup

###############################################################################
#        _   _                       _             
#   ___ | |_| |__   ___ _ __   _ __ | | ____ _ ___ 
#  / _ \| __| '_ \ / _ \ '__| | '_ \| |/ / _` / __|
# | (_) | |_| | | |  __/ |    | |_) |   < (_| \__ \
#  \___/ \__|_| |_|\___|_|    | .__/|_|\_\__, |___/
#                             |_|        |___/     
###############################################################################

# install x-code cli
print_border "Installing Xcode..."
xcode-select --install

# install pip packages
pip_packages=(
    "tqdm"
    "pyfiglet"
    "pandas"
    "numpy"
    "beautifulsoup4"
)

printf "\nInstalling pip packages...\n"
list_all "${pip_packages[@]}"
install_all "pip3 install" "${pip_packages[@]}"

# install node modules
npm_packages=(
    "walk"
    "eslint"
    "prettier"
    "musicmetadata"
    "sqlite3"
)

printf "\nInstalling npm packages...\n"
list_all "${npm_packages[@]}"
install_all "npm install" "${npm_packages[@]}"

###############################################################################
#                               __ _       
#   ___  ___    ___ ___  _ __  / _(_) __ _ 
#  / _ \/ __|  / __/ _ \| '_ \| |_| |/ _` |
# | (_) \__ \ | (_| (_) | | | |  _| | (_| |
#  \___/|___/  \___\___/|_| |_|_| |_|\__, |
#                                    |___/ 
###############################################################################

#turn on that firewall
print_border "Enabling firewall..."
a=1
b="sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1"
c="sudo defaults read /Library/Preferences/com.apple.alf globalstate"

validate_config "$a" "$b" "$c"
function print_success {
    local success_msg=$1
    local already_satisfied=$2
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m'$success_msg' ✅ \n\n"
}

#print_border "Enabling stealth mode..."
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode | grep -q "enabled"
[[ "$?" != 0 ]]  && echo "Not Enabled" || echo "Enabled"

#set stealth mode (don't respond to ping)
print_border "Enabling stealth mode..."
if ! /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode | grep -q "enabled";
then
    /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on && 
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m'Stealth mode enabled' ✅ \n\n"
else
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m (Already Satisfied) 'Stealth mode enabled' ✅ \n\n"
fi

#disable remote login
print_border "Disabling remote login..."
if sudo systemsetup -getremotelogin | grep "On";
then
    sudo systemsetup -setremotelogin off && 
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m'Remote Login Off' ✅ \n\n"
else
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m (Already Satisfied) 'Remote Login Off' ✅ \n\n"
fi

#disable guest login
print_border "Disabling guest login..."
a=0
b="sudo defaults write /Library/Preferences/com.apple.loginwindow.plist GuestEnabled 0"
c="sudo defaults read /Library/Preferences/com.apple.loginwindow.plist GuestEnabled"

validate_config "$a" "$b" "$c"

#turn off bluetooth and restart daemon
print_border "Disabling bluetooth..."
a=0
b="sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0"
c="sudo defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState"

validate_config "$a" "$b" "$c"

printf "\nStopping bluetooth daemon...\n"
sudo launchctl stop com.apple.bluetoothd
printf "Restarting bluetooth daemon...\n\n"
sudo launchctl start com.apple.bluetoothd

#require password immediately after sleep or screen saver begins
print_border "Require password on screen saver..."
a=1
b="sudo defaults write com.apple.screensaver askForPassword -int 1"
c="sudo defaults read com.apple.screensaver askForPassword"

validate_config "$a" "$b" "$c"

print_border "Set password delay to 0..."
a=0
b="sudo defaults write com.apple.screensaver askForPasswordDelay -int 0"
c="sudo defaults read com.apple.screensaver askForPasswordDelay"

validate_config "$a" "$b" "$c"

#set display sleep to 10 mins
print_border "Set display sleep to 10 mins..."
if ! sudo systemsetup -getdisplaysleep | grep -q "after 10 minutes";
then
    $(sudo pmset -a displaysleep 10) && 
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m 'Display Sleep: after 10 minutes' ✅ \n\n"
else
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m(Already Satisfied) 'Display Sleep: after 10 minutes' ✅ \n\n"
fi

#set computer + hdd sleep to 20 mins
print_border "Set computer sleep to 20 mins..."
if ! sudo systemsetup -getcomputersleep | grep -q "after 20 minutes";
then
    $(sudo systemsetup -setcomputersleep 20) && 
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m 'Computer Sleep: after 20 minutes' ✅ \n\n"
else
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m(Already Satisfied) 'Computer Sleep: after 20 minutes' ✅ \n\n"
fi

print_border "Set HDD sleep to 20 mins..."
if ! sudo systemsetup -getharddisksleep | grep -q "Hard Disk Sleep: after 20 minutes";
then
    $(sudo systemsetup -setharddisksleep 20) && 
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m'Hard Disk Sleep: after 20 minutes' ✅ \n\n"
else
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m'(Already Satisfied) Hard Disk Sleep: after 20 minutes' ✅ \n\n"
fi

#disable wake on network access
print_border "Disable wake on network access..."
if sudo systemsetup -getwakeonnetworkaccess | grep -q "Wake On Network Access: On";
then
    sudo systemsetup -setwakeonnetworkaccess off && 
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m 'Wake On Network Access: Off' ✅ \n\n"
else
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m(Already Satisfied) 'Wake On Network Access: Off' ✅ \n\n"
fi

#use network time
print_border "Use network time..."
if sudo systemsetup -getusingnetworktime | grep -q "Off";
then
    sudo systemsetup -setusingnetworktime on && 
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m 'Network Time: On' ✅ \n\n"
else
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m(Already Satisfied) 'Network Time: On' ✅ \n\n"
fi

#use network time
print_border "Disable Apple remote events..."
if sudo systemsetup -getremoteappleevents | grep -q "On";
then
    sudo systemsetup -setremoteappleevents off && 
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m'Remote Apple Events: Off' ✅ \n\n"
else
    printf "\n\033[01m\033[32m[SUCCESS]\e[0m \n\e[5m\e[36m==>\e[0m(Already Satisfied) 'Remote Apple Events: Off' ✅ \n\n"
fi

#show extensions
print_border "Show all file extensions..."
a=1
b="sudo defaults write NSGlobalDomain AppleShowAllExtensions -bool true"
c="sudo defaults read NSGlobalDomain AppleShowAllExtensions"

validate_config "$a" "$b" "$c"

#show status bar and path bar in finder
print_border "Show status bar and path bar in Finder..."
a=1
b="sudo defaults write com.apple.finder ShowStatusBar -bool true"
c="sudo defaults read com.apple.finder ShowStatusBar"

validate_config "$a" "$b" "$c"

a=1
b="sudo defaults write com.apple.finder ShowPathbar -bool true"
c="sudo defaults read com.apple.finder ShowPathbar"

validate_config "$a" "$b" "$c"

#full path in title
print_border "Show full POSIX path in Finder title..."
a=1
b="sudo defaults write com.apple.finder _FXShowPosixPathInTitle -bool true"
c="sudo defaults read com.apple.finder _FXShowPosixPathInTitle"

validate_config "$a" "$b" "$c"

#folders on top when sorting by name
print_border "Show folders on top when sorting by name..."
a=1
b="sudo defaults write com.apple.finder _FXSortFoldersFirst -bool true"
c="sudo defaults read com.apple.finder _FXSortFoldersFirst"

validate_config "$a" "$b" "$c"

#don't create .ds_store on usb/network drives
print_border "Don't create .DS_Store on USB drives..."
a=1
b="sudo defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true"
c="sudo defaults read com.apple.desktopservices DSDontWriteUSBStores"

validate_config "$a" "$b" "$c"

print_border "Don't create .DS_Store on network drives..."
a=1
b="sudo defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true"
c="sudo defaults read com.apple.desktopservices DSDontWriteNetworkStores"

validate_config "$a" "$b" "$c"

#no requests for time machine on new disks
print_border "Don't request Time Machine on new disks..."
a=1
b="sudo defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true"
c="sudo defaults read com.apple.TimeMachine DoNotOfferNewDisksForBackup"

validate_config "$a" "$b" "$c"

#no requests for time machine on new disks
print_border "Disable mail animations..."
a=1
b="defaults write com.apple.mail DisableReplyAnimations -bool true"
c="defaults read com.apple.mail DisableReplyAnimations"

validate_config "$a" "$b" "$c"

a=1
b="defaults write com.apple.mail DisableSendAnimations -bool true"
c="defaults read com.apple.mail DisableSendAnimations"

validate_config "$a" "$b" "$c"



cat done.txt