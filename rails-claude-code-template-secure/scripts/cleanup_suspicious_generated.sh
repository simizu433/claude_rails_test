#!/usr/bin/env bash
set -euo pipefail
cat <<'MSG'
This script does not delete automatically.
Recommended host-side cleanup:
  docker compose down -v --remove-orphans
  cd ..
  sudo chown -R "$USER:$USER" rails-claude-code-template* 2>/dev/null || true
  rm -rf rails-claude-code-template*
MSG
