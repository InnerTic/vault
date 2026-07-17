---
title: "Drives And Mounts"
tags:
  - system
  - drives-and-mounts
aliases: [drives, mounts, fstab, storage-layout]
modified: 2026-07-17
---

# Drives & Mounts

Physical drive layout, UUIDs, fstab entries, bind mounts, and symlinks.

**Active boot**: CachyOS (gaming / AI workstation). Debian/MX layout preserved in [[#debian-mx-linux-boot-historical|Debian section]].

## CachyOS Drive Inventory

| Device | Size | FS | Mount | Purpose |
|--------|------|----|-------|---------|
| **sda1** | 4.1G | vfat | `/boot` | EFI boot partition |
| **sda2** | 115G | btrfs | `/` (subvol @) | OS root — subvolumes: @root, @srv, @cache, @tmp, @log |
| **sdb1** | 465G | ext4 | `/mnt/ssd_storage` | Bulk data — documents, downloads, media |
| **sdc1** | 3.6T | btrfs | `/mnt/data` | HDD — model storage, backups, large files |
| **sdd1** | 112G | btrfs | `/home` | User home directory |
| **sde1** | 256M | vfat | — | MX Linux EFI (not mounted normally) |
| **sde2** | 48G | btrfs | — | MX Linux root (rootMX25) |
| **sde3** | 186G | btrfs | — | MX Linux home (homeMX) |
| **sde4** | 243G | xfs | `/mnt/vm-disks` | VM disk storage |
| **sdf** | 466G | ext4 | — | Old Debian drive (unmounted, historical) |
| **sdg** | 58G | — | — | USB / transient (varies) |
| **nvme0n1p1** | 465G | ext4 | `/mnt/workspace` | AI tools, llama.cpp, projects, dotfiles (persistent) |

## CachyOS UUIDs (Active /etc/fstab)

| Mount | UUID | FS |
|-------|------|----|
| sda1 /boot | `C3E7-93C2` | vfat |
| sda2 / | `76c0155f-a646-40b6-8fec-ae64fcc4a037` | btrfs |
| sdb1 /mnt/ssd_storage | `51b4243d-ea88-4a02-b02f-c286d52b6e0d` | ext4 |
| sdc1 /mnt/data | `f0b1d710-a0a6-4ef1-83ce-fc9e55d577d8` | btrfs |
| sdd1 /home | `e070aea8-a128-4e6d-9e3f-da38a6604dbe` | btrfs |
| sde4 /mnt/vm-disks | `58f7f216-4c23-47ab-8cea-8b524bc3eab7` | xfs |
| nvme0n1p1 /mnt/workspace | `9a1cdd8a-3d81-468f-be70-aa00a01d7301` | ext4 |

## Root Btrfs Subvolumes

| Subvolume | Mount | Purpose |
|-----------|-------|---------|
| `@` | `/` | OS root |
| `@root` | `/root` | Root home |
| `@srv` | `/srv` | Server data |
| `@cache` | `/var/cache` | Package cache |
| `@tmp` | `/var/tmp` | Temporary files |
| `@log` | `/var/log` | System logs |
| — | `/tmp` | tmpfs (ram) |

## Bind Mounts (/etc/fstab)

ssd_storage directories bind-mounted into home:

| Source | Target |
|--------|--------|
| `/mnt/ssd_storage/ken/Documents` | `/home/ken/Documents` |
| `/mnt/ssd_storage/ken/Downloads` | `/home/ken/Downloads` |
| `/mnt/ssd_storage/ken/Pictures` | `/home/ken/Pictures` |
| `/mnt/ssd_storage/ken/Videos` | `/home/ken/Videos` |
| `/mnt/ssd_storage/ken/Desktop` | `/home/ken/Desktop` |
| `/mnt/ssd_storage/ken/Music` | `/home/ken/Music` |
| `/mnt/ssd_storage/ken/go` | `/home/ken/go` |
| `/mnt/ssd_storage/ken/MEGA` | `/home/ken/MEGA` |

## Symlinks in ~/

| Symlink | Target | Purpose |
|---------|--------|---------|
| `~/ssd_storage` | `/mnt/ssd_storage` | Quick access to bulk storage |
| `~/workspace` | `/mnt/workspace` | Primary work directory |
| `/workspace` | `/mnt/workspace` | Steam Proton Z: drive compat |
| `~/Downloads/llm_models` | `/mnt/data/model_storage` | Canonical GGUF store (HDD) |
| `~/dotfiles` | `/mnt/workspace/dotfiles` | Dotfiles mirror |

## Workspace Persistence

`/mnt/workspace` (nvme-workspace) is the **only drive that never gets formatted**.
It holds:
- `dotfiles/` — this repo (mirror of vault/dotfiles/)
- `llama.cpp/` — build + source
- `sd-webui-forge-neo/` — Stable Diffusion
- `textgen/` — TextGen WebUI
- `searxng/` — search engine

## 2026-07-17 fstab fixes

During CachyOS system restore, two fstab entries were stale:

| Mount | Old UUID | New UUID | Change |
|-------|----------|----------|--------|
| /mnt/data | `7E303CAF303C6FEF` | `f0b1d710-a0a6-4ef1-83ce-fc9e55d577d8` | ntfs-3g → btrfs, UUID changed after reformat |
| /mnt/vm-disks | `446695a8-1348-4d45-ab10-5af0a5bf1ae5` | `58f7f216-4c23-47ab-8cea-8b524bc3eab7` | Partition index changed (sde3→sde4), UUID changed |

Both were auto-mounted by KDE at `/run/media/ken/*` instead of `/mnt/*` before the fix. Now correctly mounted at their `/mnt` paths via fstab.

## Debian / MX Linux Boot (HISTORICAL)

When booted into Debian, drive letters and assignments differ. This section preserved for cross-reference when dual-booting.

### Debian Drive Inventory

| Device | Size | FS | Mount | Purpose |
|--------|------|----|-------|---------|
| sdb1 | 465G | ext4 | `/mnt/ssd_storage` | Bulk data |
| sdc1 | 3.6T | btrfs | `/mnt/m2_storage` | Secondary storage |
| sdd2 | 222G | ext4 | `/` (root) | OS root (rootMX25, Debian 13 trixie) |
| sdd3 | 243G | xfs | `/media/ken/81132c1e...` | USB mount (was vm-disks) |
| nvme0n1p1 | 465G | ext4 | `/mnt/workspace` | AI tools, projects |

### Debian UUIDs

| Mount | UUID | FS |
|-------|------|----|
| sdd2 / (root) | `34bdf920-237c-4392-835f-0416be09ada5` | ext4 |
| sdb1 /mnt/ssd_storage | `51b4243d-ea88-4a02-b02f-c286d52b6e0d` | ext4 |
| nvme /mnt/workspace | `9a1cdd8a-3d81-468f-be70-aa00a01d7301` | ext4 |

## Drive Selection Guide

| Use case | Drive | Why |
|----------|-------|-----|
| OS, packages, temp | sda2 (/) | Btrfs snapshots for rollback |
| AI models, projects | nvme (workspace) | Fast NVMe, persists reinstalls |
| Model GGUFs (canonical) | sdc (/mnt/data) | 3.6T btrfs, all GGUFs stored here |
| Documents, media | sdb (ssd_storage) | Large SSD, bind-mounted to ~/ |
| VMs, disk images | sde4 (vm-disks) | Dedicated xfs partition |
| User configs | sdd (/home) | Btrfs, regular backups recommended |

## Related

- [[reference/lspci-akuma-output]] — PCI topology showing which drives are on which bus
- [[reference/workspace-symlink-strategy]] — What lives on workspace and how it's linked into /home
