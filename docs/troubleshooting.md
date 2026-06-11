# Troubleshooting

## Verification first

Always run:

```bash
~/Library/Scripts/cursor-external-drive/verify-cursor-external-drive.sh
```

Check the external volume is mounted:

```bash
ls "/Volumes/External HD/CursorCache"
```

Replace `External HD` with your configured volume name.

---

## `Operation not permitted`

**Cause:** macOS Transparency, Consent, and Control (TCC) blocking access to external volumes or `state.vscdb`.

**Fix:**

1. Run scripts from `~/Library/Scripts/cursor-external-drive/` (after `./install.sh`), not from a clone on the external drive.
2. **System Settings → Privacy & Security → Full Disk Access** — add Terminal (or iTerm).
3. Re-run `finalize-cursor-data.sh` with Cursor quit.

---

## Cursor opens with empty / default settings

**Cause:** External volume not mounted; symlinks point to missing paths.

**Fix:**

1. Mount the drive (`mount-external-volume.sh` or Finder).
2. Confirm symlinks: `ls -la ~/.cursor ~/Library/Application\ Support/Cursor/User`
3. Restart Cursor.
4. If symlinks were replaced by real folders after an update, run `setup-cursor-cache.sh`.

---

## `state.vscdb` sync stuck or incomplete

**Cause:** File is large (often 20–40 GB) and may be locked while Cursor runs.

**Fix:**

1. Let Phase 1 rsync complete (can take 30+ minutes on HDD).
2. Quit Cursor (`Cmd+Q`).
3. Run `finalize-cursor-data.sh` for a consistent final copy.
4. Compare sizes:
   ```bash
   du -sh ~/Library/Application\ Support/Cursor/User/globalStorage/state.vscdb
   du -sh "/Volumes/External HD/CursorCache/User/globalStorage/state.vscdb"
   ```

---

## LaunchAgent not repairing symlinks

**Check loaded agent:**

```bash
launchctl list | grep cursor-external-drive
```

**Read log:**

```bash
tail -50 ~/Library/Logs/cursor-external-drive-setup.log
```

**Reinstall:**

```bash
cd /path/to/cursor-external-drive
./uninstall.sh && ./install.sh
```

---

## Revert to internal drive

See [README — Uninstall / revert](../README.md#uninstall--revert).

Always quit Cursor before removing symlinks or copying data back.
