#!/usr/bin/env bash
# direnv shell hooks + sanity check

step_direnv_run() {
  info "direnv setup"

  if ! command -v direnv &>/dev/null; then
    error "direnv is not installed (expected via Homebrew)."
    error "Try re-running dev-tools or run: brew install direnv"
    return 1
  fi

  if [[ -f "$HOME/.zshrc" ]] && ! grep -q 'direnv hook zsh' "$HOME/.zshrc"; then
    backup_file "$HOME/.zshrc"
    cat >> "$HOME/.zshrc" << 'EOF'

# direnv (auto-load .envrc per directory)
eval "$(direnv hook zsh)"
EOF
    success "Added direnv hook to ~/.zshrc"
  fi

  if [[ -f "$HOME/.bash_profile" ]] && ! grep -q 'direnv hook bash' "$HOME/.bash_profile"; then
    backup_file "$HOME/.bash_profile"
    cat >> "$HOME/.bash_profile" << 'EOF'

# direnv (auto-load .envrc per directory)
eval "$(direnv hook bash)"
EOF
    success "Added direnv hook to ~/.bash_profile"
  fi

  info "direnv version: $(direnv version)"

  local tmp_dir got
  tmp_dir="$(mktemp -d)"
  echo 'export DIRENV_TEST="works"' > "$tmp_dir/.envrc"
  tmp_dir="$(cd "$tmp_dir" && pwd -P)"
  direnv allow "$tmp_dir" >/dev/null

  got="$(direnv exec "$tmp_dir" bash -lc 'echo "${DIRENV_TEST:-}"')"
  rm -rf "$tmp_dir"

  if [[ "$got" = "works" ]]; then
    success "direnv sanity check passed."
  else
    error "direnv sanity check failed (expected 'works', got '$got')."
    error "Try opening a new terminal, then run: direnv status"
    return 1
  fi
}
