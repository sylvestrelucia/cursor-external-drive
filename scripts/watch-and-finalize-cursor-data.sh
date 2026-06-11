#!/usr/bin/env bash
# Waits for Cursor to quit, then runs finalize-cursor-data.sh once.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"
FINALIZE="${SCRIPT_DIR}/finalize-cursor-data.sh"
LOG="${HOME}/Library/Logs/cursor-external-drive-watcher.log"

exec >>"${LOG}" 2>&1
echo "[$(date)] Watcher started"

while cursor_running; do
  sleep 15
done

echo "[$(date)] Cursor quit — finalizing symlinks"
"${FINALIZE}"
echo "[$(date)] Watcher finished"
