#!/usr/bin/env bash
# Homebrew installation

step_homebrew_run() {
  info "Homebrew..."
  if bootstrap_homebrew_if_needed; then
    success "Homebrew ready."
  else
    error "Homebrew setup failed."
    return 1
  fi
}
