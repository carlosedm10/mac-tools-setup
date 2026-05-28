#!/usr/bin/env bash
# GitHub SSH key generation, agent setup, ~/.ssh/config, and connectivity test.

github_ssh_test() {
  local ssh_output
  ssh_output=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
  echo "$ssh_output" | grep -q "successfully authenticated"
}

# setup_github_ssh [true|false]
# Optional arg: dry-run mode (default false).
setup_github_ssh() {
  local dry_run="${1:-false}"
  local ssh_key="$HOME/.ssh/id_ed25519_github"
  local git_email

  if github_ssh_test; then
    success "GitHub SSH authentication already working."
    return 0
  fi

  echo ""
  info "Setting up SSH for GitHub..."

  git_email="$(git config --global user.email 2>/dev/null || true)"
  if [[ -z "$git_email" ]]; then
    ensure_gum || return 1
    git_email="$(gum input --placeholder "you@example.com" --prompt "Git email (for SSH key comment): ")"
    [[ -n "$git_email" ]] || {
      error "Git email is required."
      return 1
    }
  fi

  if [[ ! -f "$ssh_key" ]]; then
    info "Generating SSH key for GitHub..."
    if [[ "$dry_run" == "true" ]]; then
      warn "[dry-run] ssh-keygen -t ed25519 -C \"$git_email\" -f \"$ssh_key\" -N \"\""
    else
      ssh-keygen -t ed25519 -C "$git_email" -f "$ssh_key" -N ""
      success "SSH key generated."
    fi
  else
    success "SSH key already exists."
  fi

  if [[ "$dry_run" != "true" ]]; then
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "$ssh_key" 2>/dev/null || ssh-add "$ssh_key"
  else
    warn "[dry-run] would start ssh-agent and add $ssh_key"
  fi

  mkdir -p "$HOME/.ssh"
  if [[ -f "$HOME/.ssh/config" ]] && grep -q "Host github.com" "$HOME/.ssh/config"; then
    info "GitHub entry already exists in ~/.ssh/config — skipping append."
  elif [[ "$dry_run" == "true" ]]; then
    warn "[dry-run] would append github.com entry to ~/.ssh/config"
  else
    backup_file "$HOME/.ssh/config"
    cat >> "$HOME/.ssh/config" <<'EOF'

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  AddKeysToAgent yes
  UseKeychain yes
EOF
    success "SSH config updated."
  fi

  echo ""
  echo "  Your public SSH key (copy it now):"
  if [[ -f "$ssh_key.pub" ]]; then
    cat "$ssh_key.pub"
  else
    echo "  (key not generated — dry-run)"
  fi
  echo ""
  echo "  Add this key to GitHub:"
  echo "     https://github.com/settings/ssh/new"
  echo "     Then authorize it with SSO (if required)."
  echo ""

  if [[ "$dry_run" == "true" ]]; then
    warn "[dry-run] would prompt to test GitHub SSH connection"
    return 0
  fi

  ensure_gum || return 1
  if ! gum confirm "Have you added the key to GitHub and authorized SSO?"; then
    warn "Add the key, then test manually: ssh -T git@github.com"
    return 0
  fi

  local ssh_output
  ssh_output=$(ssh -o StrictHostKeyChecking=no -T git@github.com 2>&1 || true)

  if echo "$ssh_output" | grep -q "successfully authenticated"; then
    success "SSH connection to GitHub successful."
  else
    warn "SSH test failed. Output:"
    echo "$ssh_output"
    warn "Check your key and try again: ssh -T git@github.com"
  fi
}
