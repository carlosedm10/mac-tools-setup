#!/usr/bin/env bash
# GUI applications via Homebrew casks (by category)

step_apps_run() {
  local category="$1"
  local -a casks=()
  local cask

  if [[ -z "${APP_CATEGORY_CASKS[$category]:-}" ]]; then
    error "Unknown app category: $category"
    return 1
  fi

  read -ra casks <<< "${APP_CATEGORY_CASKS[$category]}"

  info "${APP_CATEGORY_LABELS[$category]:-$category} apps"
  info "Installing applications via Homebrew..."

  for cask in "${casks[@]}"; do
    info "Installing $cask..."
    if [[ "$DRY_RUN" == "true" ]]; then
      warn "[dry-run] brew install --cask $cask"
    else
      brew install --cask "$cask" || warn "Failed to install $cask"
    fi
  done

  if [[ "$category" == "coding" ]]; then
    step_ghostty_run || return 1
  fi

  success "${APP_CATEGORY_LABELS[$category]:-$category} apps installed."
}
