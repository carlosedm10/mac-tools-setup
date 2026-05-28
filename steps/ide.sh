#!/usr/bin/env bash
# IDE: Cursor app + extensions

step_ide_run() {
  info "IDE (Cursor)"

  info "Installing Cursor..."
  if [[ "$DRY_RUN" == "true" ]]; then
    warn "[dry-run] brew install --cask cursor"
  else
    brew install --cask cursor || warn "Failed to install Cursor cask"
  fi

  if ! command -v cursor &>/dev/null; then
    warn "Cursor CLI not found. Skipping extension installation."
    warn "Open Cursor once, then re-run the IDE step to install extensions."
    return 0
  fi

  info "Installing recommended Cursor extensions..."

  _install_ext() {
    local ext="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
      warn "[dry-run] cursor --install-extension $ext"
      return 0
    fi
    if ! cursor --install-extension "$ext"; then
      warn "Failed to install extension '$ext' (continuing)."
    fi
  }

  _install_ext ms-python.python
  _install_ext ms-python.debugpy
  _install_ext ms-python.vscode-pylance
  _install_ext charliermarsh.ruff
  _install_ext ms-toolsai.jupyter
  _install_ext ms-toolsai.jupyter-renderers
  _install_ext ms-toolsai.jupyter-cell-tags
  _install_ext ms-toolsai.jupyter-slideshow
  _install_ext dorzey.vscode-sqlfluff
  _install_ext mtxr.sqltools
  _install_ext mechatroner.rainbow-csv
  _install_ext dotjoshjohnson.xml
  _install_ext redhat.vscode-yaml
  _install_ext samuelcolvin.jinjahtml
  _install_ext lucien-martijn.parquet-visualizer
  _install_ext wayou.vscode-todo-highlight
  _install_ext cweijan.vscode-office
  _install_ext vscode-icons-team.vscode-icons
  _install_ext streetsidesoftware.code-spell-checker
  _install_ext alefragnani.project-manager
  _install_ext Malo.copy-json-path
  _install_ext mikestead.dotenv
  _install_ext foxundermoon.shell-format
  _install_ext ms-vscode.makefile-tools
  _install_ext tamasfe.even-better-toml
  _install_ext hashicorp.terraform
  _install_ext ms-vscode-remote.remote-ssh
  _install_ext ms-vscode-remote.remote-ssh-edit
  _install_ext ms-vscode-remote.remote-explorer
  _install_ext github.vscode-github-actions
  _install_ext eamodio.gitlens
  _install_ext donjayamanne.githistory
  _install_ext sourcegraph.cody-ai
  _install_ext github.copilot
  _install_ext google.geminicodeassist
  _install_ext batisteo.vscode-django
  _install_ext bradlc.vscode-tailwindcss
  _install_ext Vue.volar
  _install_ext kamikillerto.vscode-colorize

  success "IDE setup finished (some extensions may have failed; see warnings above)."
}
