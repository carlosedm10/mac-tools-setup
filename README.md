# Mac setup script

This repo contains a **Mac-only** script that sets up a new development machine with your preferred tools.

The script:

- Installs **Homebrew**
- Sets up **developer tooling** (Xcode Command Line Tools, Oh My Zsh, Python, UV, Node via `nvm`, CLI packages)
- Installs your **GUI apps** (Arc, Cursor, Docker, iTerm2, Fathom, Postman, Slack, Tailscale, Telegram, UTM, VLC, WhatsApp, Wireshark, Zoom)
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
  - Python 3.11
  - UV (Python package manager)
  - Node.js via `nvm` (if `nvm` is already installed)
  - Brew packages: `git`, `wget`, `curl`, `openssl`, `pnpm`, `htop`, `jq`, `git-lfs`, `pipx`, `poetry`
- **Applications (via Homebrew casks)**
  - Arc
  - Blender
  - Cursor
  - Docker Desktop
  - Fathom
  - iTerm2
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
