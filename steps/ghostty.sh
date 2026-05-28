#!/usr/bin/env bash
# Ghostty config (~/.config/ghostty)

step_ghostty_run() {
  local repo_root src_dir dest_dir

  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  src_dir="$repo_root/config/ghostty"
  dest_dir="$HOME/.config/ghostty"

  info "Ghostty config"

  if [[ ! -f "$src_dir/config" || ! -f "$src_dir/themes/ayu" ]]; then
    error "Missing bundled Ghostty config under $src_dir"
    return 1
  fi

  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    warn "[dry-run] would install $src_dir -> $dest_dir"
    return 0
  fi

  mkdir -p "$dest_dir/themes"

  if [[ -f "$dest_dir/config" ]]; then
    backup_file "$dest_dir/config"
  fi
  if [[ -f "$dest_dir/themes/ayu" ]]; then
    backup_file "$dest_dir/themes/ayu"
  fi

  cp "$src_dir/config" "$dest_dir/config"
  cp "$src_dir/themes/ayu" "$dest_dir/themes/ayu"
  success "Ghostty config installed ($dest_dir)."
}
