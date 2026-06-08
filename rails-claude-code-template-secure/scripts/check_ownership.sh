#!/usr/bin/env bash
set -euo pipefail
printf "container id: "; id
printf "workspace owner: "; stat -c '%U:%G %u:%g %n' /workspace
find /workspace -maxdepth 2 -user root -print | head -50
