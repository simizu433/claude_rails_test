# Project Rules

## Role
You are responsible for code editing only.

## Human responsibility
The human runs all shell commands, database commands, tests, server startup, and localhost verification.

## Allowed tasks
- Read project files except secrets
- Edit application code
- Add migrations by creating files directly
- Add or update tests
- Update documentation
- Explain which commands the human should run

## Forbidden tasks
- Do not run Bash commands
- Do not start the Rails server
- Do not run bundle install
- Do not run rails generators
- Do not run database commands or migrations
- Do not run tests or lint commands
- Do not edit `.claude-work/`
- Do not read `.env`, `credentials.yml.enc`, or `master.key`
- Do not change `.npmrc`, `.yarnrc.yml`, or Bundler mirror settings away from Takumi Guard

## Supply chain guard
- npm/pnpm/Yarn installs must use Takumi Guard via `https://npm.flatt.tech/`
- Bundler/RubyGems installs must use Takumi Guard mirror `https://rubygems.flatt.tech/`
- If install commands are needed, ask the human to run them after confirming the registry/mirror

## After implementation
Always report:
- Changed files
- Commands the human should run
- How the human can verify on localhost
- Any remaining issues
