# Claude Rails Test

Claude Code をコンテナ内で動かし、Railsアプリのコード作成・修正だけを任せるための検証リポジトリです。

この構成では、Claude Code に Bash コマンドを実行させず、Railsアプリのファイル編集だけを担当させます。
`rails new`、`bundle install`、`db:migrate`、`rails server`、テスト実行などは人間が実行します。

---

## 目的

この構成では、Claude Code に以下だけを担当させます。

* Railsアプリのコード作成
* 既存コードの修正
* migrationファイルの作成
* model / controller / view / test ファイルの作成・修正
* 実行が必要なコマンドの提示

一方で、以下は禁止します。

* Bashコマンドの実行
* `rails generate` の実行
* `bundle install` の実行
* `db:migrate` の実行
* `rails server` の起動
* `git push` やデプロイ操作
* `.env` や `master.key` など秘密情報の読み取り

---

## ディレクトリ構成

```txt
.
├─ README.md
└─ rails-claude-code-template-secure/
   ├─ Dockerfile
   ├─ docker-compose.yml
   ├─ .devcontainer/
   │  └─ devcontainer.json
   ├─ .claude/
   │  └─ settings.json
   ├─ CLAUDE.md
   ├─ scripts/
   │  ├─ setup_bundle_guard.sh
   │  ├─ check_guards.sh
   │  ├─ install_claude.sh
   │  ├─ git_baseline.sh
   │  ├─ git_diff_after.sh
   │  └─ check_ownership.sh
   └─ .gitignore
```

---

## 前提

以下がインストール済みであること。

* Docker Desktop
* VSCode
* VSCode Dev Containers 拡張

Windows + WSL2 上で作業する想定です。

Docker / Docker Compose は Docker Desktop に含まれているため、個別インストールは不要です。

---

## 事前確認

WSL側のターミナルで以下が実行できることを確認します。

```bash
docker --version
docker compose version
```

バージョンが表示されればOKです。

---

## セットアップ手順

### 1. テンプレートディレクトリへ移動

リポジトリを clone した後、テンプレートディレクトリへ移動します。

```bash
cd rails-claude-code-template-secure
```

---

### 2. `.env` を作成

コンテナ内で作成したファイルがホスト側で root 所有にならないように、ホストユーザーの UID/GID を渡します。

```bash
echo "UID=$(id -u)" > .env
echo "GID=$(id -g)" >> .env
```

確認します。

```bash
cat .env
```

例：

```txt
UID=1000
GID=1000
```

---

### 3. コンテナを起動

```bash
docker compose up -d --build
```

---

### 4. VSCodeで開く

```bash
code .
```

VSCodeでコマンドパレットを開きます。

```txt
Ctrl + Shift + P
```

以下を選択します。

```txt
Dev Containers: Rebuild and Reopen in Container
```

---

### 5. コンテナ内で確認

VSCodeのターミナルで以下を実行します。

```bash
whoami
id
echo $HOME
pwd
rails -v
```

期待値：

```txt
whoami → devuser
HOME → /home/devuser
pwd → /workspace
rails -v → Railsのバージョンが表示される
```

---

## Guard設定の確認

このテンプレートでは、npm と Bundler / RubyGems の取得先を Takumi Guard 経由にしています。

コンテナ内で確認します。

```bash
bash scripts/check_guards.sh
```

個別に確認する場合：

```bash
npm config get registry
bundle config list
```

期待値：

```txt
npm registry → https://npm.flatt.tech/
Bundler mirror → https://rubygems.flatt.tech/
```

もし Bundler mirror が未設定と表示された場合は、以下を実行します。

```bash
bash scripts/setup_bundle_guard.sh
bash scripts/check_guards.sh
```

---

## Railsアプリの作成

Railsアプリ作成は人間が実行します。

必ず `--skip-bundle` を付けます。

```bash
rails new . --database=postgresql --skip-git --skip-bundle
```

既存ファイルとの conflict が出た場合は、基本的にテンプレート側のファイルを残します。

```txt
README.md          → n
Dockerfile         → n
docker-compose.yml → n
.devcontainer系    → n
.claude系          → n
CLAUDE.md          → n
scripts系          → n
```

---

## DB設定

`config/database.yml` の `default` を以下のように設定します。

```yml
default: &default
  adapter: postgresql
  encoding: unicode
  host: db
  username: postgres
  password: password
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

---

## bundle install / DB作成

まず Guard 設定を確認します。

```bash
bash scripts/check_guards.sh
```

OKなら、人間が `bundle install` を実行します。

```bash
bundle install
```

DBを作成します。

```bash
bin/rails db:create
```

---

## Git初期化

Claude Code に作業させる前に、現在の状態を Git の基準点として保存します。

```bash
git init
git add .
git commit -m "Initial Rails app"
```

---

## Claude Code のインストール

コンテナ内の VSCode ターミナルで実行します。

```bash
bash scripts/install_claude.sh
source ~/.bashrc
claude --version
```

---

## Claude Code の起動

Claude Code に作業させる前に、作業前の状態を保存します。

```bash
bash scripts/git_baseline.sh
```

ターミナルログを保存しながら Claude Code を起動します。

```bash
script -f .claude-work/terminal.log
claude
```

---

## Bash実行禁止の確認

Claude Code 上で、最初に以下を入力して確認します。

```txt
テストとして pwd を実行してください
```

期待する反応：

```txt
Bash command is denied
```

または：

```txt
I don't have permission to run Bash commands.
```

`pwd` の結果が普通に返ってきた場合は、Bash deny 設定が効いていないため、作業を中断して `.claude/settings.json` を確認してください。

---

## Claude Code に作業依頼する例

Claude Code 上で、以下のように依頼します。

```txt
このRailsアプリのコード作成と修正だけ担当してください。

