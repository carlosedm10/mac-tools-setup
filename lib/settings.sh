#!/usr/bin/env bash
# lib/settings.sh: Persistent completion tracking for mac-setup install

MAC_SETUP_SETTINGS_DIR="${MAC_SETUP_SETTINGS_DIR:-$HOME/.config/mac-setup}"
MAC_SETUP_SETTINGS_FILE="${MAC_SETUP_SETTINGS_FILE:-$MAC_SETUP_SETTINGS_DIR/settings.json}"

settings_ensure_jq() {
  ensure_jq || return 1
}

settings_exists() {
  [[ -f "$MAC_SETUP_SETTINGS_FILE" ]]
}

settings_read_completed() {
  settings_ensure_jq || return 1
  jq -r '.completed_steps[]? // empty' "$MAC_SETUP_SETTINGS_FILE" 2>/dev/null
}

settings_step_completed() {
  local step="$1"
  local completed

  if ! settings_exists; then
    return 1
  fi

  while IFS= read -r completed; do
    [[ -n "$completed" ]] || continue
    if [[ "$completed" == "$step" ]]; then
      return 0
    fi
  done < <(settings_read_completed 2>/dev/null)

  return 1
}

settings_step_status() {
  local step="$1"
  if settings_step_completed "$step"; then
    echo "done"
  else
    echo "pending"
  fi
}

settings_list_pending_steps() {
  local step
  for step in "${ALL_STEPS[@]}"; do
    if ! settings_step_completed "$step"; then
      echo "$step"
    fi
  done
}

settings_list_completed_steps() {
  settings_read_completed 2>/dev/null || true
}

settings_mark_completed() {
  local step="$1"
  local -a completed=()
  local existing

  settings_ensure_jq || return 1
  mkdir -p "$MAC_SETUP_SETTINGS_DIR"

  while IFS= read -r existing; do
    [[ -n "$existing" ]] || continue
    if [[ "$existing" != "$step" ]]; then
      completed+=("$existing")
    fi
  done < <(settings_read_completed 2>/dev/null || true)

  completed+=("$step")

  local json_steps
  json_steps=$(printf '%s\n' "${completed[@]}" | jq -R . | jq -s .)

  jq -n \
    --argjson completed_steps "$json_steps" \
    --arg last_run "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{completed_steps: $completed_steps, last_run: $last_run}' \
    > "$MAC_SETUP_SETTINGS_FILE"
}

settings_reset_completed() {
  settings_ensure_jq || return 1
  mkdir -p "$MAC_SETUP_SETTINGS_DIR"
  jq -n '{completed_steps: [], last_run: null}' > "$MAC_SETUP_SETTINGS_FILE"
}
