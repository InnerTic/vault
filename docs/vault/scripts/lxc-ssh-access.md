---
title: "Lxc Ssh Access"
tags:
  - scripts
---

# SSH Key Distribution for LXCs

**Type:** Ops · **Updated:** 2026-06-21

Strategy for seamless SSH access from desktop to every LXC without passwords or manual key injection.

## Three-Layer Strategy

1. **Proxmox host** (entry point) — SSH key already present
2. **Proxmox SSH jump** — connect to containers via `pct exec` or SSH inside
3. **Template-based auto key injection** — every new LXC automatically receives SSH key

## Key Injection at Creation

```bash
pct create 200 local:vztmpl/debian-12-standard*.tar.zst \
  --hostname quartz \
  --ssh-public-keys /root/.ssh/authorized_keys
```

This is the clean Proxmox-native method — every LXC gets the key at creation time.

## Gold Template Method

Create template with key pre-injected:

```bash
pct create 9000 local:vztmpl/debian-12-standard*.tar.zst \
  --hostname base-template \
  --ssh-public-keys /root/.ssh/authorized_keys \
  --unprivileged 1 --features nesting=1
pct template 9000
pct clone 9000 201 --hostname quartz
```

## SSH Config Aliases

```text
Host proxmox
    HostName 172.16.7.1
    User root
    IdentityFile ~/.ssh/id_ed25519

Host lxc-quartz
    HostName 172.16.7.1
    User root
    IdentityFile ~/.ssh/id_ed25519
    ProxyCommand ssh proxmox pct exec 200 -- ssh -W %h:%p %h
```

## Alternative: Direct SSH

Install SSH server in each LXC and connect by IP:

```bash
pct exec <ID> -- apt install -y openssh-server
pct exec <ID> -- systemctl enable --now ssh
ssh root@<container-ip>
```

## Future

- `lxc ssh quartz` — one-command access script
- Auto-IP registry — containers self-register names
- Full bootstrap pipeline: `pct create → auto key inject → auto bootstrap → auto service`
