#!/bin/bash

printf "\nHey,Welcome to my script to download all of my configuration! \nDon't execute the script as root \nEnter your root password ! \n"
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

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
sudo apt update 
sudo apt install -y vnstat
sudo systemctl start vnstat.service 
sudo systemctl enable vnstat.service
sudo apt full-upgrade -y 
printf "\n=============\n[1]Upgraded \n=============\n"

sudo apt install -y htop thunar xserver-xorg xinit redshift mousepad vlc nnn neofetch acpi nitrogen curl ffmpeg pkg-config qt5-qmake qtbase5-dev libqt5x11extras5-dev i3 android-sdk-platform-tools build-essential gdb g++ stacer redshift-gtk picom diodon grub-customizer atril ristretto pulseaudio-module-bluetooth yt-dlp lightdm bleachbit maim wireplumber libnotify-bin pandoc kitty zsh steam xsel power-profiles-daemon gamescope obs-studio v4l2loopback-dkms goverlay fonts-font-awesome fonts-noto-color-emoji nethogs xorg x11-xserver-utils

printf "\n=============\n[2]tools installed \n=============\n"

sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="VirtualCam" exclusive_caps=1
powerprofilesctl set balanced
timedatectl set-local-rtc 1
sudo systemctl start bluetooth
sudo update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/i3 60
sudo update-alternatives --set x-session-manager /usr/bin/i3
printf "\n=============\n[3] i3 is the default now\n=============\n"

if [ "$nvidia" = "y" ]; then
	sudo apt install -y nvidia-driver nvidia-cuda-toolkit nvidia-smi
	printf "\n=============\n[4]installed nvidia drivers\n=============\n"
fi

if [ "$brave" = "y" ]; then
	sudo curl -fsS https://dl.brave.com/install.sh | sh
	printf "\n=============\n[5] installed Brave \n=============\n"
fi

if [ "$snapflat" = "y" ]; then
	sudo apt install -y software-properties-common snapd flatpak wine wine64 wine64-tools wine32:i386 winetricks 
	sudo systemctl start snapd.service
	sudo systemctl start snapd.apparmor.service
	sudo snap install chatgpt-desktop-client
	sudo snap install deepseek-desktop
	flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install --noninteractive flathub com.usebottles.bottles
	flatpak install --noninteractive flathub com.rtosta.zapzap
	sudo touch /usr/local/bin/bootles /usr/local/bin/whatsapp
	sudo echo "flatpak run com.usebottles.bottles" >> /usr/local/bin/bootles
	sudo echo "flatpak run com.rtosta.zapzap" >> /usr/local/bin/whatsapp
	printf "\n=============\n[6]installed wine and flatpack and thier sub utilities\n=============\n"
fi

if [ "$zsh" = "y" ]; then
	sudo chsh -s $(which zsh)
	cp d4con/scripts/zshrc /home/$USER/zshrc
	mv /home/$USER/zshrc /home/$USER/.zshrc
	source /home/$USER/.zshrc > /dev/null
	printf "\n=============\n[8] Shell configuration is now loaded \n=============\n"
fi

chmod +x d4con/scripts/*
sudo cp d4con/scripts/numlock /usr/local/bin
sudo mkdir -p /etc/lightdm
sudo cp d4con/scripts/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
cp -r d4con /home/$USER/
mv /home/$USER/d4con /home/$USER/.d4con 
rm -rf /home/$USER/.config/dunst /home/$USER/.config/i3 /home/$USER/.config/i3status /home/$USER/.config/kitty /home/$USER/.config/neofetch /home/$USER/.config/nnn /home/$USER/.config/nitrogen /home/$USER/.config/picom
ln -sf /home/$USER/.d4con/nitrogen  /home/$USER/.config
ln -sf /home/$USER/.d4con/dunst  /home/$USER/.config
ln -sf /home/$USER/.d4con/i3  /home/$USER/.config
ln -sf /home/$USER/.d4con/i3status  /home/$USER/.config
ln -sf /home/$USER/.d4con/kitty  /home/$USER/.config
ln -sf /home/$USER/.d4con/neofetch  /home/$USER/.config
ln -sf /home/$USER/.d4con/nnn  /home/$USER/.config
ln -sf /home/$USER/.d4con/picom /home/$USER/.config
mkdir -p ~/.config/Thunar
cp /home/$USER/.d4con/scripts/Thunar.xml  ~/.config/Thunar
mv ~/.config/Thunar/Thunar.xml ~/.config/Thunar/uca.xml
mkdir -p /etc/X11/xorg.conf.d
sudo cp /home/$USER/.d4con/scripts/90-touchpad.conf /etc/X11/xorg.conf.d

printf "\n=============\n[9]Symbolic links is Created Successfully\n=============\n"
printf "\nSetup completed successfully!\nCheck the Logs folder that is located in Downloads folder for more info! \n"
kill "$SUDO_KEEPALIVE_PID"
