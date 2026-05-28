#!/usr/bin/env bash
# UI utilities: colors, formatted output, gum wrappers

# ============================================================================
# Colors & formatting
# ============================================================================

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

info()    { echo -e "${BLUE}::${NC} $*"; }
success() { echo -e "${GREEN}::${NC} $*"; }
warn()    { echo -e "${YELLOW}::${NC} $*"; }
error()   { echo -e "${RED}::${NC} $*"; }
debug()   { echo -e "${DIM}..${NC} $*"; }

# ============================================================================
# Gum wrappers (ensure_gum lives in lib/deps.sh)
# ============================================================================

gum_select_multi() {
  local desc="$1"
  shift
  local items=("$@")

  ensure_gum || return 1

  echo -e "${CYAN}${BOLD}${desc}${NC}" >&2
  echo -e "${DIM}(use arrow keys, space to select, enter to confirm)${NC}" >&2
  echo "" >&2

  local -a selected
  local IFS=$'\n'
  selected=($(printf '%s\n' "${items[@]}" | gum choose --no-limit))

  if [[ ${#selected[@]} -eq 0 ]]; then
    error "No steps selected." >&2
    return 1
  fi

  printf '%s\n' "${selected[@]}"
}

gum_select_multi_defaults() {
  local desc="$1"
  shift
  local -a defaults=()

  while [[ $# -gt 0 && "$1" != "--" ]]; do
    defaults+=("$1")
    shift
  done

  [[ "${1:-}" == "--" ]] && shift
  local items=("$@")

  ensure_gum || return 1

  echo -e "${CYAN}${BOLD}${desc}${NC}" >&2
  echo -e "${DIM}(use arrow keys, space to select, enter to confirm)${NC}" >&2
  echo "" >&2

  local -a gum_args=(choose --no-limit)
  local d
  for d in "${defaults[@]}"; do
    gum_args+=(--selected="$d")
  done

  local -a selected
  local IFS=$'\n'
  selected=($(printf '%s\n' "${items[@]}" | gum "${gum_args[@]}"))

  if [[ ${#selected[@]} -eq 0 ]]; then
    error "No steps selected." >&2
    return 1
  fi

  printf '%s\n' "${selected[@]}"
}

gum_select_single() {
  local desc="$1"
  shift
  local items=("$@")

  ensure_gum || return 1

  echo -e "${CYAN}${BOLD}${desc}${NC}"
  echo -e "${DIM}(use arrow keys, enter to select)${NC}"
  echo ""

  local selected
  selected=$(printf '%s\n' "${items[@]}" | gum choose)

  if [[ -z "$selected" ]]; then
    error "No item selected."
    return 1
  fi

  echo "$selected"
}

declare -g _status_rows=()

add_status_row() {
  _status_rows+=("$@")
}

reset_status_table() {
  _status_rows=()
}

print_status_table() {
  local headers=("$@")
  local col_widths=()
  local row

  for i in "${!headers[@]}"; do
    col_widths[$i]=${#headers[$i]}
  done

  for row in "${_status_rows[@]}"; do
    local -a cols
    IFS='|' read -ra cols <<< "$row"
    for i in "${!cols[@]}"; do
      local len=${#cols[$i]}
      if (( len > col_widths[i] )); then
        col_widths[$i]=$len
      fi
    done
  done

  local header_line=""
  for i in "${!headers[@]}"; do
    printf -v padded "%-${col_widths[$i]}s" "${headers[$i]}"
    header_line+="${BOLD}${padded}${NC}  "
  done
  echo "$header_line"

  local divider=""
  for width in "${col_widths[@]}"; do
    divider+=$(printf "%${width}s" | tr ' ' '—')
    divider+="  "
  done
  echo -e "${DIM}${divider}${NC}"

  for row in "${_status_rows[@]}"; do
    local -a cols
    IFS='|' read -ra cols <<< "$row"
    local row_line=""
    for i in "${!cols[@]}"; do
      printf -v padded "%-${col_widths[$i]}s" "${cols[$i]}"
      row_line+="${padded}  "
    done
    echo "$row_line"
  done
}

run_with_spinner() {
  local msg="$1"
  shift
  local cmd=("$@")

  if ! ensure_gum; then
    debug "$msg"
    "${cmd[@]}"
    return $?
  fi

  ("${cmd[@]}" 2>&1) & gum spin --spinner dot --title "$msg" -- sleep infinity
  local ret=$?
  wait $! 2>/dev/null || true

  if [[ $ret -eq 0 ]]; then
    success "$msg"
  else
    error "$msg failed"
  fi

  return $ret
}
