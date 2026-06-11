#!/usr/bin/env bash
# Verify symlinks and external drive access.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

errors=0
ok() { log "OK  $*"; }
fail() { log "FAIL $*"; errors=$((errors + 1)); }

require_volume || fail "External volume not mounted: ${CURSOR_EXTERNAL_VOLUME}"

check_link() {
  local src="$1"
  local expected_dest="$2"
  if [[ -L "${src}" ]] && [[ "$(readlink "${src}")" == "${expected_dest}" ]] && [[ -e "${src}" ]]; then
    ok "${src}"
  else
    fail "${src} (expected -> ${expected_dest})"
  fi
}

check_link "${CURSOR_HOME}" "${CURSOR_HOME_EXTERNAL}"
check_link "${CURSOR_SUPPORT}/User" "${CURSOR_EXTERNAL_BASE}/User"

for name in "${SUPPORT_CACHE_DIRS[@]}"; do
  check_link "${CURSOR_SUPPORT}/${name}" "${CURSOR_EXTERNAL_BASE}/${name}"
done

check_link "${CURSOR_APP_CACHE}" "${CURSOR_APP_CACHE_EXTERNAL}"

[[ -f "${CURSOR_SUPPORT}/User/settings.json" ]] && ok "settings.json readable" || fail "settings.json"
[[ -d "${CURSOR_HOME}/projects" ]] && ok "~/.cursor/projects readable" || fail "~/.cursor/projects"

if [[ "${errors}" -eq 0 ]]; then
  log "All checks passed."
else
  die "${errors} check(s) failed."
fi
