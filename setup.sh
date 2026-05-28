#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Common Setup Script for macOS
# ------------------------------------------------------------------------------

echo "🚀 Starting common onboarding automation for macOS"
echo "⚠️  This script will automate many steps, but some manual actions are still required."
echo "   Please read each prompt carefully.\n"

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------
confirm() {
    read -r -p "${1:-Continue?} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) true ;;
        *) false ;;
    esac
}

backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
        echo "✅ Backed up $1"
    fi
}

install_homebrew() {
    echo "Installing Homebrew..."
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for the current session
        eval "$(/opt/homebrew/bin/brew shellenv)"  # For Apple Silicon
        # For Intel, use /usr/local/bin/brew
    else
        echo "✅ Homebrew already installed."
    fi

    # Ensure brew is on PATH for this script run (Apple Silicon or Intel).
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# nvm is a shell function (not a binary); install once, then source nvm.sh in this script.
NVM_VERSION="v0.40.3"

install_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        echo "✅ nvm already installed."
        return 0
    fi

    echo "Installing nvm ${NVM_VERSION}..."
    PROFILE=/dev/null curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    echo "✅ nvm installed."
}

load_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        echo "❌ nvm is not installed at $NVM_DIR/nvm.sh"
        return 1
    fi
    # shellcheck disable=SC1091
    . "$NVM_DIR/nvm.sh"
}

