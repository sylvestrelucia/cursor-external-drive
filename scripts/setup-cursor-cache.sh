#!/usr/bin/env bash
# Move Cursor cache and user data to an external drive via symlinks.
# Safe to re-run: skips paths already linked correctly.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

require_volume

for name in "${SUPPORT_CACHE_DIRS[@]}"; do
  link_dir "${CURSOR_SUPPORT}" "${name}" || log "SKIP ${CURSOR_SUPPORT}/${name}"
done

if needs_user_data_migration; then
  if cursor_running; then
    log "Syncing User + ~/.cursor (Cursor can stay open)..."
    mkdir -p "${CURSOR_EXTERNAL_BASE}/User" "${CURSOR_HOME_EXTERNAL}"
    rsync -a "${CURSOR_SUPPORT}/User/" "${CURSOR_EXTERNAL_BASE}/User/"
    rsync -a "${CURSOR_HOME}/" "${CURSOR_HOME_EXTERNAL}/"
    log "Sync done. Quit Cursor, then run finalize-cursor-data.sh"
    exit 0
  fi
  link_dir "${CURSOR_SUPPORT}" "User"
  link_path "${CURSOR_HOME}" "${CURSOR_HOME_EXTERNAL}"
else
  log "OK  User + ~/.cursor already on external drive"
fi

if [[ -d "${CURSOR_APP_CACHE}" || -L "${CURSOR_APP_CACHE}" ]]; then
  link_path "${CURSOR_APP_CACHE}" "${CURSOR_APP_CACHE_EXTERNAL}" || true
else
  mkdir -p "${CURSOR_APP_CACHE_EXTERNAL}"
  ln -s "${CURSOR_APP_CACHE_EXTERNAL}" "${CURSOR_APP_CACHE}"
  log "LINK ${CURSOR_APP_CACHE} -> ${CURSOR_APP_CACHE_EXTERNAL}"
fi

log "Done. External root: ${CURSOR_EXTERNAL_BASE}"
du -sh "${CURSOR_EXTERNAL_BASE}"/* 2>/dev/null | sort -hr || true
