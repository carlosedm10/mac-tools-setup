# Mac setup script

This repo contains a **Mac-only** modular setup tool for a new development machine.

The installer groups setup into:

- **All** — everything in one go
- **Dev deps** — Homebrew, terminal, languages, direnv
- **Apps** — GUI apps by category (internet, messaging, video, coding)
- **IDE** — Cursor + extensions
- **GitHub** — Git config + SSH

## Architecture

Setup is split into modular steps orchestrated by `install`, with shared libraries under `lib/` and one file per phase under `steps/`. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

## Before you run it

- **macOS only**: Do not run this on Windows or Linux.
- **Your `.zshrc` will be replaced** (Dev deps step):
  - If you already have a `.zshrc`, the script first copies it to `~/Downloads/zshrc_copy.txt`
  - Then it writes a new `.zshrc` based on the current template (Oh My Zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `nvm`, Docker completions)
  - If you want to keep parts of your old setup, copy them back from that file afterwards.

## What gets installed

### Dev deps

- Homebrew
- Xcode Command Line Tools
- Oh My Zsh + zsh plugins
- Python, UV, Bun, Go, Ollama, Ruby/Rails, Node (Homebrew + nvm LTS)
- Brew packages: `git`, `wget`, `curl`, `openssl`, `pnpm`, `htop`, `jq`, `git-lfs`, `pipx`, `poetry`, `direnv`
- Docker via Colima: `colima`, `docker`, `docker-compose` (starts Colima on first run)

### Apps (pick categories in the installer)

| Category | Apps |
|----------|------|
| **Internet** | Arc, Tailscale |
| **Messaging** | Slack, Telegram, WhatsApp |
| **Video** | Blender, VLC, Zoom, Fathom |
| **Coding & tools** | DBeaver, Docker Desktop, MongoDB Compass, Postman, Wireshark, UTM, Ghostty |

### IDE

- Cursor (Homebrew cask)
- Curated Cursor extensions (Python, data, infra, GitHub, AI, frontend)

### GitHub

- Global Git name/email
- SSH key for GitHub + `~/.ssh/config` entry

> Note: Full **Xcode** (the IDE) must be installed separately from the Mac App Store. The script only handles the Command Line Tools.

## How to run it

1. **Open Terminal** and clone this repo:

   ```bash
   git clone <REPO_URL>
   cd mac-tools-setup
   ```

2. **Run the installer**:

   ```bash
   ./install
   ```

3. Use the **gum multi-select** to choose groups (`All`, `Dev deps`, `Apps`, `IDE`, `GitHub`). If you pick **Apps**, a second picker lets you choose categories.

4. Follow any prompts (e.g. Xcode Command Line Tools GUI installer, Git name/email, GitHub SSH key add).

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
