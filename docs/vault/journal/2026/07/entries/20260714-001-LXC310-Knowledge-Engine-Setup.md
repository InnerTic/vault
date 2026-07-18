---
type: work-entry
id: 20260714-001
status: completed
confidence: high
time_spent: 2h
projects:
  - "[[Knowledge Engine]]"
  - "[[SQLite]]"
daily:
  - "[[2026-07-14]]"
systems:
  - "[[Proxmox]]"
  - "[[Quartz]]"
  - "[[Caddy]]"
scripts:
  - ~/knowledge/bin/knowledge
  - ~/knowledge/bin/knowledge-index
  - ~/knowledge/bin/vault-build.sh
  - ~/knowledge/bin/vault-sync.sh
files:
  - /home/ken/knowledge/db/knowledge.db
  - /home/ken/knowledge/schema.sql
  - /home/ken/quartz/
  - /etc/caddy/Caddyfile
created_pages:
  - "[[2026-07-14]]"
  - "[[20260714-001-LXC310-Knowledge-Engine-Setup]]"
  - "[[20260714-002-Knowledge-Engine-Schema-Indexer]]"
updated_pages:
  - "[[AGENTS]]"
tags:
  - knowledge-engine
  - sqlite
  - infrastructure
  - proxmox
  - lxc
modified: 2026-07-14
---

# 20260714-001 — LXC 310 Knowledge Engine Setup

Date: 2026-07-14

## Goal

Provision LXC 310 (sqlite-test) on Proxmox as the host for the knowledge engine — a combined SQLite + Quartz + Caddy stack that serves the vault as a static site with structured query capabilities.

## Infrastructure

### LXC 310 (sqlite-test)

- **Host**: Proxmox at 172.16.7.1
- **IP**: 172.16.12.20
- **OS**: Debian 12 bookworm
- **Resources**: 2GB RAM, 8GB disk (resized recommended: 16GB)
- **User**: ken (sudo NOPASSWD configured via pct exec)

### Installed Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| SQLite | 3.40 | Structured data store |
| Node.js | 22.23 | Quartz build |
| Quartz | 5.0.0 | Static site generator |
| Caddy | 2.11.4 | Web server |
| llama-server | (port 8081) | Embedding endpoint |

### Quartz Configuration

- `quartz.config.yaml` based on default, customized `baseUrl: 172.16.12.20`
- Plugins: 45 installed (quartz-themes excluded — 252MB repo, filled 8GB disk)
- Content: rsynced from `~/vault/docs/` (excludes `.git`, `.obsidian`)
- Content git repo initialized for `created-modified-date` plugin

### Caddy Configuration

```
:80 {
    root * /home/ken/quartz/public
    handle {
        @trailing path_regexp ^(.+)/$
        rewrite @trailing {re.1}
        try_files {path} {path}.html {path}/index.html
        file_server
    }
    encode gzip zstd
    handle /status { respond "ok" 200 }
}
```

Key fix: `path_regexp` rewrite strips trailing slashes so `try_files` can find `slug.html` files.

## Issues Encountered

1. **Sudo NOPASSWD**: Not configured on the LXC. Fixed via `pct exec 310` from Proxmox host.
2. **Disk full**: `quartz-themes` plugin clone (252MB repo + 1.6GB git objects) filled 8GB disk. Removed plugin and temp files to recover 5GB.
3. **Caddy trailing slash**: Quartz generates `slug.html` but URLs have trailing slashes. Fixed with `path_regexp` rewrite.
4. **OG image plugin**: Fails to fetch fonts in container. Disabled in config.
5. **Plugin install timeout**: `npx quartz plugin install` hangs on large repos. Killed and reran.

## Commands

```bash
# From Proxmox host
pct exec 310 -- bash -c "echo 'ken ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ken"

# From LXC
knowledge status
knowledge build
curl http://172.16.12.20/
curl http://172.16.12.20/status
```

## See Also

- [[20260714-002-Knowledge-Engine-Schema-Indexer]]
- [[Knowledge Engine]]
- [[SQLite]]
