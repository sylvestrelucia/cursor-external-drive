#!/usr/bin/env bash
# Phase 1: copy User + ~/.cursor to the external drive (safe while Cursor is running).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

require_volume

sync_to() {
  local src="$1"
  local dest="$2"
  [[ -d "${src}" ]] || { log "SKIP missing ${src}"; return 0; }
  log "SYNC ${src} -> ${dest}"
  mkdir -p "${dest}"
  rsync -a --progress "${src}/" "${dest}/"
  log "DONE ${dest}"
}

sync_to "${CURSOR_SUPPORT}/User" "${CURSOR_EXTERNAL_BASE}/User"
sync_to "${CURSOR_HOME}" "${CURSOR_HOME_EXTERNAL}"

log "Sync complete. Quit Cursor, then run finalize-cursor-data.sh"
