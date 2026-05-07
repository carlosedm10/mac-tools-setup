# Mac setup script

This repo contains a **Mac-only** script that sets up a new development machine with your preferred tools.

The script:

- Installs **Homebrew**
- Sets up **developer tooling** (Xcode Command Line Tools, Oh My Zsh, Python, UV, Bun, Go, Node via `nvm`, CLI packages)
- Installs your **GUI apps** (Arc, Blender, Cursor, DBeaver Community, Docker, iTerm2, Fathom, MongoDB Compass, Postman, Slack, Tailscale, Telegram, UTM, VLC, WhatsApp, Wireshark, Zoom)
- Configures **Cursor** with a curated set of extensions
- Configures **Git & GitHub SSH**

## Before you run it

- **macOS only**: Do not run this on Windows or Linux.
- **Your `.zshrc` will be replaced**:
  - If you already have a `.zshrc`, the script will first copy it to:
    - `~/Downloads/zshrc_copy.txt`
  - Then it writes a new `.zshrc` based on the current template (Oh My Zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `nvm`, Docker completions).
  - If you want to keep parts of your old setup, copy them back from that file afterwards.

## What gets installed

- **Homebrew**
- **Developer tools**
  - Xcode Command Line Tools
  - Oh My Zsh
  - Zsh plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`
  - Python (latest stable 3.x via Homebrew `python`)
  - UV (Python package manager)
  - Bun ([official install script](https://bun.sh))
  - Go: `go`, plus `golangci-lint`, `delve` (debugger), `staticcheck`, `gopls` (language server); `~/go/bin` is on `PATH` for `go install` tools
  - Ollama (local LLM runtime; [official install script](https://ollama.com/download))
  - Node.js via `nvm` (if `nvm` is already installed)
  - Brew packages: `git`, `wget`, `curl`, `openssl`, `pnpm`, `htop`, `jq`, `git-lfs`, `pipx`, `poetry`, `direnv`
- **Applications (via Homebrew casks)**
  - Arc
  - Blender
  - Cursor
  - DBeaver Community (SQL / database GUI)
  - Docker Desktop
  - Fathom
  - iTerm2
  - MongoDB Compass (MongoDB GUI)
  - Postman
  - Slack
  - Tailscale
  - Telegram
  - UTM
  - VLC
  - WhatsApp
  - Wireshark
  - Zoom
- **Git & GitHub**
  - Global name/email
  - SSH key for GitHub
  - `~/.ssh/config` entry for `github.com`

> Note: Full **Xcode** (the IDE) must be installed separately from the Mac App Store. The script only handles the Command Line Tools.

## How to run it

1. **Open Terminal** and clone this repo:

   ```bash
   git clone <REPO_URL>
   cd mac-tools-setup
   ```

2. **Run the setup script**:

   ```bash
   bash setup.sh
   ```

3. Follow any prompts (e.g. Xcode Command Line Tools GUI installer, Git name/email, GitHub SSH key add).

After it finishes, you should have:

- Your apps installed
- A configured Zsh shell
- Python + Node tooling
- Cursor with extensions
- Git/GitHub ready to use

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

4. Add `.envrc.local` to your repo’s `.gitignore`, then allow the directory:

```bash
direnv allow
```

From then on, `cd`-ing into the app will load vars automatically, and leaving the directory will unload them.
