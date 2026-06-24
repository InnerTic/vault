# Akuma Recovery Log — Raw Facts (Immutable Log)

Source: `/home/ken/vault/docs/vault/archive/akuma-recovery.log` (pre-2026-04-19 snapshot)

## System Hardware
| Component | Value |
|---|---|
| Manufacturer | ASUS |
| CPU | AMD Ryzen 7 5700G (16 cores) |
| RAM | 48 GiB (46.3 usable) |
| GPU 0 | NVIDIA GeForce RTX 3060 |
| GPU 1 | AMD Radeon Graphics (integrated) |

## OS / Kernel
| Component | Value |
|---|---|
| OS | CachyOS Linux (Arch-based rolling) |
| Kernel | 6.18.20-1-cachyos-lts (64-bit) |
| DE | KDE Plasma 6.6.3 |
| KDE Frameworks | 6.24.0 |
| Qt | 6.11.0 |

## Disk Layout (from `lsblk` at time of snapshot)
| Device | Size | Type | Mount |
|---|---|---|---|
| sda | 465.8G | disk | `/srv` `/var` |
| sdb1 | 105.5G | part | `/` |
| sdb2 | 4.1G | part | `/boot` |
| sdb3 | 9.7G | part | `[SWAP]` |
| sdc2 | 3.6T | part | `/mnt/data` |
| sdd1 | 465.8G | part | (unmounted) |
| nvme0n1p1 | 465.8G | part | `/home` |
| zram0 | 46.3G | disk | `[SWAP]` |

## fstab UUIDs
| Mount | UUID | FS | Options |
|---|---|---|---|
| `/` | d987dca7-90cd-4bbf-9e37-bb90d6e1637d | ext4 | defaults,noatime |
| `/boot` | CEB5-AAD0 | vfat | defaults,umask=0077 |
| swap | 2b82ec28-ca9d-4278-95b3-495aca2271ba | swap | defaults |
| `/home` | 9a1cdd8a-3d81-468f-be70-aa00a01d7301 | ext4 | defaults,noatime |
| `/var` | 4c2a516d-28af-43f7-9936-4157b2652582 | ext4 | defaults,noatime |
| `/mnt/data` | 7E303CAF303C6FEF | ntfs-3g | defaults,uid=1001,gid=1001,noatime,big_writes |

## Bind Mounts
| Source | Target | Type |
|---|---|---|
| `/var/srv_data` | `/srv` | bind |
| `/var/games` | `/home/ken/games` | bind |

## NVIDIA Stack (Pinned)
| Component | Version | Location |
|---|---|---|
| Driver | 580.142 | `/usr/lib/nvidia/`, `/etc/modprobe.d/` |
| CUDA | 13.0 | `/usr/local/cuda-13.0/` |
| cuDNN | 8.x (matching 13.0) | under CUDA path |

## Install Commands (Verified Working)
1. `sudo pacman -Rns nvidia nvidia-utils nvidia-settings nvidia-dkms`
2. `sudo pacman -S nvidia-580xx nvidia-580xx-utils nvidia-settings`
3. `sudo pacman -S cuda-13.0`
4. `nvidia-smi`
5. `sudo nvidia-smi -pm 1`

## Games Migration Commands
1. `sudo mkdir -p /var/games && sudo chown ken:ken /var/games`
2. `rsync -avP /home/ken/games/ /var/games/`
3. `mv /home/ken/games /home/ken/games_old`
4. `mkdir /home/ken/games`
5. `sudo mount -a && ls /home/ken/games`
6. `rm -rf /home/ken/games_old`

## Permissions Strategy
| Path | Command |
|---|---|
| `/var/games` | `sudo chown -R ken:ken /var/games` |
| `/var/ai` | `sudo chown -R ken:ken /var/ai` |

## Archive Metadata
- Archived: 2026-05-13
- Status: "PREVIOUS system before 2026-04-19 storage layout overhaul"
- Purpose: Reference only — does not reflect current setup
