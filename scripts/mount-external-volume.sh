#!/usr/bin/env bash
# Mount the configured external volume if connected but not mounted.
# Add to System Settings → General → Login Items, before Cursor starts.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

volume_name="$(basename "${CURSOR_EXTERNAL_VOLUME}")"

if [[ -d "${CURSOR_EXTERNAL_VOLUME}" ]]; then
  log "Already mounted: ${CURSOR_EXTERNAL_VOLUME}"
  exit 0
fi

log "Attempting to mount: ${volume_name}"
if diskutil mount "${volume_name}" 2>/dev/null; then
  log "Mounted ${CURSOR_EXTERNAL_VOLUME}"
else
  log "Could not mount ${volume_name} (drive may be unplugged or still spinning up)"
  exit 1
fi
