#!/usr/bin/env bash
# Git config + GitHub SSH

step_github_run() {
  info "GitHub"

  local git_name git_email
  git_name="$(git config --global user.name 2>/dev/null || true)"
  git_email="$(git config --global user.email 2>/dev/null || true)"

  ensure_gum || return 1

  if [[ -z "$git_name" ]]; then
    git_name="$(gum input --placeholder "Your Name" --prompt "Git user name: ")"
    [[ -n "$git_name" ]] || {
      error "Git user name is required."
      return 1
    }
  fi

  if [[ -z "$git_email" ]]; then
    git_email="$(gum input --placeholder "you@example.com" --prompt "Git email: ")"
    [[ -n "$git_email" ]] || {
      error "Git email is required."
      return 1
    }
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    warn "[dry-run] git config --global user.name \"$git_name\""
    warn "[dry-run] git config --global user.email \"$git_email\""
  else
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    success "Git global config set."
  fi

  setup_github_ssh "$DRY_RUN"
}
