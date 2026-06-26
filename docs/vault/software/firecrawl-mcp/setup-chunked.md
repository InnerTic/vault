---
title: "Setup Chunked"
tags:
  - software
---

# Firecrawl MCP — Chunked Setup

Install in LXC 108 (searxng). Node already present.

---

## Chunk 0 — Access the container

```bash
# List running containers, check IDs
ssh proxmox pct list

# Expected: 108 searxng (or whatever ID it has)
# If 108 is different, note the actual ID and adjust paths accordingly.

# SSH into the searxng container
ssh proxmox pct enter 108

# Or if SSH is configured on the container:
ssh ken@172.16.12.x
```

**Done when** you're inside the container and can run `ls /mnt/workspace/searxng/`.

---

## Chunk 1 — Create dir + install

```bash
mkdir -p /mnt/workspace/searxng/firecrawl
cd /mnt/workspace/searxng/firecrawl
npm init -y
npm install firecrawl-mcp
```

Verify:

```bash
npx firecrawl-mcp --help
```

**Done when** `firecrawl-mcp --help` prints usage.

---

## Chunk 2 — Env + systemd service

Create `/mnt/workspace/searxng/firecrawl/.env`:

```
FIRECRAWL_API_KEY=
```

Create `~/.config/systemd/user/firecrawl-mcp.service`:

```
[Unit]
Description=Firecrawl MCP server
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/mnt/workspace/searxng/firecrawl
EnvironmentFile=/mnt/workspace/searxng/firecrawl/.env
ExecStart=/home/ken/.local/share/node_modules/.bin/firecrawl-mcp
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

Start:

```bash
systemctl --user daemon-reload
systemctl --user enable --now firecrawl-mcp.service
systemctl --user status firecrawl-mcp.service
```

**Done when** `systemctl --user status` shows `active (running)`.

---

## Chunk 3 — OpenCode config + usage

Add to `mcp` block in `~/.config/opencode/opencode.jsonc`:

```json
"firecrawl": {
  "type": "local",
  "command": ["npx", "firecrawl-mcp"],
  "cwd": "/mnt/workspace/searxng/firecrawl",
  "environment": {
    "FIRECRAWL_API_KEY": "{env:FIRECRAWL_API_KEY}"
  }
}
```

Test in a prompt:

```
scrape https://example.com use firecrawl
```

**Done when** Firecrawl returns scraped content in chat.
