---
title: "Proxmox Gold Image Builder"
tags:
  - projects
modified: 2026-06-26
---

# Proxmox Gold Image Builder

**Type:** Architecture · **Updated:** 2026-06-21

Replace repeated `pct create + install + configure` with a single prebuilt Debian template cloned in seconds.

## Concept

```
build template once → snapshot as GOLD → clone forever
pct clone GOLD → instant ready system
```

## Base Template Build

Script at `~/infra/build-gold-lxc.sh` (canonical: `vault/dotfiles/scripts/build-gold-lxc.sh`):

- Creates VMID 9000 from Debian 12 standard template
- Installs base packages (sudo, curl, git, vim, openssh-server, ca-certificates)
- Creates user `ken` with sudo
- Enables SSH
- Cleans temp state
- Converts to template

## Clone from Gold

```bash
pct clone 9000 300 --hostname quartz-test --full
pct clone 9000 301 --hostname hermes-sandbox --full
pct set 300 -net0 name=eth0,bridge=vmbr0,ip=dhcp
pct start 300
```

## Benefits

| Before | After |
|--------|-------|
| Slow: install every time | Fast: clone in seconds |
| Fragile: runtime differences | Consistent: identical environments |
| Agent-risk: setup varies per container | Safe: no install-time drift |

## Optional Hardening

- `passwd -l root` — remove password login
- `/etc/ssh/sshd_config`: `PasswordAuthentication no`, `PermitRootLogin no`
- Auto snapshot on clone
- Auto IP tagging (.12.x promotion)
