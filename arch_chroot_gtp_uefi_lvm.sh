#!/bin/bash
arch-chroot /mnt <<EOF
    echo 'Часовой пояс'
    ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
    echo 'Синхронизация времени'
    hwclock --systohc --utc
    echo 'Локализация'
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    echo "en_US ISO-8859-1" >> /etc/locale.gen
    echo "ru_UA.UTF-8 UTF-8" >> /etc/locale.gen
    echo "ru_UA KOI8-U" >> /etc/locale.gen
    echo 'Обновляем локализацию'
    locale-gen
    echo 'Настраиваем язык системы'
    echo "LANG=ru_UA.UTF-8" >> /etc/locale.conf
    echo 'Настраиваем шрифт системы'
    echo "KEYMAP=ru" >> /etc/vconsole.conf
    echo "FONT=cyr-sun16" >> /etc/vconsole.conf
    echo 'Настройка hostmane'
    echo "archik" >> /etc/hostname
    echo 'Настройка hosts'
    echo "127.0.0.1	localhost" >> /etc/hosts
    echo "::1		localhost" >> /etc/hosts
    echo "127.0.1.1	archik.localdomain	archik" >> /etc/hosts
    echo 'Настройка initramfs'
    sed -i 's/HOOKS=(base udev autodetect modconf block filesystems     keyboard fsck)/HOOKS=(base udev autodetect modconf block encrypt lvm2   resume filesystems keyboard fsck)/' /etc/mkinitcpio.conf
    echo 'Оновление initramfs'
    mkinitcpio -p linux
    echo 'Устанавливаем пароль рута'
    echo "root:1998" | chpasswd
    echo 'Ставим пакет загрузчика'
    pacman -S grub efibootmgr
    echo 'Создаем директорию для загрузчика'
    mkdir /boot/efi
    echo 'Монтируем диск с загрузчиком'
    mount /dev/sda1 /boot/efi
    echo 'Ставим сам загрузчик на диск'
    grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
    echo 'Настраиваем загрузчик'
    sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT.*|    GRUB_CMDLINE_LINUX_DEFAULT="resume=/dev/mapper/vg_arch-lv_swap cryptdevice=/dev/sda3:vg_arch loglevel=3 quiet"|' /etc/default/grub
    echo 'Обновляем конфиг загрузчика'
    grub-mkconfig -o /boot/grub/grub.cfg
    echo 'Ставим openssh'
    pacman -S openssh
    echo 'Ставим программы для wifi'
    pacman -S wpa_supplicant dialog
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
    echo 'Выходим из установленой системы'
    exit
EOF
