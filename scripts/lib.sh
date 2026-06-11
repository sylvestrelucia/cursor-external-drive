#!/usr/bin/env bash
# Shared config and helpers for cursor-external-drive scripts.

set -euo pipefail

CONFIG_FILE="${CURSOR_EXTERNAL_CONFIG:-${HOME}/.config/cursor-external-drive/config.env}"

if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${CONFIG_FILE}"
fi

: "${CURSOR_EXTERNAL_VOLUME:?Set CURSOR_EXTERNAL_VOLUME in ${CONFIG_FILE} or the environment}"
: "${CURSOR_EXTERNAL_BASE:=${CURSOR_EXTERNAL_VOLUME}/CursorCache}"
: "${CURSOR_DOT_CURSOR_DIR:=dot-cursor}"

CURSOR_SUPPORT="${HOME}/Library/Application Support/Cursor"
CURSOR_HOME="${HOME}/.cursor"
CURSOR_HOME_EXTERNAL="${CURSOR_EXTERNAL_BASE}/${CURSOR_DOT_CURSOR_DIR}"

log() { printf '[cursor-external-drive] %s\n' "$*"; }
die() { printf '[cursor-external-drive] ERROR: %s\n' "$*" >&2; exit 1; }

resolve_cursor_app_cache_name() {
  if [[ -n "${CURSOR_APP_CACHE_NAME:-}" ]]; then
    printf '%s' "${CURSOR_APP_CACHE_NAME}"
    return 0
  fi

  local cursor_info="/Applications/Cursor.app/Contents/Info"
  if [[ -f "${cursor_info}" ]]; then
    local bundle_id
    bundle_id="$(defaults read "${cursor_info}" CFBundleIdentifier 2>/dev/null || true)"
    if [[ -n "${bundle_id}" ]]; then
      printf '%s' "${bundle_id}"
      return 0
    fi
  fi

  local dir name
  for dir in "${HOME}/Library/Caches"/com.todesktop.*; do
    [[ -d "${dir}" ]] || continue
    name="$(basename "${dir}")"
    [[ "${name}" == *.ShipIt ]] && continue
    printf '%s' "${name}"
    return 0
  done

  return 1
}

if ! CURSOR_APP_CACHE_NAME="$(resolve_cursor_app_cache_name)"; then
  die "Could not detect Cursor app cache folder. Install Cursor or set CURSOR_APP_CACHE_NAME in ${CONFIG_FILE}"
fi

CURSOR_APP_CACHE="${HOME}/Library/Caches/${CURSOR_APP_CACHE_NAME}"
CURSOR_APP_CACHE_EXTERNAL="${CURSOR_EXTERNAL_BASE}/${CURSOR_APP_CACHE_NAME}"

require_volume() {
  if [[ ! -d "${CURSOR_EXTERNAL_VOLUME}" ]]; then
    die "External volume not mounted: ${CURSOR_EXTERNAL_VOLUME}"
  fi
  mkdir -p "${CURSOR_EXTERNAL_BASE}"
}

cursor_running() {
  pgrep -f "Cursor.app" >/dev/null 2>&1
}

link_path() {
  local src="$1"
  local dest="$2"

  if [[ -L "${src}" ]]; then
    local target
    target="$(readlink "${src}")"
    if [[ "${target}" == "${dest}" ]]; then
      log "OK  ${src} -> ${dest}"
      return 0
    fi
    log "FIX ${src} (was -> ${target})"
    rm "${src}"
  elif [[ -d "${src}" ]]; then
    log "MOVE ${src} -> ${dest}"
    mkdir -p "${dest}"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "${src}/" "${dest}/"
    else
      ditto "${src}" "${dest}"
    fi
    rm -rf "${src}"
  elif [[ -e "${src}" ]]; then
    die "Unexpected file at ${src}; remove manually and re-run."
  else
    log "NEW ${dest}"
    mkdir -p "${dest}"
  fi

  ln -s "${dest}" "${src}"
  log "LINK ${src} -> ${dest}"
}

link_dir() {
  local parent="$1"
  local name="$2"
  link_path "${parent}/${name}" "${CURSOR_EXTERNAL_BASE}/${name}"
}

needs_user_data_migration() {
  [[ -d "${CURSOR_SUPPORT}/User" && ! -L "${CURSOR_SUPPORT}/User" ]] \
    || [[ -d "${CURSOR_HOME}" && ! -L "${CURSOR_HOME}" ]]
}

SUPPORT_CACHE_DIRS=(
  "Cache"
  "CachedData"
  "GPUCache"
  "Code Cache"
  "CachedExtensionVSIXs"
  "CachedProfilesData"
  "CachedConfigurations"
  "DawnGraphiteCache"
  "DawnWebGPUCache"
  "logs"
  "Partitions"
  "WebStorage"
  "VideoDecodeStats"
)
