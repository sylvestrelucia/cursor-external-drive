#!/usr/bin/env bash
# Install scripts and optional LaunchAgent for cursor-external-drive.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/cursor-external-drive"
CONFIG_FILE="${CONFIG_DIR}/config.env"
EXAMPLE="${REPO_DIR}/config.example.env"

log() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }

: "${CURSOR_SCRIPTS_DIR:=${HOME}/Library/Scripts/cursor-external-drive}"
: "${CURSOR_LAUNCHD_LABEL:=com.$(whoami).cursor-external-drive}"

install -d "${CONFIG_DIR}"
install -d "${CURSOR_SCRIPTS_DIR}"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  cp "${EXAMPLE}" "${CONFIG_FILE}"
  log "Created ${CONFIG_FILE} — edit CURSOR_EXTERNAL_VOLUME before migrating."
else
  log "Using existing ${CONFIG_FILE}"
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${CURSOR_EXTERNAL_VOLUME:?Set CURSOR_EXTERNAL_VOLUME in ${CONFIG_FILE}}"

install -m 755 "${REPO_DIR}/scripts/"*.sh "${CURSOR_SCRIPTS_DIR}/"

LAUNCHD_DIR="${HOME}/Library/LaunchAgents"
PLIST="${LAUNCHD_DIR}/${CURSOR_LAUNCHD_LABEL}.cache-symlinks.plist"
install -d "${LAUNCHD_DIR}"

cat >"${PLIST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${CURSOR_LAUNCHD_LABEL}.cache-symlinks</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-c</string>
    <string>if [[ -d "${CURSOR_EXTERNAL_VOLUME}" ]]; then "${CURSOR_SCRIPTS_DIR}/setup-cursor-cache.sh"; fi</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>3600</integer>
  <key>StandardOutPath</key>
  <string>${HOME}/Library/Logs/cursor-external-drive-setup.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/Library/Logs/cursor-external-drive-setup.log</string>
</dict>
</plist>
EOF

UID_NUM="$(id -u)"
launchctl bootout "gui/${UID_NUM}/${CURSOR_LAUNCHD_LABEL}.cache-symlinks" 2>/dev/null || true
launchctl bootstrap "gui/${UID_NUM}" "${PLIST}"

log "Installed scripts to ${CURSOR_SCRIPTS_DIR}"
log "Installed LaunchAgent ${PLIST}"
log ""
log "Next steps:"
log "  1. Edit ${CONFIG_FILE} if needed"
log "  2. Run ${CURSOR_SCRIPTS_DIR}/setup-cursor-cache.sh"
log "  3. Quit Cursor, then run ${CURSOR_SCRIPTS_DIR}/finalize-cursor-data.sh"
log "  4. Verify: ${CURSOR_SCRIPTS_DIR}/verify-cursor-external-drive.sh"
