#!/usr/bin/env bash
set -euo pipefail
bundle config set --global mirror.https://rubygems.org https://rubygems.flatt.tech/
bundle config set --global path /workspace/vendor/bundle
bundle config list
