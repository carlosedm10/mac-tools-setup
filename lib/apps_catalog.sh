#!/usr/bin/env bash
# App categories for the Apps setup step

ALL_APP_CATEGORIES=("internet" "messaging" "video" "coding")

declare -A APP_CATEGORY_LABELS=(
  [internet]="Internet"
  [messaging]="Messaging"
  [video]="Video"
  [coding]="Coding & tools"
)

declare -A APP_CATEGORY_CASKS=(
  [internet]="arc tailscale"
  [messaging]="slack telegram whatsapp"
  [video]="blender vlc zoom fathom"
  [coding]="dbeaver-community docker mongodb-compass postman wireshark utm iterm2"
)

apps_step_id() {
  echo "apps-$1"
}

apps_step_label() {
  local category="$1"
  echo "Apps › ${APP_CATEGORY_LABELS[$category]:-$category}"
}
