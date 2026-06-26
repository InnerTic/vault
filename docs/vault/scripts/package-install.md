---
title: "Package Install"
tags:
  - scripts
modified: 2026-06-26
---

# package-install.sh

```bash
#!/bin/bash
# Extracted from: live-env-setup.sh (Step 2) + REBUILD_SCRIPT.sh (Step 1)
# Single purpose: install system + app packages from pkglist
# Usage: sudo ./package-install.sh [/path/to/pkglist-debian.txt]

set -euo pipefail

# ═══════════════════════════════════════════════════════════
#  CONFIG — change these to match your system
# ═══════════════════════════════════════════════════════════

PKGLIST="${1:-$HOME/vault/docs/vault/software/packages/pkglist-debian.txt}"
PKG_MANAGER="apt"         # <-- swap: apt (Debian) or pacman (CachyOS)
DISTRO_PKGS=(             # <-- swap: base packages for your distro
  ntfs-3g btrfs-progs xfsprogs
  build-essential cmake git
)
# For CachyOS, use instead:
# PKG_MANAGER="pacman"
# DISTRO_PKGS=(base-devel cmake git)

# ═══════════════════════════════════════════════════════════

if [ "$PKG_MANAGER" = "apt" ]; then
  sudo apt update
  sudo apt install -y "${DISTRO_PKGS[@]}"
elif [ "$PKG_MANAGER" = "pacman" ]; then
  sudo pacman -S --needed "${DISTRO_PKGS[@]}"
fi

# App packages
if [[ -f "$PKGLIST" ]]; then
  echo "Installing app packages from $PKGLIST..."
  if [ "$PKG_MANAGER" = "apt" ]; then
    grep -v '^\s*#' "$PKGLIST" | grep -v '^\s*$' | sudo xargs apt install -y 2>/dev/null || true
  elif [ "$PKG_MANAGER" = "pacman" ]; then
    grep -v '^\s*#' "$PKGLIST" | grep -v '^\s*$' | sudo xargs pacman -S --needed 2>/dev/null || true
  fi
else
  echo "Package list not found at $PKGLIST, skipping."
fi

echo "Package install complete."
```
