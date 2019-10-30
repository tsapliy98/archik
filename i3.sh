#!/bin/bash

echo 'Создаем нового пользователя'
useradd -m -g users -G audio,lp,optical,power,scanner,storage,video,wheel -s /bin/bash sergey
    
echo 'Пароль нового пользователя'
echo "sergey:1998" | chpasswd
    
echo 'sudoers'
sed -i 's|^# wheel ALL=(ALL) ALL|wheel ALL=(ALL) ALL|' /etc/sudoers
    
echo 'multilib'
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf 
    
echo 'Обновление зеркалов'
pacman -Syy

echo "Установка xorg"
pacman -S xorg-server xorg-apps xorg-xinit

echo "Установка драйверов"
pacman -S xf86-video-intel lib32-intel-dri intel-ucode
    
echo "Установка оконного менеджера"
pacman -S i3-wm i3lock rofi rxvt-unicode 

echo "Экранный менеджер"
pacman -S lightdm lightdm-gtk-greeter

echo "Установка директории пользователя"
acman -S xdg-user-dirs

echo "Обновление директории пользователя"
xdg-user-dirs-update

echo "Установка звука"
pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-equalizer pulseaudio-jack pulseaudio-lirc pulseaudio-zeroconf 

echo "Установка networkmanager"
pacman -S networkmanager network-manager-applet modemmanager  mobile-broadband-provider-info usb_modeswitch  rp-pppoe networkmanager-openconnect 

echo "Установка тачпада"
pacman -S xf86-input-synaptics

echo "Установка шрифтов"
pacman -S ttf-liberation ttf-dejavu ttf-droid 

echo "Установка дополнения bash"
pacman -S bash-completion 

echo "Программа для смены тем"
pacman -S lxappearance 

echo "ЗАпуск программ"
systemctl enable NetworkManager

echo "Выходим из под рута"
exit  
