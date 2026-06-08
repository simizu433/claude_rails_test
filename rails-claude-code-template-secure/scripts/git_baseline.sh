#!/usr/bin/env bash
set -euo pipefail
mkdir -p .claude-work
git status --short > .claude-work/status.before.txt || true
git diff > .claude-work/diff.before.patch || true
git rev-parse HEAD > .claude-work/head.before.txt 2>/dev/null || echo "NO_HEAD" > .claude-work/head.before.txt
echo "Saved baseline to .claude-work/"
