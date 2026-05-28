#!/usr/bin/env bash
# GUI applications via Homebrew casks (by category)

step_apps_run() {
  local category="$1"
  local -a casks=()
  local -a formulae=()
  local cask formula

  if [[ -z "${APP_CATEGORY_CASKS[$category]:-}" ]]; then
    error "Unknown app category: $category"
    return 1
  fi

  read -ra casks <<< "${APP_CATEGORY_CASKS[$category]}"
  if [[ -n "${APP_CATEGORY_FORMULAE[$category]:-}" ]]; then
    read -ra formulae <<< "${APP_CATEGORY_FORMULAE[$category]}"
  fi

  info "${APP_CATEGORY_LABELS[$category]:-$category} apps"
  info "Installing applications via Homebrew..."

  for cask in "${casks[@]}"; do
    info "Installing $cask (cask)..."
    if [[ "$DRY_RUN" == "true" ]]; then
      warn "[dry-run] brew install --cask $cask"
    else
      brew install --cask "$cask" || warn "Failed to install $cask"
    fi
  done

  for formula in "${formulae[@]}"; do
    info "Installing $formula (formula)..."
    if [[ "$DRY_RUN" == "true" ]]; then
      warn "[dry-run] brew install $formula"
    else
      brew install "$formula" || warn "Failed to install $formula"
    fi
  done

  if [[ "$category" == "coding" ]]; then
    step_ghostty_run || return 1
  fi

  success "${APP_CATEGORY_LABELS[$category]:-$category} apps installed."
}
