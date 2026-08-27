#!/usr/bin/env bash
# IDE: Cursor app + extensions
#
# Extension list = personal stack (Python, data, infra, remote-ssh, AI, frontend).

_CURSOR_APP="/Applications/Cursor.app"
_CURSOR_CLI_BUNDLED="$_CURSOR_APP/Contents/Resources/app/bin/cursor"

# Resolve the Cursor CLI: PATH first, then the binary bundled inside Cursor.app.
_cursor_cli() {
  if command -v cursor &>/dev/null; then
    command -v cursor
    return 0
  fi
  if [[ -x "$_CURSOR_CLI_BUNDLED" ]]; then
    echo "$_CURSOR_CLI_BUNDLED"
    return 0
  fi
  return 1
}

_IDE_EXTENSIONS=(
  # --- Python ---
  ms-python.python
  ms-python.debugpy
  ms-python.vscode-pylance
  charliermarsh.ruff
  ms-toolsai.jupyter
  ms-toolsai.jupyter-renderers
  ms-toolsai.jupyter-cell-tags
  ms-toolsai.jupyter-slideshow
  # --- Data ---
  dorzey.vscode-sqlfluff
  mtxr.sqltools
  mechatroner.rainbow-csv
  dotjoshjohnson.xml
  redhat.vscode-yaml
  samuelcolvin.jinjahtml
  lucien-martijn.parquet-visualizer
  # --- Productivity ---
  wayou.vscode-todo-highlight
  cweijan.vscode-office
  vscode-icons-team.vscode-icons
  streetsidesoftware.code-spell-checker
  alefragnani.project-manager
  Malo.copy-json-path
  # --- Infra ---
  mikestead.dotenv
  foxundermoon.shell-format
  ms-vscode.makefile-tools
  tamasfe.even-better-toml
  hashicorp.terraform
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  ms-vscode-remote.remote-explorer
  # --- GitHub ---
  github.vscode-github-actions
  eamodio.gitlens
  donjayamanne.githistory
  # --- AI assistants ---
  sourcegraph.cody-ai
  github.copilot
  github.copilot-chat
  google.geminicodeassist
  # --- Frontend ---
  batisteo.vscode-django
  bradlc.vscode-tailwindcss
  Vue.volar
  kamikillerto.vscode-colorize
)

_install_extensions_for() {
  local cli="$1"
  local ext
  info "Installing extensions via $cli..."
  for ext in "${_IDE_EXTENSIONS[@]}"; do
    if [[ "$DRY_RUN" == "true" ]]; then
      warn "[dry-run] $cli --install-extension $ext"
    elif ! "$cli" --install-extension "$ext" &>/dev/null; then
      warn "Failed to install '$ext' (continuing)."
    fi
  done
}

step_ide_run() {
  info "IDE (Cursor)"

  if [[ -d "$_CURSOR_APP" ]]; then
    info "Cursor already installed at $_CURSOR_APP"
  elif [[ "$DRY_RUN" == "true" ]]; then
    warn "[dry-run] brew install --cask cursor"
  else
    info "Installing Cursor..."
    brew install --cask cursor || warn "Failed to install Cursor cask"
  fi

  local cursor_cli=""
  if [[ "$DRY_RUN" == "true" ]]; then
    cursor_cli="cursor"
  elif cursor_cli=$(_cursor_cli); then
    :
  else
    warn "Cursor CLI not found — install Cursor, or run 'Shell Command: Install cursor command in PATH' from the Command Palette."
    warn "Skipped extension installation."
    success "IDE setup finished."
    return 0
  fi

  _install_extensions_for "$cursor_cli"
  success "IDE setup finished (some extensions may have failed; see warnings above)."
}
