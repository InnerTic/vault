---
title: "System Profile Cachyos"
tags:
  - archive
modified: 2026-06-26
---

this file needs to be current if possible using a combination of tools to gather data

# System Profile Summary - Akuma
## Extracted from akuma_recovery.log for portable configuration reference
## Focus: Hardware specs, desktop environment, and general setup (not hardware-specific UUIDs)

## System Overview
- **OS**: CachyOS Linux
- **Kernel**: 6.18.20-1-cachyos-lts (LTS)
- **Desktop Environment**: KDE Plasma 6.6.3
- **KDE Frameworks**: 6.24.0
- **Qt**: 6.11.0
- **Manufacturer**: ASUS
- **CPU**: 16 × AMD Ryzen 7 5700G
- **RAM**: 48 GiB (46.3 GiB usable)

## Graphics Configuration
- **Primary GPU**: NVIDIA GeForce RTX 3060
  - **Driver**: 580.142
- **Secondary GPU**: AMD Radeon Graphics (integrated)

## Storage Approach (General Pattern)
*Note: Specific UUIDs and partition sizes will vary by hardware*
- **Root Partition**: ext4 (noatime)
- **Boot Partition**: vfat (umask=0077)
- **Swap Partition**: swap
- **Home Partition**: ext4 (noatime)
- **Data/Storage Partition**: ext4 (noatime) - previously mounted at /var
- **Long-term Backup**: NTFS-3G partition (defaults,uid=1001,gid=1001,umask=000,noatime,big_writes,nofail)
- **Bind Mounts Used**:
  - /var/srv_data → /srv
  - /var/games → /home/ken/games

## Notable Mount Points from Previous Setup
- /srv → /var/srv_data (bind mount)
- /home/ken/games → /var/games (bind mount)
- /mnt/data → 3.6TB HDD (NTFS-3G for long-term backup)

## Installed Package Categories (from cachyos_packages.txt)
*See clean_package_list.txt for detailed breakdown*
- AI/Development: opencode, cuda, cudnn, python, git, cmake, go, etc.
- Terminal/Shell: alacritty, tmux, micro, nano, zsh, etc.
- Monitoring: btop, bottom, nvtop, glances, conky, fastfetch
- Fonts: Noto fonts, cantarell, ttf-bitstream-vera, etc.
- Media: vlc, gstreamer plugins, ffmpeg, etc.
- Storage: btrfs, xfs, rsync, exfat, ntfs, etc.
- Networking: bind, nfs, netctl, xl2tpd, etc.
- Utilities: meld, pcmanfm, unrar, filelight, kio-admin, etc.
- KDE/Plasma: kdialog, kwalletmanager, phonon-qt6-vlc, poppler-glib, xsettingsd, accountsservice, hyprland
- System/Hardware: flatpak, fwupd, smartmontools, hdparm, mesa-utils, nvtop, ethtool
- Audio: pavucontrol
- Archive/Compression: libdvdcss, libgsf, libopenraw
- Documentation: perl, s-nail, logrotate, plocate
- Other: bazaar, duf, dxvk-mingw-git, e2fsprogs, mdadm, mtools, nilfs-utils, sg3_utils, sysfsutils, upower, usb_modeswitch

## Configuration Philosophy
- Preference for bleeding-edge but stable packages (CachyOS)
- Focus on AI/development workflow with terminal-first approach
- KDE Plasma desktop with customizations
- Hybrid GPU setup (NVIDIA primary
