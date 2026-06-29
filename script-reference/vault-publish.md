---
title: "vault-publish"
tags:
  - script
  - vault
  - quartz
modified: 2026-06-28
---

# vault-publish

Full publish pipeline for vault → Quartz. Single command that backlinks, syncs, builds, commits, and pushes.

## Usage

```bash
vault-publish
```

## Pipeline

1. **Check state** — aborts if there are staged but uncommitted changes
2. **Backlink** — runs `vault-journal-backlink.sh` if available
3. **Sync** — rsyncs `~/vault/docs/` → `~/quartz/content/`
4. **Build** — `npx quartz build` in `~/quartz/`
5. **Commit & push** — adds all, commits as "chore: sync vault and update quartz wiki", pushes

## Troubleshooting

If `npx quartz build` fails with "couldn't find git repository for content":

```bash
ls -la ~/.gitconfig
ln -sf ~/vault/dotfiles/git/.gitconfig ~/.gitconfig
```

The `@napi-rs/simple-git` library requires a readable `~/.gitconfig` to initialize.

## See Also

- [[quartz-setup|Quartz Setup]]
- [[vault-journal-backlink|vault-journal-backlink.sh]]
- [[AGENTS]]
