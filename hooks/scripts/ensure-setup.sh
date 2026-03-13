#!/usr/bin/env bash
# Ensure gstack browse binary is built and find-browse can locate it.
set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
GSTACK_DIR="$PLUGIN_ROOT/vendor/gstack"
BROWSE_BIN="$GSTACK_DIR/browse/dist/browse"
COMPAT_LINK="$HOME/.claude/skills/gstack"

# 1. Build browse binary if missing or stale
NEEDS_BUILD=0
if [ ! -x "$BROWSE_BIN" ]; then
  NEEDS_BUILD=1
elif [ -n "$(find "$GSTACK_DIR/browse/src" -type f -newer "$BROWSE_BIN" -print -quit 2>/dev/null)" ]; then
  NEEDS_BUILD=1
elif [ "$GSTACK_DIR/package.json" -nt "$BROWSE_BIN" ]; then
  NEEDS_BUILD=1
elif [ -f "$GSTACK_DIR/bun.lock" ] && [ "$GSTACK_DIR/bun.lock" -nt "$BROWSE_BIN" ]; then
  NEEDS_BUILD=1
fi

if [ "$NEEDS_BUILD" -eq 1 ]; then
  if command -v bun >/dev/null 2>&1; then
    (cd "$GSTACK_DIR" && bun install && bun run build) >&2
  else
    echo "gstack: bun not found, skipping browse binary build" >&2
  fi
fi

# 2. Ensure Playwright Chromium
if [ -x "$BROWSE_BIN" ] && command -v bun >/dev/null 2>&1; then
  if ! (cd "$GSTACK_DIR" && bun --eval 'import { chromium } from "playwright"; const browser = await chromium.launch(); await browser.close();') >/dev/null 2>&1; then
    (cd "$GSTACK_DIR" && bunx playwright install chromium) >&2 || true
  fi
fi

# 3. Backward-compat symlink so upstream find-browse resolves
#    find-browse looks at ~/.claude/skills/gstack/browse/dist/browse
if [ -L "$COMPAT_LINK" ]; then
  # Update if pointing somewhere else
  current="$(readlink "$COMPAT_LINK")"
  if [ "$current" != "$GSTACK_DIR" ]; then
    ln -snf "$GSTACK_DIR" "$COMPAT_LINK"
  fi
elif [ ! -e "$COMPAT_LINK" ]; then
  mkdir -p "$(dirname "$COMPAT_LINK")"
  ln -snf "$GSTACK_DIR" "$COMPAT_LINK"
fi
