#!/bin/bash
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
        g
        n
        ;
        ;
        +512M
                y
        t
        1
        n
        ;
        ;
        +512M
                y
        n
        ;
        ;
        ;
                y
        t
        3
        31
        w
EOF

echo '------------------------------'

cryptsetup luksFormat /dev/sda3
cryptsetup open --type luks /dev/sda3 lvm
pvcreate --dataalignment 1m /dev/mapper/lvm
vgcreate vg_arch /dev/mapper/lvm
lvcreate -L 4GB vg_arch -n lv_swap
lvcreate -L 30GB vg_arch -n lv_root
lvcreate -l 100%FREE vg_arch -n lv_home
modprobe dm-mod
vgscan
vgchange -ay
