---
title: "Vault Driven Container Profiles"
tags:
  - projects
modified: 2026-06-26
  - vault-driven-container-profiles
---

# Vault-Driven Container Profiles

**Type:** Architecture · **Updated:** 2026-06-21

Move from imperative provisioning scripts to declarative container profiles defined in the vault.

## Core Idea

The vault stops being documentation of systems. It becomes the **source of truth for machine state**. Everything else is a projection:

```
vault → Proxmox LXC
vault → dotfiles runtime
vault → infra execution layer
vault → Quartz site
```

## Container Profiles

A declarative spec at `vault/profiles/lxc/<name>.yaml`:

```yaml
name: quartz-test
base: debian-12
mode: fish
packages:
  - git
  - curl
  - nodejs
  - npm
components:
  - core
  - fonts
  - fish
  - aliases
infra:
  - lxc-bootstrap
  - llama-server (optional)
network:
  expose:
    - 8080
post_install:
  - git clone https://github.com/quartz
  - npm install
  - npm run build
```

## Bootstrap Script → Compiler

Instead of `lxc-bootstrap.sh --fish`:

```
vault compile profiles/lxc/quartz.yaml --target proxmox
```

Which produces: LXC config, install order, executed scripts, final state validation.

## Architecture

```
vault.git (profiles + dotfiles + infra spec)
  ├── LXC Compiler → Proxmox CT
  ├── Dotfiles Mirror → User Environment
  └── Quartz Builder → Wiki Site
```

## Design Constraint

Separate three layers:
1. **Profile** (intent) — what the system should be
2. **Components** (mechanism) — how it is installed
3. **Execution** (runtime) — what actually runs inside LXC

If these mix, drift returns.

## Migration Plan

1. Add `vault/profiles/lxc/` directory
2. Convert ONE container first (quartz-test)
3. Keep `lxc-bootstrap.sh` but call it from compiler
4. Introduce `vault-compile.sh profile.yaml` wrapper
