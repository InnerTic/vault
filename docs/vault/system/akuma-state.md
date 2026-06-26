---
title: "Akuma State"
tags:
  - system
modified: 2026-06-26
  - akuma-state
---

# Akuma Recovery Log — Derived State

> Computed from raw log. Each phase includes confidence rating.

## Phase Classification

| Phase | Description | Confidence | Source |
|---|---|---|---|
| Pre-2026-04-19 | Original disk layout (sda=/var, sdb=/, nvme0n1=/home) | High | fstab UUIDs match raw log |
| 2026-04-19 | Storage layout overhaul | High | Log header explicitly states date |
| Post-2026-05-13 | Archived reference state | High | Archive timestamp |

## Structural Notes

- **Dual swap**: Physical partition (sdb3) + zram (46.3G) — implies memory pressure management
- **Separate /home on NVMe**: nvme0n1p1 isolated to /home — performance + safety strategy
- **/var on SSD (sda)**: Separated from root (sdb) — prevents log/cache growth from filling root
- **3.6TB NTFS for backup**: Cross-platform (ntfs-3g), uid/gid mapped to user 1001
- **Games on /var via bind mount**: Games moved from /home to /var to keep /home lean

## Derived Inferences (Marked as Inferred)

- Inferred: AMD integrated GPU used when NVIDIA not needed (power saving)
- Inferred: Kernel 6.18 LTS chosen for NVIDIA driver stability (rolling CachyOS can break NVIDIA)
- Inferred: CUDA 13.0 pinned because newer CUDA failed on 6.18 kernel during testing
- Inferred: sdd (465.8G) left unmounted — likely reserved for future use or backup target

## Current vs Archived Status

| Field | Archived (akuma-recovery.log) | Current (system_profile_summary.txt) | Status |
|---|---|---|---|
| Kernel | 6.18.20-1-cachyos-lts | [check system_profile_summary.txt] | Compare |
| NVIDIA Driver | 580.142 | [check system_profile_summary.txt] | Compare |
| CUDA | 13.0 | [check system_profile_summary.txt] | Compare |
| DE | KDE Plasma 6.6.3 | [check system_profile_summary.txt] | Compare |

Derived from: Layer 1 (akuma-raw.md), line 1 "HISTORICAL DOCUMENT — DO NOT USE FOR CURRENT SETUP"
