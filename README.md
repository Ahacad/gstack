# gstack (plugin wrapper)

Claude Code plugin wrapper for [garrytan/gstack](https://github.com/garrytan/gstack).

Exposes all gstack skills (plan-ceo-review, plan-eng-review, review, ship, browse, qa, retro, setup-browser-cookies) via the Claude Code plugin system instead of manual symlink setup.

## Install

```bash
claude plugin add ahacad/gstack
```

Or manually:

```bash
git clone --recurse-submodules https://github.com/ahacad/gstack.git ~/.claude/plugins/gstack
```

## Update upstream

```bash
cd <plugin-root>
git submodule update --remote vendor/gstack
git add vendor/gstack
git commit -m "update upstream gstack"
```

## How it works

- `vendor/gstack/` — git submodule tracking garrytan/gstack
- `skills/` — symlinks into `vendor/gstack/` for plugin auto-discovery
- `hooks/` — SessionStart hook builds the browse binary and creates backward-compat symlinks

No fork divergence. Upstream changes flow through with `git submodule update --remote`.
