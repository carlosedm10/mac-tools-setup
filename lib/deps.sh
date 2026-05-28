#!/usr/bin/env bash
# Runtime dependencies: Bash 4+ and gum (must stay Bash 3.2–compatible until ensure_bash4 re-execs).

# ============================================================================
# Homebrew helpers
# ============================================================================

brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    # shellcheck disable=SC1091
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    # shellcheck disable=SC1091
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# Install Homebrew when missing (Bash 3.2–safe; runs before ensure_bash4 re-exec).
# Honors INSTALL_DRY_RUN=true from install.
bootstrap_homebrew_if_needed() {
  brew_shellenv
  if command -v brew &>/dev/null; then
    return 0
  fi

  if [[ "${INSTALL_DRY_RUN:-false}" == "true" ]]; then
    echo "[dry-run] would install Homebrew" >&2
    return 0
  fi

  echo "Homebrew not found — installing..." >&2
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  brew_shellenv
  if ! command -v brew &>/dev/null; then
    cat >&2 <<'EOF'
Error: Homebrew installed but brew is not on PATH.

Add Homebrew to your shell profile, then re-run install:
  eval "$(/opt/homebrew/bin/brew shellenv)"    # Apple Silicon
  eval "$(/usr/local/bin/brew shellenv)"       # Intel Mac
EOF
    return 1
  fi

  echo "Homebrew installed." >&2
  return 0
}

_ensure_brew() {
  brew_shellenv
  if command -v brew &>/dev/null; then
    return 0
  fi
  echo "Error: Homebrew is required. Install from https://brew.sh" >&2
  return 1
}

_homebrew_bash_paths() {
  echo /opt/homebrew/bin/bash
  echo /usr/local/bin/bash
}

_bash_major_version() {
  local bash_bin="$1"
  "$bash_bin" -c 'echo "${BASH_VERSINFO[0]}"' 2>/dev/null
}

_install_bash_via_brew() {
  if ! _ensure_brew; then
    return 1
  fi
  echo "Bash 4+ required; installing via Homebrew..." >&2
  brew install bash
}

_install_gum_via_brew() {
  if ! _ensure_brew; then
    return 1
  fi
  echo "gum not found; installing via Homebrew..." >&2
  brew install charmbracelet/tap/gum
}

_install_jq_via_brew() {
  if ! _ensure_brew; then
    return 1
  fi
  echo "jq not found; installing via Homebrew..." >&2
  brew install jq
}

install_jq_if_needed() {
  if command -v jq &>/dev/null; then
    return 0
  fi
  _install_jq_via_brew
}

ensure_jq() {
  if command -v jq &>/dev/null; then
    return 0
  fi
  install_jq_if_needed || return 1
  command -v jq &>/dev/null
}

install_bash_if_needed() {
  local candidate major
  for candidate in $(_homebrew_bash_paths); do
    if [[ -x "$candidate" ]]; then
      major=$(_bash_major_version "$candidate")
      if [[ -n "$major" && "$major" -ge 4 ]]; then
        return 0
      fi
    fi
  done
  _install_bash_via_brew
}

install_gum_if_needed() {
  if command -v gum &>/dev/null; then
    return 0
  fi
  _install_gum_via_brew
}

# Bootstrap: require Bash 4+, install via Homebrew, re-exec when needed.
# Usage: ensure_bash4 "$0" "$@"
ensure_bash4() {
  local script_path="$1"
  shift

  if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
    return 0
  fi

  local candidate major
  for candidate in $(_homebrew_bash_paths); do
    if [[ -x "$candidate" ]]; then
      major=$(_bash_major_version "$candidate")
      if [[ -n "$major" && "$major" -ge 4 ]]; then
        exec "$candidate" "$script_path" "$@"
      fi
    fi
  done

  if _install_bash_via_brew; then
    for candidate in $(_homebrew_bash_paths); do
      if [[ -x "$candidate" ]]; then
        major=$(_bash_major_version "$candidate")
        if [[ -n "$major" && "$major" -ge 4 ]]; then
          exec "$candidate" "$script_path" "$@"
        fi
      fi
    done
  fi

  cat >&2 <<'EOF'
Error: install requires Bash 4+ (macOS /bin/bash is 3.2).

Install: brew install bash
Then put Homebrew earlier in PATH, e.g. in ~/.zprofile:
  export PATH="/opt/homebrew/bin:$PATH"    # Apple Silicon
  export PATH="/usr/local/bin:$PATH"       # Intel Mac

Re-run install; it will re-exec with Homebrew bash when available.
EOF
  exit 1
}

ensure_gum() {
  if command -v gum &>/dev/null; then
    return 0
  fi
  install_gum_if_needed || return 1
  command -v gum &>/dev/null
}

# Install bash + gum + jq for orchestration (install script).
install_mac_setup_dependencies() {
  if ! _ensure_brew; then
    return 1
  fi
  install_bash_if_needed
  install_gum_if_needed
  install_jq_if_needed

  if [[ "${BASH_VERSINFO[0]:-0}" -lt 4 ]]; then
    echo ""
    echo "  Note: add Homebrew to PATH so install uses Bash 4+ (not macOS /bin/bash):"
    echo '    export PATH="/opt/homebrew/bin:$PATH"    # Apple Silicon'
    echo '    export PATH="/usr/local/bin:$PATH"       # Intel Mac'
    echo ""
  fi
}
