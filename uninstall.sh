#!/usr/bin/env bash
# Remove LaunchAgent (scripts and config are kept).

set -euo pipefail

CONFIG_FILE="${HOME}/.config/cursor-external-drive/config.env"
LABEL="com.$(whoami).cursor-external-drive"

if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${CONFIG_FILE}"
  LABEL="${CURSOR_LAUNCHD_LABEL:-${LABEL}}"
fi

PLIST="${HOME}/Library/LaunchAgents/${LABEL}.cache-symlinks.plist"
UID_NUM="$(id -u)"

launchctl bootout "gui/${UID_NUM}/${LABEL}.cache-symlinks" 2>/dev/null || true
rm -f "${PLIST}"

echo "Removed LaunchAgent ${PLIST}"
echo "Scripts in ~/Library/Scripts/cursor-external-drive and config in ~/.config/cursor-external-drive were kept."
