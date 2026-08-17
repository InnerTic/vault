#!/bin/bash
# Extracted from: live-env-setup.sh (Step 3) + REBUILD_SCRIPT.sh (Step 2)
# Single purpose: add data drives to /etc/fstab + bind mounts + mkdir
# Usage: sudo ./fstab-bind-mounts.sh
#
# Idempotent: checks for UUID presence before appending.

set -euo pipefail

# ═══════════════════════════════════════════════════════════
#  CONFIG — change these to match your drive layout
# ═══════════════════════════════════════════════════════════

DATA_DRIVE="/media/ssd_storage"   # <-- swap this: external drive, data-hdd, etc.
USER="ken"                       # <-- swap this: your username

# ═══════════════════════════════════════════════════════════
#  fstab entries (drive UUIDs — update if drives change)
# ═══════════════════════════════════════════════════════════

# Don't re-append drive mounts if entries already exist
if ! grep -q 'UUID=51b4243d' /etc/fstab 2>/dev/null; then
  sudo tee -a /etc/fstab << FSTAB

# ssd_storage
UUID=51b4243d-ea88-4a02-b02f-c286d52b6e0d /mnt/ssd_storage ext4 defaults,nofail 0 2
# Data-HDD
UUID=f0b1d710-a0a6-4ef1-83ce-fc9e55d577d8 /media/HDD_Data btrfs defaults,x-gvfs-show,nofail 0 2
# m2_storage
UUID=e070aea8-a128-4e6d-9e3f-da38a6604dbe /mnt/m2_storage btrfs defaults,nofail 0 2
# nvme-workspace
UUID=9a1cdd8a-3d81-468f-be70-aa00a01d7301 /mnt/workspace ext4 defaults,nofail 0 2
FSTAB
fi

# Add bind mounts (always, idempotent check per entry)
for pair in \
  "$DATA_DRIVE/$USER/Documents /home/$USER/Documents" \
  "$DATA_DRIVE/$USER/Downloads /home/$USER/Downloads" \
  "$DATA_DRIVE/$USER/Pictures /home/$USER/Pictures" \
  "$DATA_DRIVE/$USER/Videos /home/$USER/Videos" \
  "$DATA_DRIVE/$USER/Desktop /home/$USER/Desktop" \
  "$DATA_DRIVE/$USER/Music /home/$USER/Music" \
  "$DATA_DRIVE/$USER/go /home/$USER/go" \
  "$DATA_DRIVE/$USER/MEGA /home/$USER/MEGA"; do
  src="${pair%% *}"
  dst="${pair##* }"
  if ! grep -qF "$src $dst none bind" /etc/fstab 2>/dev/null; then
    echo "$src $dst none bind,nofail 0 0" | sudo tee -a /etc/fstab
  fi
done

# Create mount points
sudo mkdir -p /mnt/{ssd_storage,data,m2_storage,workspace}
sudo mkdir -p "/home/$USER/"{Documents,Downloads,Pictures,Videos,Desktop,Music,go,MEGA}

sudo mount -a

echo "Drives mounted. Verify: df -h | grep /mnt"
