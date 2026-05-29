#!/usr/bin/env bash
# Colima config (~/.colima/default/colima.yaml)

step_colima_run() {
  local repo_root src dest

  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  src="$repo_root/config/colima/colima.yaml"
  dest="${COLIMA_HOME:-$HOME/.colima}/default/colima.yaml"

  info "Colima config"

  if [[ ! -f "$src" ]]; then
    error "Missing bundled Colima config under $src"
    return 1
  fi

  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    warn "[dry-run] would install $src -> $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -f "$dest" ]]; then
    backup_file "$dest"
  fi

  cp "$src" "$dest"
  success "Colima config installed ($dest)."
}
