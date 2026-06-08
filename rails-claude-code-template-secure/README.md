# Rails + Claude Code secure template

Policy:
- Claude Code edits files only; Bash is denied.
- npm/yarn use Takumi Guard: https://npm.flatt.tech/
- Bundler/RubyGems uses Takumi Guard mirror: https://rubygems.flatt.tech/
- Git diff scripts record before/after state.
- Container runs with host UID/GID to avoid root-owned files.

Start:
1. Create `.env` on host: `echo "UID=$(id -u)" > .env && echo "GID=$(id -g)" >> .env`
2. `docker compose up -d --build`
3. Rebuild and reopen in VSCode Dev Container.
4. In container, run `bash scripts/check_guards.sh`.
5. Create Rails app with `rails new . --database=postgresql --skip-git --skip-bundle`.


## Hardened runtime notes

The app container runs as `devuser` and uses Docker hardening options:

```yaml
cap_drop:
  - ALL
security_opt:
  - no-new-privileges:true
```

This does not change the normal setup steps, but after changing Docker-related files you must rebuild the container.
