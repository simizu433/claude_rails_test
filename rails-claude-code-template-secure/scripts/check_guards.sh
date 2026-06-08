#!/usr/bin/env bash
set -euo pipefail

EXPECTED_NPM="https://npm.flatt.tech/"
EXPECTED_RUBY="https://rubygems.flatt.tech/"

ACTUAL_NPM="$(npm config get registry)"
echo "npm registry: $ACTUAL_NPM"
if [ "$ACTUAL_NPM" != "$EXPECTED_NPM" ]; then
  echo "NG: npm registry must be $EXPECTED_NPM" >&2
  exit 1
fi

echo "Bundler config:"
bundle config list
if ! bundle config list | grep -q "mirror.https://rubygems.org"; then
  echo "NG: Bundler RubyGems mirror is not set." >&2
  echo "Run: bash scripts/setup_bundle_guard.sh" >&2
  exit 1
fi
if ! bundle config list | grep -q "$EXPECTED_RUBY"; then
  echo "NG: Bundler RubyGems mirror is not $EXPECTED_RUBY" >&2
  exit 1
fi

echo "OK: npm and Bundler guards are configured."
