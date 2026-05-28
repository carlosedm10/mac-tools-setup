#!/usr/bin/env bash
# Xcode CLT, Oh My Zsh, .zshrc, brew formulae, nvm, etc.

step_dev_tools_run() {
  info "Developer Tools & Terminal Dependencies"

  info "Installing Xcode Command Line Tools..."
  if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    ensure_gum || return 1
    gum confirm "Follow the GUI prompt to install Xcode CLT, then confirm when done." || {
      warn "Skipping until Xcode CLT is installed."
      return 1
    }
  else
    success "Xcode Command Line Tools already installed."
  fi

  info "Installing Oh My Zsh..."
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh installed."
  else
    success "Oh My Zsh already installed."
  fi

  if [[ -f "$HOME/.zshrc" ]]; then
    mkdir -p "$HOME/Downloads"
    cp "$HOME/.zshrc" "$HOME/Downloads/zshrc_copy.txt"
    success "Saved a copy of .zshrc to ~/Downloads/zshrc_copy.txt"
  fi

  backup_file "$HOME/.zshrc"
  info "Writing new .zshrc configuration..."
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

# Terminal keybinds (Ghostty / other emulators)
bindkey "^[b" backward-word
bindkey "^[f" forward-word
bindkey "^[^?" backward-kill-word
bindkey "^U" kill-whole-line
EOF
  success ".zshrc written."

  if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  fi

  if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  fi

  info "Installing core packages: git, wget, curl, openssl, pnpm, htop, jq, git-lfs, pipx, poetry, direnv..."
  brew install git wget curl openssl pnpm htop jq git-lfs pipx poetry direnv

  info "Installing Node.js (includes npm + npx)..."
  brew install node

  info "Installing UV (Python package manager)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh

  info "Installing Ollama..."
  if command -v ollama &>/dev/null; then
    success "Ollama already installed."
  else
    curl -fsSL https://ollama.com/install.sh | sh
    success "Ollama installed."
  fi

  info "Installing latest stable Python (Homebrew python formula)..."
  brew install python

  info "Installing Ruby + Rails..."
  brew install ruby
  gem install bundler rails

  local ruby_gem_bindir
  ruby_gem_bindir="$(ruby -e 'require "rubygems"; puts Gem.bindir')"
  export PATH="$ruby_gem_bindir:$PATH"

  if ! command -v rails &>/dev/null; then
    error "Rails executable not found on PATH after install."
    error "RubyGems bindir detected as: $ruby_gem_bindir"
    error "Try opening a new terminal, then verify with: rails -v"
    return 1
  fi
  success "Rails installed: $(rails -v)"

  info "Installing Bun..."
  if [[ -x "$HOME/.bun/bin/bun" ]]; then
    success "Bun already installed."
  else
    curl -fsSL https://bun.sh/install | bash
    success "Bun installed."
  fi

  info "Installing Go (compiler) and tooling: golangci-lint, delve, staticcheck, gopls..."
  brew install go golangci-lint delve staticcheck gopls

  info "Installing Docker via Colima (CLI + Compose)..."
  brew install colima docker docker-compose

  if command -v colima &>/dev/null; then
    if ! colima status &>/dev/null; then
      info "Starting Colima (first start can take a few minutes)..."
      colima start || warn "Colima failed to start; run 'colima start' when ready."
    else
      success "Colima already running."
    fi
    docker context use colima &>/dev/null || true
  fi

  info "Installing and configuring Node.js via nvm..."
  install_nvm
  load_nvm
  nvm install --lts || warn "nvm install --lts failed (continuing)."
  nvm alias default 'lts/*' || true
  nvm use default || true

  if ! command -v npx &>/dev/null; then
    error "npx is still not available on PATH."
    error "Try: restart your terminal, or run: source ~/.zshrc"
    error "Then verify with: npx --version"
    return 1
  fi
}
