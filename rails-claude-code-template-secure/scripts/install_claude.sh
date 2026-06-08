#!/usr/bin/env bash
set -euo pipefail
mkdir -p /workspace/.npm-global
npm config set prefix /workspace/.npm-global
npm config set registry https://npm.flatt.tech/
npm install -g @anthropic-ai/claude-code
cat <<'MSG'
Claude Code installed.
If `claude` is not found, run:
  export PATH="/workspace/.npm-global/bin:$PATH"
MSG