重要:
- Bashコマンドは実行しないでください
- rails generate も実行しないでください
- bundle install、db:migrate、test、server起動も実行しないでください
- 必要なファイルは直接作成・編集してください
- .claude-work/ 配下は変更しないでください
- npm/pnpm/yarn系はTakumi Guard経由にしてください
- Bundler/RubyGemsもTakumi Guard mirror経由にしてください
- .npmrc、.yarnrc.yml、Bundler mirror設定は変更しないでください
- 実行が必要なコマンドは、人間向けに最後に一覧で教えてください
- localhostでの動作確認は人間が行います

まずTODOアプリを作ってください。

要件:
- タスク一覧
- タスク作成
- タスク編集
- タスク削除
- 完了/未完了切り替え
- 完了タスクは取り消し線表示
```

---

## Claude Code にやらせること

Claude Code には以下を担当させます。

* Railsコードの作成・修正
* migrationファイルの作成
* model / controller / view の作成
* testファイルの作成
* 実行すべきコマンドの提示

---

## Claude Code に禁止していること

`.claude/settings.json` と `CLAUDE.md` により、以下を禁止しています。

* Bashコマンドの実行
* `bundle install`
* `db:migrate`
* `rails server`
* `git push`
* デプロイ操作
* `.env` の読み取り
* `config/master.key` の読み取り
* `credentials.yml.enc` の読み取り
* `.claude-work/` の変更

---

## 作業後の確認

Claude Code を終了します。

```txt
/exit
```

その後、`script` も終了します。

```bash
exit
```

差分を保存します。

```bash
bash scripts/git_diff_after.sh
```

変更内容を確認します。

```bash
git diff --stat
git diff
less .claude-work/terminal.log
```

特に以下を確認します。

* 意図しないファイルが変更されていないか
* `.env` や `master.key` など秘密情報に触れていないか
* Bash実行ログがないか
* migrationやroutesなどの変更が妥当か

---

## 人間が実行するコマンド

Claude Code が提示したコマンドを、人間が確認して実行します。

よく使うコマンドは以下です。

```bash
bin/rails db:migrate
bin/rails test
bin/rails server -b 0.0.0.0
```

ブラウザで確認します。

```txt
http://localhost:3000
```

---

## 基本運用

```txt
1. Railsアプリを作成
2. Guard設定を確認
3. bundle install / db:create を人間が実行
4. Gitで初期状態をcommit
5. Claude Codeを起動
6. Claudeにコード作成・修正だけ依頼
7. git diffで変更内容を確認
8. 問題なければ人間がmigrate / test / serverを実行
9. localhostで動作確認
```

---

## よく使うコマンド

### コンテナ起動

```bash
docker compose up -d --build
```

### コンテナ停止

```bash
docker compose down
```

### コンテナとボリューム削除

```bash
docker compose down -v --remove-orphans
```

### Guard確認

```bash
bash scripts/check_guards.sh
```

### Claude作業前の状態保存

```bash
bash scripts/git_baseline.sh
```

### Claude作業後の差分保存

```bash
bash scripts/git_diff_after.sh
```

### 差分確認

```bash
git diff --stat
git diff
```

### Rails起動

```bash
bin/rails server -b 0.0.0.0
```

---

## セキュリティ設定

このテンプレートでは、`docker-compose.yml` に以下を設定しています。

```yml
user: devuser
cap_drop:
  - ALL
security_opt:
  - no-new-privileges:true
```

これにより、コンテナ内での権限昇格や不要なLinux capabilitiesを抑制します。

また、Railsのlocalhost確認のみを想定する場合、`ports` は以下のように `127.0.0.1` に限定することを推奨します。

```yml
ports:
  - "127.0.0.1:3000:3000"
```

---

## 注意

以下はGitHubへコミットしないでください。

```txt
.env
.claude-work/
terminal.log
node_modules/
vendor/bundle/
config/master.key
config/credentials.yml.enc
.kamal/secrets
```

特に `config/master.key` は絶対に公開しないでください。

---

## 削除・作り直し

作り直す場合は、ホスト側で以下を実行します。

```bash
cd ~/projects
cd rails-claude-code-template-secure
docker compose down -v --remove-orphans
cd ..
sudo chown -R "$USER:$USER" rails-claude-code-template-secure/
rm -rf rails-claude-code-template-secure/
```

その後、リポジトリを再度 clone するか、テンプレートを再展開してください。
