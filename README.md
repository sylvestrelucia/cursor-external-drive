# cursor-external-drive

Move [Cursor](https://cursor.com) cache and user data from your Mac’s internal drive to an external volume using symlinks. Frees tens of gigabytes on the main disk while keeping settings, extensions, agent projects, and cache intact.

Tested on **macOS** with Cursor (Electron / VS Code fork).

## What gets moved

| Local path | External folder | Typical size |
|------------|-----------------|--------------|
| `~/Library/Application Support/Cursor/User` | `CursorCache/User` | 1–40+ GB |
| `~/.cursor` | `CursorCache/dot-cursor` | 0.5–2 GB |
| `~/Library/Application Support/Cursor/Cache` | `CursorCache/Cache` | varies |
| `~/Library/Application Support/Cursor/CachedData` | `CursorCache/CachedData` | varies |
| `~/Library/Application Support/Cursor/GPUCache` | `CursorCache/GPUCache` | small |
| + 10 other cache dirs under `Application Support/Cursor/` | `CursorCache/…` | varies |
| `~/Library/Caches/<Cursor bundle id>/` | `CursorCache/<same name>/` | small |

**Stays on internal drive** (small runtime data): `IndexedDB`, `Local Storage`, `Crashpad`, etc.

## Requirements

- macOS
- External drive formatted for macOS (APFS or HFS+)
- `rsync` (pre-installed on macOS)
- Enough free space on the external drive for your Cursor data

## Quick start

```bash
git clone https://github.com/sylvestrelucia/cursor-external-drive.git
cd cursor-external-drive
./install.sh
```

Edit `~/.config/cursor-external-drive/config.env` and set your volume name (as shown in Finder under `/Volumes/`, e.g. `External HD`):

```bash
CURSOR_EXTERNAL_VOLUME="/Volumes/External HD"
CURSOR_EXTERNAL_BASE="${CURSOR_EXTERNAL_VOLUME}/CursorCache"
```

### Migration (two phases)

**Phase 1 — cache + copy user data** (Cursor can stay open):

```bash
~/Library/Scripts/cursor-external-drive/setup-cursor-cache.sh
```

This symlinks cache folders immediately and copies `User` + `~/.cursor` to the external drive.

**Phase 2 — symlink user data** (Cursor must be quit):

```bash
# Cmd+Q to quit Cursor, then:
~/Library/Scripts/cursor-external-drive/finalize-cursor-data.sh
```

Reopen Cursor. Verify:

```bash
~/Library/Scripts/cursor-external-drive/verify-cursor-external-drive.sh
```

## Scripts

| Script | Purpose |
|--------|---------|
| `setup-cursor-cache.sh` | Main script: cache symlinks + sync or move user data |
| `sync-cursor-data.sh` | Copy only `User` + `~/.cursor` to external drive |
| `finalize-cursor-data.sh` | Final sync + symlink swap (Cursor must be quit) |
| `watch-and-finalize-cursor-data.sh` | Background watcher: finalize when Cursor quits |
| `verify-cursor-external-drive.sh` | Health check for symlinks and readability |
| `install.sh` | Install scripts + hourly LaunchAgent |
| `uninstall.sh` | Remove LaunchAgent only |

All scripts read `~/.config/cursor-external-drive/config.env` (created by `install.sh` from `config.example.env`).

## LaunchAgent

`install.sh` registers an agent that re-runs `setup-cursor-cache.sh` at login and every hour **when the external volume is mounted**. This repairs symlinks if a Cursor update recreates real folders on the internal drive.

Logs: `~/Library/Logs/cursor-external-drive-setup.log`

Remove with `./uninstall.sh`.

## Configuration

`config.example.env`:

```bash
CURSOR_EXTERNAL_VOLUME="/Volumes/External HD"
CURSOR_EXTERNAL_BASE="${CURSOR_EXTERNAL_VOLUME}/CursorCache"
CURSOR_DOT_CURSOR_DIR="dot-cursor"
CURSOR_SCRIPTS_DIR="${HOME}/Library/Scripts/cursor-external-drive"
CURSOR_LAUNCHD_LABEL="com.example.cursor-external-drive"
# CURSOR_APP_CACHE_NAME="com.todesktop.XXXXXXXXXX"  # optional; auto-detected from Cursor.app
```

Override config path: `CURSOR_EXTERNAL_CONFIG=/path/to/config.env ./scripts/setup-cursor-cache.sh`

The `~/Library/Caches/…` folder name is Cursor’s macOS bundle identifier (`CFBundleIdentifier` from `/Applications/Cursor.app`). Scripts detect it automatically; set `CURSOR_APP_CACHE_NAME` only if detection fails.

## Important notes

1. **Keep the external drive mounted** before launching Cursor. If it’s disconnected, Cursor won’t find settings or cache.
2. **Prevent sleep** during large initial copies (especially `User/globalStorage/state.vscdb`, which can be 30+ GB).
3. **Install scripts on the internal drive** — LaunchAgents cannot reliably execute scripts stored on external volumes (`Operation not permitted`). `install.sh` copies scripts to `~/Library/Scripts/cursor-external-drive/`.
4. **Quit Cursor** before the finalize step. Cursor cannot quit itself from an integrated terminal; use `Cmd+Q` or run finalize from an external Terminal.app window.
5. **Re-run safely** — scripts skip paths already symlinked correctly.

## Troubleshooting

### `Operation not permitted` on external volume

- Run scripts from `~/Library/Scripts/cursor-external-drive/` (after `install.sh`), not from the external drive copy.
- Grant **Full Disk Access** to Terminal if rsync fails on `state.vscdb`.

### Cursor opens with default settings

- External drive not mounted → mount it and restart Cursor.
- Run `verify-cursor-external-drive.sh` and fix any broken symlinks with `setup-cursor-cache.sh`.

### Large `state.vscdb`

Cursor stores extension/global state in `User/globalStorage/state.vscdb`. It can grow very large. Phase 1 sync may take 10–30+ minutes; the finalize step needs Cursor quit so the database isn’t locked.

## Uninstall / revert

To move back to the internal drive:

1. Quit Cursor.
2. Remove symlinks and restore data:
   ```bash
   rsync -a "/Volumes/External HD/CursorCache/User/" "$HOME/Library/Application Support/Cursor/User-restored/"
   rsync -a "/Volumes/External HD/CursorCache/dot-cursor/" "$HOME/.cursor-restored/"
   # Remove symlinks, rename restored folders back to User and .cursor
   ```
3. Run `./uninstall.sh` and delete `~/Library/Scripts/cursor-external-drive/` if desired.

## License

MIT
