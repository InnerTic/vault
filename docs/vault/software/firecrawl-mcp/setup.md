---
title: "Setup"
tags:
  - software
modified: 2026-06-26
---



rethink the setup form the ground up. this is a searxng container made with a community script. ITS A CONTAINER UNDER PROXMOX. LXC has no /mnt/workspace thats spicificlly Akuma and its OS's have that



# Firecrawl MCP Setup

Web ingestion MCP server — converts URLs to clean markdown, extracts structured data, searches the web. Runs alongside SearXNG in LXC 108.

## Container

| Property | Value |
|---|---|
| LXC ID | 108 |
| Hostname | searxng |
| Service type | user systemd |
| Install root | `/mnt/workspace/searxng/firecrawl/` |

Co-located with SearXNG because both are web-ingestion services. SearXNG finds URLs, Firecrawl fetches + converts them.

## Install

```bash
# Create directory
mkdir -p /mnt/workspace/searxng/firecrawl

# Pin local install (more reproducible than npx -y every time)
cd /mnt/workspace/searxng/firecrawl
npm init -y
npm install firecrawl-mcp
```

Verify:

```bash
npx firecrawl-mcp --help
```

## Configuration

### Env file

`/mnt/workspace/searxng/firecrawl/.env`:

```
# Only needed for hosted Firecrawl (api.firecrawl.dev).
# Leave empty or unset for self-hosted.
FIRECRAWL_API_KEY=
```

### Service file

`~/.config/systemd/user/firecrawl-mcp.service`:

```
[Unit]
Description=Firecrawl MCP server — web ingestion
After=network-online.target
Wants=network-online.target

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

## MCP Client Config

Add to `~/.config/opencode/opencode.jsonc`:

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

Use in prompts:

```
scrape https://example.com/docs/page use firecrawl
search for proxmox lxc networking guide use firecrawl
extract the install steps from this page use firecrawl
```

## Directory layout

```
/mnt/workspace/searxng/firecrawl/
├── package.json       # npm init (pins firecrawl-mcp)
├── node_modules/      # local install
├── .env               # API key (if using hosted)
```

## Notes

- **Hosted vs self-hosted**: This setup assumes hosted Firecrawl (api.firecrawl.dev) with an API key. Self-hosted is a separate container with Docker.
- **No reverse proxy**: MCP runs in stdio mode, consumed directly by OpenCode/Claude. No port needed.
- **Node.js**: Uses the same Node runtime already present for `mcp-searxng`.

## References

- firecrawl-mcp npm: <https://www.npmjs.com/package/firecrawl-mcp>
- Firecrawl MCP GitHub: <https://github.com/firecrawl/firecrawl-mcp-server>
- Firecrawl: <https://firecrawl.dev>