# ------------------------------------------------------------------------------
# 1. Developer Tools & Terminal Dependencies
# ------------------------------------------------------------------------------
setup_dev_tools_and_terminal() {
    echo "\n=== 1. Developer Tools & Terminal Dependencies ==="

    # 1.1 Xcode Command Line Tools
    echo "Installing Xcode Command Line Tools..."
    if ! xcode-select -p &>/dev/null; then
        xcode-select --install
        echo "⚠️  Please follow the GUI prompt to install the tools, then press any key to continue."
        read -n 1 -s
    else
        echo "✅ Xcode Command Line Tools already installed."
    fi

    echo "Installing Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "✅ Oh My Zsh installed."
    else
        echo "✅ Oh My Zsh already installed."
    fi

    # Extra safety copy of existing .zshrc into Downloads as plain text
    if [ -f "$HOME/.zshrc" ]; then
        mkdir -p "$HOME/Downloads"
        cp "$HOME/.zshrc" "$HOME/Downloads/zshrc_copy.txt"
        echo "✅ Saved a copy of .zshrc to ~/Downloads/zshrc_copy.txt"
    fi

    # Backup and replace .zshrc next to original
    backup_file "$HOME/.zshrc"
    echo "Writing new .zshrc configuration..."
    cat > "$HOME/.zshrc" << 'EOF'
# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export PATH="/opt/homebrew/bin:$PATH"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$PATH:$HOME/go/bin"

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# RubyGems executables (e.g. rails, bundler) for Homebrew Ruby 4.x
export PATH="/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"

# Docker CLI completions
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
compinit

# iTerm extra binds (optional)
bindkey "^[b" backward-word
bindkey "^[f" forward-word
bindkey "^[^?" backward-kill-word
bindkey "^U" kill-whole-line
EOF
    echo "✅ .zshrc written."

    # Install zsh-autosuggestions plugin if not present
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi

    # Install zsh-syntax-highlighting plugin if not present
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    # 1.4 Core packages
    echo "Installing core packages: git, wget, curl, openssl, pnpm, htop, jq, git-lfs, pipx, poetry, direnv..."
    brew install git wget curl openssl pnpm htop jq git-lfs pipx poetry direnv

    # 1.4.1 Node.js (includes npm + npx)
    echo "Installing Node.js (includes npm + npx)..."
    brew install node

    # 1.5 UV
    echo "Installing UV (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # 1.6 Ollama
    echo "Installing Ollama..."
    if command -v ollama &>/dev/null; then
        echo "✅ Ollama already installed."
    else
        curl -fsSL https://ollama.com/install.sh | sh
        echo "✅ Ollama installed."
    fi

    # 1.7 Python: latest stable 3.x from Homebrew
    echo "Installing latest stable Python (Homebrew python formula)..."
    brew install python

    # 1.8 Ruby + Rails
    echo "Installing Ruby + Rails..."
    brew install ruby
    gem install bundler rails

    # Ensure Rails executable dir is available for this script run, too.
    ruby_gem_bindir="$(ruby -e 'require "rubygems"; puts Gem.bindir')"
    export PATH="$ruby_gem_bindir:$PATH"

    if ! command -v rails &>/dev/null; then
        echo "❌ Rails executable not found on PATH after install."
        echo "   RubyGems bindir detected as: $ruby_gem_bindir"
        echo "   Try opening a new terminal, then verify with: rails -v"
        exit 1
    fi
    echo "✅ Rails installed: $(rails -v)"

    # 1.9 Bun
    echo "Installing Bun..."
    if [ -x "$HOME/.bun/bin/bun" ]; then
        echo "✅ Bun already installed."
    else
        curl -fsSL https://bun.sh/install | bash
        echo "✅ Bun installed."
    fi

    # 1.10 Go and common tooling
    echo "Installing Go (compiler) and tooling: golangci-lint, delve, staticcheck, gopls..."
    brew install go golangci-lint delve staticcheck gopls

    # 1.11 NVM + Node.js LTS (nvm is a shell function; must install + source nvm.sh)
    echo "Installing and configuring Node.js via nvm..."
    install_nvm
    load_nvm
    nvm install --lts || echo "⚠️  nvm install --lts failed (continuing)."
    nvm alias default 'lts/*' || true
    nvm use default || true

    # Sanity check: npx should be present after installing node
    if ! command -v npx &>/dev/null; then
        echo "❌ npx is still not available on PATH."
        echo "   Try: restart your terminal, or run: source ~/.zshrc"
        echo "   Then verify with: npx --version"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# 1.x direnv (Ruby/Rails friendly env loading)
# ------------------------------------------------------------------------------
setup_direnv() {
    echo "\n=== direnv ==="

    if ! command -v direnv &>/dev/null; then
        echo "❌ direnv is not installed (expected via Homebrew)."
        echo "   Try re-running the previous section or run: brew install direnv"
        exit 1
    fi

    # Ensure zsh hook exists (script rewrites ~/.zshrc, but keep this idempotent anyway).
    if [ -f "$HOME/.zshrc" ] && ! grep -q 'direnv hook zsh' "$HOME/.zshrc"; then
        backup_file "$HOME/.zshrc"
        cat >> "$HOME/.zshrc" << 'EOF'

# direnv (auto-load .envrc per directory)
eval "$(direnv hook zsh)"
EOF
        echo "✅ Added direnv hook to ~/.zshrc"
    fi

    # Optional bash hook if user uses bash.
    if [ -f "$HOME/.bash_profile" ] && ! grep -q 'direnv hook bash' "$HOME/.bash_profile"; then
        backup_file "$HOME/.bash_profile"
        cat >> "$HOME/.bash_profile" << 'EOF'

# direnv (auto-load .envrc per directory)
eval "$(direnv hook bash)"
EOF
        echo "✅ Added direnv hook to ~/.bash_profile"
    fi

    echo "direnv version: $(direnv version)"

    # Non-interactive sanity check: prove an env var is loaded via .envrc
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    echo 'export DIRENV_TEST="works"' > "$tmp_dir/.envrc"
    # macOS: mktemp returns /var/... but direnv allow stores /private/var/...
    tmp_dir="$(cd "$tmp_dir" && pwd -P)"
    direnv allow "$tmp_dir" >/dev/null

    local got
    got="$(direnv exec "$tmp_dir" bash -lc 'echo "${DIRENV_TEST:-}"')"
    rm -rf "$tmp_dir"

    if [ "$got" = "works" ]; then
        echo "✅ direnv sanity check passed."
    else
        echo "❌ direnv sanity check failed (expected 'works', got '$got')."
        echo "   Try opening a new terminal, then run: direnv status"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# 2. Applications (GUI)
# ------------------------------------------------------------------------------
setup_apps() {
    echo "\n=== 2. Applications ==="
    echo "Installing applications via Homebrew..."

    local casks=(
        arc
        blender
        cursor
        dbeaver-community
        docker
        fathom
        iterm2
        mongodb-compass
        postman
        slack
        tailscale
        telegram
        utm
        vlc
        whatsapp
        wireshark
        zoom
    )

    for cask in "${casks[@]}"; do
        echo "Installing $cask..."
        brew install --cask "$cask" || echo "⚠️  Warning: failed to install $cask"
    done

    echo "Applications installed."
    echo "ℹ️  Xcode must be installed from the Mac App Store manually."
}

# ------------------------------------------------------------------------------
# 3. Cursor extensions
# ------------------------------------------------------------------------------
setup_cursor_extensions() {
    echo "\n=== 3. Cursor Extensions ==="

    if ! command -v cursor &>/dev/null; then
        echo "⚠️  Cursor CLI not found. Skipping extension installation."
        return
    fi

    echo "Installing recommended Cursor extensions..."

    install_ext() {
        local ext="$1"
        if ! cursor --install-extension "$ext"; then
            echo "⚠️  Failed to install extension '$ext' (continuing)."
        fi
    }

    # Python
    install_ext ms-python.python
    install_ext ms-python.debugpy
    install_ext ms-python.vscode-pylance
    install_ext charliermarsh.ruff
    install_ext ms-toolsai.jupyter
    install_ext ms-toolsai.jupyter-renderers
    install_ext ms-toolsai.jupyter-cell-tags
    install_ext ms-toolsai.jupyter-slideshow
    # Data
    install_ext dorzey.vscode-sqlfluff
    install_ext mtxr.sqltools
    install_ext mechatroner.rainbow-csv
    install_ext dotjoshjohnson.xml
    install_ext redhat.vscode-yaml
    install_ext samuelcolvin.jinjahtml
    install_ext lucien-martijn.parquet-visualizer
    # Productivity
    install_ext wayou.vscode-todo-highlight
    install_ext cweijan.vscode-office
    install_ext vscode-icons-team.vscode-icons
    install_ext streetsidesoftware.code-spell-checker
    install_ext alefragnani.project-manager
    install_ext Malo.copy-json-path
    # Infra
    install_ext mikestead.dotenv
    install_ext foxundermoon.shell-format
    install_ext ms-vscode.makefile-tools
    install_ext tamasfe.even-better-toml
    install_ext hashicorp.terraform
    install_ext ms-vscode-remote.remote-ssh
    install_ext ms-vscode-remote.remote-ssh-edit
    install_ext ms-vscode-remote.remote-explorer
    # GitHub
    install_ext github.vscode-github-actions
    install_ext eamodio.gitlens
    install_ext donjayamanne.githistory
    # AI
    install_ext sourcegraph.cody-ai
    install_ext github.copilot
    install_ext google.geminicodeassist
    # Frontend (if needed)
    install_ext batisteo.vscode-django
    install_ext bradlc.vscode-tailwindcss
    install_ext Vue.volar
    install_ext kamikillerto.vscode-colorize

    echo "✅ Cursor extension install step finished (some may have failed; see warnings above)."
}

# ------------------------------------------------------------------------------
# 4. Git & GitHub
# ------------------------------------------------------------------------------
setup_git_and_github() {
    echo "\n=== 4. Git & GitHub ==="

    # 4.1 Local Git config
    read -r -p "Enter your Git user name: " git_name
    read -r -p "Enter your Git email: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    echo "✅ Git global config set."

    # 4.2 SSH for GitHub
    echo "Generating SSH key for GitHub..."
    ssh_key="$HOME/.ssh/id_ed25519_github"
    if [ ! -f "$ssh_key" ]; then
        ssh-keygen -t ed25519 -C "$git_email" -f "$ssh_key" -N ""
        echo "✅ SSH key generated."
    else
        echo "✅ SSH key already exists."
    fi

    # Start ssh-agent and add key
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "$ssh_key" 2>/dev/null || ssh-add "$ssh_key"

    # Create SSH config
    mkdir -p "$HOME/.ssh"
    if [ -f "$HOME/.ssh/config" ] && grep -q "Host github.com" "$HOME/.ssh/config"; then
        echo "ℹ️  GitHub entry already exists in ~/.ssh/config. Skipping append."
    else
        backup_file "$HOME/.ssh/config"
        cat >> "$HOME/.ssh/config" << EOF

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  AddKeysToAgent yes
  UseKeychain yes
EOF
        echo "✅ SSH config updated."
    fi

    # Display public key for manual addition to GitHub
    echo "\n🔑 Your public SSH key (copy it now):"
    cat "$ssh_key.pub"
    echo "\n📋 Please add this key to GitHub:"
    echo "   https://github.com/settings/ssh/new"
    echo "   Then authorize it with SSO (if required)."
    if ! confirm "Have you added the key to GitHub and authorized SSO?"; then
        echo "Please do so now, then run the next step manually: 'ssh -T git@github.com' to test."
    else
        # Test connection
        # Note: ssh -T returns exit code 1 on success (no shell access), so we capture output first
        # to avoid 'pipefail' errors. We also use StrictHostKeyChecking=no to avoid prompts.
        ssh_output=$(ssh -o StrictHostKeyChecking=no -T git@github.com 2>&1 || true)

        if echo "$ssh_output" | grep -q "successfully authenticated"; then
            echo "✅ SSH connection to GitHub successful."
        else
            echo "⚠️  SSH test failed. Output:"
            echo "$ssh_output"
            echo "Please check your key and try again later."
        fi
    fi
}


# ------------------------------------------------------------------------------
# Final Checklist
# ------------------------------------------------------------------------------
final_checklist() {
    echo "\n=== Installation Completed ==="
    echo "✅ Developer tools"
    echo "✅ direnv installed + shell hook added"
    echo "✅ Applications"
    echo "✅ Terminal + Python configured"
    echo "✅ GitHub & SSH working (if you added the key)"
    echo "\n🎉 Mac setup script completed!"
    echo "Please review any skipped manual steps and ensure everything looks good."
}

# ------------------------------------------------------------------------------
# Common main (for standalone use)
# ------------------------------------------------------------------------------
common_main() {
    install_homebrew
    setup_dev_tools_and_terminal
    setup_direnv
    setup_apps
    setup_cursor_extensions
    setup_git_and_github
    final_checklist
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    common_main
fi

