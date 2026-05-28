#!/usr/bin/env bash
# Agent skills via agent-skills-template (bunx)

_SKILLS_PLATFORMS=(cursor claude-code codex opencode pi agents)
_SKILLS_DEFAULT_PLATFORMS=(cursor claude-code opencode)

step_skills_run() {
  local -a platforms=()
  local platforms_csv
  local line

  info "Agent skills (agent-skills-template)"

  if ! command -v bun &>/dev/null; then
    error "bun is required. Run the Dev deps step first (or: curl -fsSL https://bun.sh/install | bash)."
    return 1
  fi

  ensure_gum || return 1

  while IFS= read -r line; do
    [[ -n "$line" ]] && platforms+=("$line")
  done < <(gum_select_multi_defaults \
    "Select platforms to install skills for:" \
    "${_SKILLS_DEFAULT_PLATFORMS[@]}" \
    -- "${_SKILLS_PLATFORMS[@]}") || return 1

  if [[ ${#platforms[@]} -eq 0 ]]; then
    error "No platforms selected."
    return 1
  fi

  platforms_csv="$(
    IFS=,
    echo "${platforms[*]}"
  )"

  info "Platforms: $platforms_csv"
  info "Skills: all (non-interactive)"

  if [[ "$DRY_RUN" == "true" ]]; then
    warn "[dry-run] bunx agent-skills-template@latest install -y --platforms $platforms_csv --skills all --mode copy"
    return 0
  fi

  if ! bunx agent-skills-template@latest install -y \
    --platforms "$platforms_csv" \
    --skills all \
    --mode copy; then
    error "agent-skills-template install failed."
    return 1
  fi

  success "Agent skills installed."
}
