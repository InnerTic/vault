---
title: "Setup"
tags:
  - software
modified: 2026-06-26
---

# SearXNG Setup

Self-hosted metasearch engine running as a user systemd service.

## Install (from scratch)

```bash
# Clone repo
git clone https://github.com/searxng/searxng.git /mnt/workspace/searxng/repo

# Create venv
uv venv /mnt/workspace/searxng/venv

# Install build deps + requirements
uv pip install --python /mnt/workspace/searxng/venv/bin/python pip setuptools wheel msgspec
uv pip install --python /mnt/workspace/searxng/venv/bin/python -r /mnt/workspace/searxng/repo/requirements.txt -r /mnt/workspace/searxng/repo/requirements-server.txt

# Install SearXNG package (needs --no-build-isolation — setup.py imports from searx at build time)
/mnt/workspace/searxng/venv/bin/pip install --no-build-isolation -e /mnt/workspace/searxng/repo

# Copy default config
cp /mnt/workspace/searxng/repo/searx/settings.yml /mnt/workspace/searxng/settings.yml
```

Customize `/mnt/workspace/searxng/settings.yml`:

- `server.secret_key` — generate with `python3 -c "import secrets; print(secrets.token_urlsafe(32))"`
- `server.bind_address` — `"0.0.0.0"` for LAN access, `"127.0.0.1"` for local-only
- `server.limiter` — `false` for local use
- `search.formats` — add `json` for API access:

  ```yaml
  formats:
    - html
    - json
  ```

## Service file

`~/.config/systemd/user/searxng.service`:

```
[Unit]
Description=SearXNG metasearch engine
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/mnt/workspace/searxng
Environment=SEARXNG_SETTINGS_PATH=/mnt/workspace/searxng/settings.yml
Environment=UV_LINK_MODE=copy
ExecStart=/mnt/workspace/searxng/venv/bin/searxng-run
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

## MCP Integration

MCP server bridges SearXNG to AI assistants (OpenCode, Claude, Cursor):

```bash
npm install --prefix /mnt/workspace/searxng/mcp mcp-searxng
```

Add to `~/.config/opencode/opencode.jsonc` (or `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "searxng": {
      "command": "npx",
      "args": ["-y", "mcp-searxng"],
      "env": {
        "SEARXNG_URL": "http://127.0.0.1:8888"
      }
    }
  }
}
```

Provides tools: `searxng_web_search`, `searxng_search_suggestions`, `searxng_instance_info`, `web_url_read`.

### Live config (LXC deployment)

SearXNG runs in LXC 108 (`172.16.12.16`), so the actual config uses:

```json
{
  "mcpServers": {
    "searxng": {
      "command": "npx",
      "args": ["-y", "mcp-searxng"],
      "env": {
        "SEARXNG_URL": "http://172.16.12.16:8888"
      }
    }
  }
}
```

### Fixed: API returns 403 — resolved 2026-06-28

**Root cause:** `search.formats` in `/etc/searxng/settings.yml` only included `html`, not `json`. The default SearXNG config only serves HTML unless `json` is explicitly added. The MCP bridge queries the JSON API, which returned 403.

**Fix:** Added `json` to `search.formats`:

```yaml
search:
  formats:
    - html
    - json
```

Other potential causes that were already correct on LXC 108:
- `server.limiter: false` — was already set
- SSH root access — was actually available (root key works)
- `search_token` — not required when `server.limiter: false`

**How to fix again if needed:**
```bash
scp corrected-settings.yml root@172.16.12.16:/etc/searxng/settings.yml
ssh root@172.16.12.16 "kill -HUP \$(pgrep -f 'searx.webapp')"
```

## Commands

```bash
systemctl --user daemon-reload
systemctl --user enable --now searxng.service
systemctl --user status searxng.service
journalctl --user -u searxng.service -n 50 --no-pager
```

## Usage

| Access | URL |
|--------|-----|
| Web UI (local) | http://127.0.0.1:8888 |
| Web UI (LAN) | http://172.16.12.16:8888 |
| JSON API | `curl 'http://172.16.12.16:8888/search?q=test&format=json'` |
| OpenCode provider | `"baseURL": "http://172.16.12.16:8888"` |
| OpenCode MCP env | `SEARXNG_URL=http://172.16.12.16:8888` |

## Directory layout

### Local install (docs/vault)
```
/mnt/workspace/searxng/
├── repo/              # git clone of searxng/searxng
├── venv/              # Python virtual environment
├── settings.yml       # custom config
```

### LXC 108 (live)
```
/usr/local/searxng/
├── searxng-src/       # git clone
├── searx-pyenv/       # Python venv
├── /etc/searxng/settings.yml   # actual config path
```

## Notes

- Installed via pip (not AUR) to avoid sudo dependency and keep it as a user service
- Uses `--no-build-isolation` because setup.py imports `searx` (which requires `msgspec`) at import time during build
- No nginx reverse proxy needed for local-only usage — SearXNG's built-in server handles direct access on port 8888
- LXC 108 runs fish shell (not bash) — heredocs won't work over SSH, use `printf` or `scp` instead

## References

- SearXNG: <https://github.com/searxng/searxng>
- mcp-searxng (MCP bridge): <https://github.com/ihor-sokoliuk/mcp-searxng>
- SearXNG docs: <https://docs.searxng.org/>
