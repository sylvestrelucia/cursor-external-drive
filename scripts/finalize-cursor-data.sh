#!/usr/bin/env bash
# Phase 2: final sync + symlink swap for User and ~/.cursor (Cursor must be quit).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

require_volume

if cursor_running; then
  die "Quit Cursor completely, then run this script again."
fi

mkdir -p "${CURSOR_EXTERNAL_BASE}/User" "${CURSOR_HOME_EXTERNAL}"

if [[ -d "${CURSOR_SUPPORT}/User" && ! -L "${CURSOR_SUPPORT}/User" ]]; then
  log "Final sync User -> external..."
  rsync -a --delete "${CURSOR_SUPPORT}/User/" "${CURSOR_EXTERNAL_BASE}/User/"
fi

if [[ -d "${CURSOR_HOME}" && ! -L "${CURSOR_HOME}" ]]; then
  log "Final sync ~/.cursor -> external..."
  rsync -a --delete "${CURSOR_HOME}/" "${CURSOR_HOME_EXTERNAL}/"
fi

finalize() {
  local src="$1"
  local dest="$2"

  if [[ -L "${src}" ]] && [[ "$(readlink "${src}")" == "${dest}" ]]; then
    log "OK  ${src} already linked"
    return 0
  fi

  if [[ -e "${src}" && ! -L "${src}" ]]; then
    log "REMOVE ${src}"
    rm -rf "${src}"
  elif [[ -L "${src}" ]]; then
    rm "${src}"
  fi

  ln -s "${dest}" "${src}"
  log "LINK ${src} -> ${dest}"
}

finalize "${CURSOR_SUPPORT}/User" "${CURSOR_EXTERNAL_BASE}/User"
finalize "${CURSOR_HOME}" "${CURSOR_HOME_EXTERNAL}"

log "Done."
du -sh "${CURSOR_EXTERNAL_BASE}/User" "${CURSOR_HOME_EXTERNAL}"
ls -la "${CURSOR_SUPPORT}/User" "${CURSOR_HOME}"
