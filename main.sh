#!/bin/bash

if [ "$EUID" -eq 0 ]; then
  echo "ERROR: Please do not run this script with sudo or as root."
  echo "The script will ask for your password when it needs it."
  exit 1
fi

printf "\n Hey, Welcome! Enter your sudo password to begin: \n"
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID' EXIT 


mkdir -p /home/$USER/Downloads/logs
exec > >(tee "/home/$USER/Downloads/logs/full.log") 2> >(tee "/home/$USER/Downloads/logs/errors.log" >&2)

printf "[1|4] Do you have a nvidia gpu ? [y/n] \n"
read -r nvidia
printf "[2|4]Do you want to download brave browser? [y/n] \n"
read -r brave
printf "[3|4]Do you want to install snap, flatpack and all of its related binaries ? [y/n] \n"
read -r snapflat
printf "[4|4]Do you want to export my zsh config to your shell and make zsh is the default? [y/n] \n"
read -r zsh


printf "Beginning the installation\n"

sudo dpkg --add-architecture i386
sudo sed -i 's/ main[[:space:]]*$/ main contrib non-free non-free-firmware/' /etc/apt/sources.list
sudo apt update 
sudo apt install -y vnstat
sudo systemctl start vnstat.service 
sudo systemctl enable vnstat.service
sudo apt full-upgrade -y 

printf "\n=============\n[1]Upgraded \n=============\n"

tools=(
    "htop"
    "thunar"
    "xserver-xorg"
    "xinit"
    "redshift"
    "mousepad"
    "vlc"
    "nnn"
    "acpi"
    "nitrogen"
    "curl"
    "ffmpeg"
    "pkg-config"
    "qt5-qmake"
    "qtbase5-dev"
    "libqt5x11extras5-dev"
    "i3"
    "android-sdk-platform-tools"
    "build-essential"
    "gdb"
    "g++"
    "redshift-gtk"
    "picom"
    "diodon"
    "grub-customizer"
    "atril"
    "ristretto"
    "pulseaudio-module-bluetooth"
    "yt-dlp"
    "lightdm"
    "bleachbit"
    "maim"
    "wireplumber"
    "libnotify-bin"
    "pandoc"
    "kitty"
    "zsh"
    "xsel"
    "power-profiles-daemon"
    "obs-studio"
    "v4l2loopback-dkms"
    "fonts-font-awesome"
    "fonts-noto-color-emoji"
    "nethogs"
    "xorg"
    "x11-xserver-utils"
    "brightnessctl"
    "blueman"
    "network-manager"
    "network-manager-gnome"
    "file-roller"
    "gparted"
    "python3"
    "python3-pip"
    "python3-venv"
    "zsh-autosuggestions"
    "qemu-kvm"
    "libvirt-daemon-system"
    "libvirt-clients"
    "bridge-utils"
    "virt-manager"
    "qemu-guest-agent"
    "mtp-tools"
    "libmtp-runtime"
    "gvfs"
    "gvfs-backends"
    "gvfs-fuse"
    "virtiofsd"
    "imagemagick"
    "fonts-lmodern"
    "lxappearance"
    "numlockx"
)


for tool in "${tools[@]}"; do
    echo "Installing $tool..."
    if sudo apt install -y "$tool"; then
        echo "$tool installed successfully."
    else
        echo "Warning: $tool installation failed. Continuing with next tool."
    fi
done

if [ "$brave" = "y" ]; then
	sudo curl -fsS https://dl.brave.com/install.sh | sh
	printf "\n=============\n Brave installed successfully \n=============\n"
fi


printf "\n=============\n[2]tools installed \n=============\n"

sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="VirtualCam" exclusive_caps=1
powerprofilesctl set balanced
timedatectl set-local-rtc 1
sudo systemctl start bluetooth
sudo adduser $USER libvirt
sudo adduser $USER kvm
sudo usermod -a -G libvirt www-data

sudo update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/i3 60
sudo update-alternatives --set x-session-manager /usr/bin/i3

sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty

printf "\n=============\n[3] i3 is the default now\n=============\n"

if [ "$nvidia" = "y" ]; then
	sudo apt install -y linux-headers-amd64 nvidia-driver firmware-misc-nonfree
	printf "\n=============\n Nvidia drivers installed  \n=============\n"
fi



if [ "$snapflat" = "y" ]; then
	sudo apt install -y snapd flatpak wine wine64 wine64-tools wine32:i386 
	sudo systemctl start snapd.service
	sudo systemctl start snapd.apparmor.service
	flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install --noninteractive flathub com.rtosta.zapzap
	sudo touch /usr/local/bin/whatsapp
	echo "flatpak run com.rtosta.zapzap" | sudo tee /usr/local/bin/whatsapp > /dev/null
	sudo chmod +x /usr/local/bin/whatsapp
	printf "\n=============\n[6]installed wine and flatpack and their sub utilities\n=============\n"
fi


chmod +x d4con/scripts/*
cp -r d4con /home/$USER/.d4con
mkdir -p ~/.config
rm -rf /home/$USER/.config/dunst /home/$USER/.config/i3 /home/$USER/.config/i3status /home/$USER/.config/kitty /home/$USER/.config/neofetch /home/$USER/.config/nitrogen /home/$USER/.config/picom
ln -sf /home/$USER/.d4con/nitrogen  /home/$USER/.config
ln -sf /home/$USER/.d4con/dunst  /home/$USER/.config
ln -sf /home/$USER/.d4con/i3  /home/$USER/.config
ln -sf /home/$USER/.d4con/i3status  /home/$USER/.config
ln -sf /home/$USER/.d4con/kitty  /home/$USER/.config
ln -sf /home/$USER/.d4con/neofetch  /home/$USER/.config
ln -sf /home/$USER/.d4con/picom /home/$USER/.config

sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp /home/$USER/.d4con/scripts/90-touchpad.conf /etc/X11/xorg.conf.d

mkdir -p ~/.themes
tar -xf "/home/$USER/.d4con/scripts/Nordic-darker_theme.tar.xz" -C ~/.themes


tar -xf "/home/$USER/.d4con/scripts/SleekTheme-Dark_grub.tar.xz" -C /tmp/
sudo "/tmp/SleekTheme-Dark/install.sh"

tar -xf "/home/$USER/.d4con/scripts/neofetch-7.1.0.tar.xz" -C /tmp/
cd /tmp/neofetch-7.1.0
sudo make install


if [ "$zsh" = "y" ]; then
	touch ~/.zshenv
	echo 'export ZDOTDIR="$HOME/.d4con/scripts"' > ~/.zshenv
	sudo chsh -s $(which zsh) $USER
	printf "\n=============\n[8] Shell configuration is now loaded \n=============\n"
fi


printf "\n=============\n[9]Symbolic links is Created Successfully\n=============\n"
printf "\nSetup completed successfully!\nCheck the Logs folder that is located in Downloads folder for more info! \n"
kill "$SUDO_KEEPALIVE_PID"