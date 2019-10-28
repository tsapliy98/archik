#!/bin/bash

echo 'Welcome to install Arch Linux'
sleep 2

echo 'Установка раскладки клавиатуры'
loadkeys ru

echo 'Установка шрифта для кирилицы'
setfont cyr-sun16

echo 'Синхронизация системных часов'
timedatectl set-ntp true

sleep 2

read -p 'Желаете разбить диск? [Y|n]: ' disk_settings
if [[ "$disk_settings" -eq "Y" ]]; then
    read -p 'Выберите тип создания дисков: 1 MBR; 2 GPT_UEFI; 3 GPT_UEFI_LVM; ' disks
    if [[ "$disks" -eq 1 ]]; then
        wget https://raw.githubusercontent.com/tsapliy98/archik/master/MBR.sh && sh MBR.sh
    elif [[ "$disks" -eq 2 ]]; then
        wget https://raw.githubusercontent.com/tsapliy98/archik/master/GPT_UEFI.sh && sh GPT_UEFI.sh
    elif [[ "$disks" -eq 3 ]]; then
        wget https://raw.githubusercontent.com/tsapliy98/archik/master/GPT_UEFI_LVM.sh && sh GPT_UEFI_LVM.sh
    fi
elif [[ "$disk_settings" -eq "n" ]]; then
    exit
fi 

sleep 2

read -p 'Выберите форматирование: 1 MBR; 2 GPT_UEFI; 3 GPT_UEFI_LVM' formating
if [[ "$formating" -eq 1 ]]; then
    mkfs.ext2 /dev/sda1
    mkswap /dev/sda2
    mkfs.ext4 /dev/sda3
    mkfs.ext4 /dev/sda4
elif [[ "$formating" -eq 2 ]]; then
    mkfs.vfat /dev/sda1
    mkswap /dev/sda2
    mkfs.ext4 /dev/sda3
    mkfs.ext4 /dev/sda4
elif [[ "$formating" -eq 3 ]]; then
    mkfs.fat -F32 /dev/sda1
    mkfs.ext2 /dev/sda2
    mkswap /dev/vg_arch/lv_swap
    mkfs.ext4 /dev/vg_arch/lv_root
    mkfs.ext4 /dev/vg_arch/lv_home
fi
   
sleep 2 

read -p 'Выберите монтирование: 1 MBR; 2 GPT_UEFI; 3 GPT_UEFI_LVM' mount 
if [[ "$mount" -eq 1 ]]; then
    mount /dev/sda3 /mnt
    mkdir /mnt/boot
    mkdir /mnt/home
    mount /dev/sda1 /mnt/boot
    mount /dev/sda4 /mnt/home
    swapon /dev/sda2
elif [[ "$mount" -eq 2 ]]; then
    mount /dev/sda3 /mnt
    mkdir /mnt/home
    mount /dev/sda1 /mnt/boot
    mount /dev/sda4 /mnt/home
    swapon /dev/sda2
elif [[ "$mount" -eq 3 ]]; then
    swapon /dev/vg_arch/lv_swap
    mount /dev/vg_arch/lv_root /mnt
    mkdir /mnt/boot
    mkdir /mnt/home
    mount /dev/sda2 /mnt/boot
    mount /dev/vg_arch/lv_home /mnt/home
fi

sleep 2

echo 'Выбор зеркал'
cat > /etc/pacman.d/mirrorlist <<"EOF"
## Ukraine
Server = http://mirrors.nix.org.ua/linux/archlinux/$repo/os/$arch
EOF

sleep 2

read -p 'Выберите установку: 1 MBR; 2 GPT_UEFI; 3 GPT_UEFI_LVM' installing
if [[ "$installing" -eq 1 ]]; then
    pacstrap /mnt base base-devel linux linux-firmware linux-headers netctl dhcpcd vim man-db man-pages texinfo vim wget git
elif [[ "$installing" -eq 2 ]]; then
    pacstrap /mnt base base-devel linux linux-firmware linux-headers netctl dhcpcd vim man-db man-pages texinfo vim wget git
elif [[ "$installing" -eq 3 ]]; then
    pacstrap /mnt base base-devel linux linux-firmware linux-headers netctl dhcpcd lvm2 vim man-db man-pages texinfo vim wget git 
fi

sleep 2

echo 'Fstab' 
genfstab -U -p /mnt >> /mnt/etc/fstab

read -p 'Выберите тип установки: 1 MBR; 2 GPT_UEFI; 3 GPT_UEFI_LVM' chrooting
if [[ "$chrooting" -eq 1 ]]; then
    wget https://raw.githubusercontent.com/tsapliy98/archik/master/arch_chroot_mbr.sh && sh arch_chroot_mbr.sh
elif [[ "$chrooting" -eq 2 ]]; then
    wget https://raw.githubusercontent.com/tsapliy98/archik/master/arch_chroot_gpt_uefi.sh && sh arch_chroot_gpt_uefi.sh
elif [[ "$chrooting" -eq 3 ]]; then
    wget https://raw.githubusercontent.com/tsapliy98/archik/master/arch_chroot_gtp_uefi_lvm.sh && sh arch_chroot_gtp_uefi_lvm.sh
fi

echo 'Размонтируем mnt'
umount -R /mnt

echo 'Перезагружаемся'
reboot
    
