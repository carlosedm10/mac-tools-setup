#!/usr/bin/env bash
# Shared helpers for setup steps

NVM_VERSION="v0.40.3"

backup_file() {
  if [[ -f "$1" ]]; then
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
    success "Backed up $1"
  fi
}

ensure_brew_shellenv() {
  brew_shellenv
}

install_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    success "nvm already installed."
    return 0
  fi

  info "Installing nvm ${NVM_VERSION}..."
  PROFILE=/dev/null curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  success "nvm installed."
}

load_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    error "nvm is not installed at $NVM_DIR/nvm.sh"
    return 1
  fi
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
}

# Homebrew casks with .pkg installers call sudo directly; cache credentials once
# and refresh the timestamp in the background so later sudo calls do not re-prompt.
sudo_keepalive_start() {
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    return 0
  fi

  info "Some installers need administrator access — enter your password once when prompted."
  if ! sudo -v; then
    error "Administrator privileges are required for some setup steps."
    return 1
  fi

  local parent_pid=$$
  (
    while kill -0 "$parent_pid" 2>/dev/null; do
      sudo -n true 2>/dev/null || exit 0
      sleep 50
    done
  ) &
  SUDO_KEEPALIVE_PID=$!
}

sudo_keepalive_stop() {
  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    unset SUDO_KEEPALIVE_PID
  fi
  return 0
}

steps_may_need_sudo() {
  local step
  for step in "$@"; do
    case "$step" in
      dev-deps|ide|apps-*) return 0 ;;
    esac
  done
  return 1
}
