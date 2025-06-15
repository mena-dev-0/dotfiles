#!/bin/bash

printf "\nHey,Welcome to my script to download all of my configuration! \nDon't execute the script as root \nEnter your root password ! \n"
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

mkdir -p /home/$USER/Downloads/logs
exec > >(tee "/home/$USER/Downloads/logs/full.log") 2> >(tee "/home/$USER/Downloads/logs/errors.log" >&2)
cd /home/$USER/Downloads/

printf "[1|5] Do you have a nvidia gpu ? [y/n] \n"
read -r nvidia
printf "[2|5]Do you want to download chrome ? [y/n] \n"
read -r chrome
printf "[3|5]Do you want to install snap and flatpack ? [y/n] \n"
read -r snapflat
printf "[4|5]Do you want to install simple screen recorder (ssr) ? [y/n] \n"
read -r ssr
printf "[5|5]Do you want to export my config to your zsh shell ? [y/n] \n"
read -r zsh
printf "Beginning the installation\n"

sudo dpkg --add-architecture i386
sudo apt update 
sudo apt full-upgrade -y 

printf "\n=============\n[1]Upgraded \n=============\n"

sudo apt install -y htop redshift vlc nnn neofetch vnstat acpi nitrogen ffmpeg pkg-config qt5-qmake qtbase5-dev libqt5x11extras5-dev i3 fonts-noto android-sdk-platform-tools build-essential gdb g++ stacer redshift-gtk picom diodon grub-customizer atril ristretto pulseaudio-module-bluetooth yt-dlp lightdm bleachbit maim virtualbox  wireplumber libnotify-bin pandoc kitty zsh git wget steam xsel power-profiles-daemon gamescope
printf "\n=============\n[2]tools installed \n=============\n"

powerprofilesctl set balanced
timedatectl set-local-rtc 1
sudo systemctl start vnstat.service 
sudo systemctl enable vnstat.service
sudo systemctl start bluetooth
update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/i3 60
update-alternatives --set x-session-manager /usr/bin/i3
printf "\n=============\n[3] i3 is the default now\n=============\n"

if [ "$nvidia" = "y" ]; then
	sudo apt install -y nvidia-driver nvidia-cuda-toolkit nvidia-smi
	printf "\n=============\n[4]installed nvidia drivers\n=============\n"
fi

if [ "$chrome" = "y" ]; then
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	sudo apt install -f -y
	sudo mv /etc/apt/sources.list.d/google-chrome.list /etc/apt/sources.list.d/google-chrome.list.stop-updating
	sudo apt purge -y chromium*  firefox-esr
	printf "\n=============\n[5] installed chrome. Firefox removed\n=============\n"
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

if [ "$ssr" = "y" ]; then
	
	git clone https://github.com/MaartenBaert/ssr.git
	sudo apt install -y build-essential cmake pkg-config desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev \
	qt5-qmake qttools5-dev qtbase5-dev libqt5x11extras5-dev libavformat-dev libavcodec-dev libavutil-dev \
	libswscale-dev libasound2-dev libpulse-dev libjack-dev libx11-dev libxext-dev libxfixes-dev libxi-dev \
	libxinerama-dev libv4l-dev g++-multilib libgl1-mesa-dev:i386 libglu1-mesa-dev:i386 libx11-dev:i386 libxfixes-dev:i386
	chmod +x ssr/simple-build-and-install
	ENABLE_32BIT_GLINJECT=FALSE ./ssr/simple-build-and-install
	printf "\n=============\n[7]SSR in now installed\n=============\n"
fi

if [ "$zsh" = "y" ]; then
	cat .d4con/scripts/shell.txt >> /home/$USER/.zshrc
	printf "\n=============\n[8] Shell configuration is now loaded \n=============\n"
fi

sudo cp .d4con/scripts/numlock /usr/local/bin
cp -r .d4con /home/$USER/
rm -rf /home/$USER/.config/dunst /home/$USER/.config/i3 /home/$USER/.config/i3status /home/$USER/.config/kitty /home/$USER/.config/neofetch /home/$USER/.config/nnn
ln -sf /home/$USER/.d4con/dunst  /home/$USER/.config
ln -sf /home/$USER/.d4con/i3  /home/$USER/.config
ln -sf /home/$USER/.d4con/i3status  /home/$USER/.config
ln -sf /home/$USER/.d4con/kitty  /home/$USER/.config
ln -sf /home/$USER/.d4con/neofetch  /home/$USER/.config
ln -sf /home/$USER/.d4con/nnn  /home/$USER/.config
mkdir -p /etc/X11/xorg.conf.d
sudo cp /home/$USER/.d4con/scripts/90-touchpad.conf /etc/X11/xorg.conf.d

printf "\n=============\n[9]Symbolic links is Created Successfully\n=============\n"

printf "\nSetup completed successfully!\nCheck the Logs folder for more info! \n"
kill "$SUDO_KEEPALIVE_PID"
