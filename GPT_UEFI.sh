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
        +2G
                y
        n
        ;
        ;
        +20G
                y
        n
        ;
        ;
        ;
                y
        t
        2
        19
        w
EOF