#!/usr/bin/env bash
# Homebrew installation

step_homebrew_run() {
  info "Installing Homebrew..."
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    success "Homebrew already installed."
  fi

  ensure_brew_shellenv
}
