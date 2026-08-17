---
title: "Config Notes"
tags:
  - hardware
modified: 2026-06-26
---

# GPU Configuration — Working Combo (June 2026)

## The Combo

| Component | Version | Source |
|-----------|---------|--------|
| **Driver** | **580.159.04** | pacman (`nvidia-580xx-dkms` + `-utils`) |
| **CUDA Toolkit** | **12.9.1** | pacman (`cuda-12.9`) |
| **llama.cpp** | **b1-64b38b5** | Self-built from `/mnt/workspace/llama.cpp/` |

Both GPUs work with this stack:
- **RTX 3060** (sm_86, 12GB) — port 8080 — Floppa-12B
- **Tesla P40** (sm_61, 24GB) — port 8081 — gpt-oss-20b-hermes

## Why This Works

### Root Cause of Previous CPU Fallback

The system had **two CUDA installations**:
- `/opt/cuda/` — CUDA 12.9 (pacman-managed)
- `~/.local/cuda-12.4/` — old manual install

A stale **`/etc/ld.so.conf.d/cuda-12-4.conf`** pointed to the 12.4 libraries.
`ldconfig` listed them **before** `/opt/cuda/lib64`, so llama.cpp's `libggml-cuda.so`
loaded CUDA 12.4 `libcudart.so.12` / `libcublas.so.12` at runtime instead of 12.9.
The GGML CUDA backend failed silently → fell back to CPU.

### Fix

Removed the config and rebuilt the linker cache:

```
sudo rm /etc/ld.so.conf.d/cuda-12-4.conf
sudo ldconfig
```

Then restarted llama-server — it links against `/opt/cuda/lib64/` (12.9) and
CUDA offloading works on both GPUs.

### Note on sm_61 (Tesla P40) Support

Contrary to the old docs, **CUDA 12.9's nvcc** does compile for sm_61.
The llama.cpp build was configured with:

```
CMAKE_CUDA_ARCHITECTURES=61;86
```

using `/opt/cuda/bin/nvcc` (12.9) at build time. The Pascal P40 works fine
for inference at ~250 t/s prompt / 78 t/s generation.

## Server Layout

```
GPU 0 — RTX 3060    :8080  CUDA_VISIBLE_DEVICES=0  ngl 99
GPU 1 — Tesla P40   :8081  CUDA_VISIBLE_DEVICES=1  ngl 99
```

## Key Files

- **llama.cpp build**: `/mnt/workspace/llama.cpp/build/bin/`
- **Models**: `/home/ken/Downloads/llm_models/`
- **CUDA 12.9**: `/opt/cuda/`

## If You Rebuild llama.cpp

Ensure `cmake -DCMAKE_CUDA_ARCHITECTURES="61;86"` or pass both archs.
The system `/opt/cuda/bin/nvcc` is on PATH and works with GCC 16.

## NVIDIA Driver Architecture Support

This dual-GPU setup (RTX 3060 Ampere + Tesla P40 Pascal) constrains driver choices.
NVIDIA mainline branches drop older architectures over time, so knowing which
branch supports which arch matters for distro migration or driver upgrades.

| Driver Branch | RTX 3060 (Ampere/sm_86) | Tesla P40 (Pascal/sm_61) |
|---------------|--------------------------|---------------------------|
| **580.xx** (legacy) | ✓ | ✓ |
| **590.xx** (mainline) | ✓ | ✗ — drops Pascal |
| **595.xx** (mainline) | ✓ | ✗ — drops Pascal |

The legacy 580.xx branch is the *only* current NVIDIA driver supporting both GPUs
on the same system. Mixed Pascal+Ampere under the 580 branch is confirmed working
on this system (CachyOS, DKMS). A migration to any distro shipping mainline 590+
would break the P40 unless the distro also provides a legacy 580xx package.

## Display Layout — 3 Monitors, Extended (2K main @ native 180 Hz)

**Setup (Akuma, Debian 13, Plasma 6/X11):**
- RTX 3060 drives all three monitors (Tesla P40 is compute-only, no display)
- 2× Samsung LF22T35 (1920×1080) — `HDMI-0` / `DP-1`, stacked on the left
  (`DP-1` on top at `{0,0}`, `HDMI-0` below at `{0,1080}`)
- 1× HKC GQ271NE 2K (2560×1440 native, **primary**) — `DP-2`, on the right at
  `{1920,360}` (vertically centered against the 2160-tall 1080 stack)
- **Mode: EXTENDED** — every monitor shows its own content; the 2K runs at
  **native 2560×1440 @ 180 Hz**. Total virtual screen: 4480×2160.
- Mirror was tried and abandoned as useless — clone forces the 2K down to
  1920×1080 and all screens show the identical picture.

**Live apply (no sudo):**
```
DISPLAY=:0 nvidia-settings -a CurrentMetaMode="DPY-3: 2560x1440_180 +1920+360, DPY-0: nvidia-auto-select @1920x1080 +0+1080, DPY-2: nvidia-auto-select @1920x1080 +0+0"
```
- `DPY-3` = 2K (DP-2), `DPY-0` = HDMI-0, `DPY-2` = DP-1 (from `nvidia-settings -q CurrentMetaMode`).
- `2560x1440_180` = explicit native mode + max refresh. `nvidia-auto-select` alone
  picks 2560×1440 **@60 Hz** — always pass the explicit `_180` for the 2K.

**Persistence files (all agree on the extended layout):**
- `~/.local/share/kscreen/7e4d029d745cdf5a1dca27921cb24c4d` and
  `~/.local/share/kscreen/f1361b63b2799b9fe433ad6359825602` — KScreen profiles:
  HDMI-0 1920×1080@60 `{0,1080}`; DP-1 1920×1080@60 `{0,0}`; DP-2 2560×1440@180 `{1920,360}`.
- `~/.config/kwinoutputconfig.json` — KWin per-output config. DP-2 mode
  2560×1440@180000, scale 1.0; `setups` positions as above.
- Optional belt-and-suspenders: `Option "MetaModes" "DPY-3: 2560x1440_180 +1920+360, DPY-0: nvidia-auto-select @1920x1080 +0+1080, DPY-2: nvidia-auto-select @1920x1080 +0+0"`
  in the `Device0` section of `/etc/X11/xorg.conf`.

**Symptom map:**
- All three screens identical, right-click works everywhere but 2K looks soft →
  mirror/clone mode is active (all positions `{0,0}` in the JSON files). Revert
  to the extended layout above.
- 2K "offset", right-click only works on the bit with the picture → KWin/KScreen
  had the 2K at 2560×1440 but *un-centered* (`y`≈459 instead of 360), or a stale
  scale-1.15 entry for DP-2.
- Plymouth at boot shows hash marks / off-position → GRUB_GFXMODE=1024x768 plus
  the fbcon virtual screen (2560×4320) spanning all 3 monitors. Fix in
  `/etc/default/grub`:
  ```
  GRUB_GFXMODE=1920x1080
  GRUB_GFXPAYLOAD_LINUX=keep
  GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"
  ```
  then `sudo update-grub && sudo update-initramfs -u`.
