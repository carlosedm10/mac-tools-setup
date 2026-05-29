# Mac setup script

This repo contains a **Mac-only** modular setup tool for a new development machine.

The installer groups setup into:

- **All** — everything in one go
- **Dev deps** — Homebrew, terminal, languages, direnv
- **GitHub** — Git config + SSH
- **Apps** — GUI apps by category (internet, messaging, video, coding)
- **IDE** — Cursor + extensions
- **Agent skills** — Cursor / Claude Code / OpenCode skills via `agent-skills-template` (last)

## Architecture

Setup is split into modular steps orchestrated by `install`, with shared libraries under `lib/` and one file per phase under `steps/`. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

## Before you run it

- **macOS only**: Do not run this on Windows or Linux.
- **Your `.zshrc` will be replaced** (Dev deps step):
  - If you already have a `.zshrc`, the script first copies it to `~/Downloads/zshrc_copy.txt`
  - Then it writes a new `.zshrc` from `config/zsh/zshrc` (Oh My Zsh, `nvm`, Bun, mise, direnv, Colima/Desktop Docker helpers, `fdev` alias, and more)
  - If you want to keep parts of your old setup, copy them back from that file afterwards.

## What gets installed

### Dev deps

- Homebrew
- Xcode Command Line Tools
- Oh My Zsh + zsh plugins
- Python, UV, Bun, Go, Ollama, Ruby/Rails, Node (Homebrew + nvm LTS)
- Brew packages: `git`, `wget`, `curl`, `openssl`, `pnpm`, `htop`, `jq`, `git-lfs`, `pipx`, `poetry`, `direnv`, `mise`
- Docker via Colima: `colima`, `docker`, `docker-compose` (installs bundled `colima.yaml` — 4 CPU, 8 GiB RAM, `vz` + `virtiofs` — then starts Colima on first run)

### Apps (pick categories in the installer)

| Category | Apps |
|----------|------|
| **Internet** | Arc, Tailscale |
| **Messaging** | Slack, Telegram, WhatsApp |
| **Video** | Blender, VLC, Zoom, Fathom |
| **Coding & tools** | DBeaver, Docker Desktop, MongoDB Compass, Postman, Wireshark, UTM, Ghostty, Claude Code, OpenCode |

### IDE

- Cursor (Homebrew cask)
- Curated Cursor extensions (Python, data, infra, GitHub, AI, frontend)

### Agent skills

- Interactive platform picker (defaults: Cursor, Claude Code, OpenCode)
- Runs `bunx agent-skills-template@latest install -y --skills all --mode copy`
- Requires **Dev deps** (Bun) first

### GitHub

- Global Git name/email
- SSH key for GitHub + `~/.ssh/config` entry

> Note: Full **Xcode** (the IDE) must be installed separately from the Mac App Store. The script only handles the Command Line Tools.

## How to run it

### 1. Create a workspace and clone this repo

Open **Terminal** (or Ghostty after setup). Use a single parent directory for dev repos — `~/code` is the convention this project and [factorial-dev](https://github.com/factorialco/factorial-dev) expect:

```bash
mkdir -p ~/code
cd ~/code
git clone git@github.com:carlosedm10/mac-tools-setup.git
cd mac-tools-setup
```

If you do not use SSH yet, clone over HTTPS and switch to SSH after the **GitHub** install step:

```bash
git clone https://github.com/carlosedm10/mac-tools-setup.git
cd mac-tools-setup
```

### 2. Run the installer

```bash
./install
```

Use the **gum multi-select** to choose groups (`All`, `Dev deps`, `Apps`, `IDE`, `GitHub`, `Agent skills`). If you pick **Apps**, a second picker lets you choose categories.

Follow any prompts (e.g. Xcode Command Line Tools GUI installer, Git name/email, GitHub SSH key add).

### 3. (Optional) Factorial local development

After **Dev deps** and **GitHub** (so `git` and SSH work), bootstrap Factorial service repos from the same `~/code` directory:

```bash
cd ~/code
git clone git@github.com:factorialco/factorial-dev.git
cd factorial-dev
./install
source ~/.zshrc   # loads the fdev alias
fdev up
```

See the [factorial-dev README](https://github.com/factorialco/factorial-dev) for service details and commands.

### Flags

| Flag | Behavior |
|------|----------|
| *(none)* | Status table + gum picker (pending groups pre-selected) |
| `--fresh` | Reset completion state; pre-select **All** |
| `--dry-run` | Show picker and log actions without executing |
| `--status` | Print step completion table and exit |

Completion state is stored in `~/.config/mac-setup/settings.json`. Re-run `./install` to continue where you left off.

## direnv (Ruby/Rails env vars)

This setup installs `direnv` and wires it into your shell so environment variables are automatically loaded when you `cd` into a project that has an `.envrc`.

### One-time verification (recommended)

Open a **new** terminal (so your shell loads the hook), then run:

```bash
direnv version
```

### Rails/Ruby project setup

In the root of your Rails app:

1. Create an `.envrc` (safe defaults you can commit):

```bash
export RAILS_ENV=development
export RACK_ENV=development
export BUNDLE_WITHOUT="production"
```

2. Put secrets / machine-local values in `.envrc.local` (do not commit):

```bash
export DATABASE_URL="postgres://localhost:5432/myapp_development"
export REDIS_URL="redis://localhost:6379/0"
export SECRET_KEY_BASE="..."
```

3. Source the local file from `.envrc`:

```bash
source_env .envrc.local
```

4. Add `.envrc.local` to your repo's `.gitignore`, then allow the directory:

```bash
direnv allow
```

From then on, `cd`-ing into the app will load vars automatically, and leaving the directory will unload them.
