# Contributing

Thanks for helping improve **cursor-external-drive**.

## Ways to contribute

- **Bug reports** — steps to reproduce, macOS version, Cursor version, drive type (SSD/HDD)
- **Documentation** — README clarity, new FAQ entries, troubleshooting cases
- **Scripts** — idempotent fixes, safer rsync, better detection logic

## Development setup

```bash
git clone https://github.com/sylvestrelucia/cursor-external-drive.git
cd cursor-external-drive
cp config.example.env /tmp/cursor-external-drive-test.env
# Edit CURSOR_EXTERNAL_VOLUME for a test volume or temp directory
export CURSOR_EXTERNAL_CONFIG=/tmp/cursor-external-drive-test.env
./scripts/verify-cursor-external-drive.sh  # after migration on a test machine
```

Test on a **non-production** Mac or after backing up Cursor data. Do not run migration scripts against your only copy of `User/` without a backup.

## Pull request guidelines

1. **One concern per PR** when possible (e.g. docs-only vs script behavior).
2. **ShellCheck** — keep scripts compatible with macOS default Bash 3.2 / Bash 5.
3. **Idempotency** — scripts must be safe to re-run.
4. **No hardcoded paths** — use `config.env` / `lib.sh` variables.
5. **No personal paths** in examples (`/Volumes/External HD`, `com.example`, etc.).

## Commit messages

Use clear, imperative subjects:

- `Fix symlink detection when Cursor.app is missing`
- `Document Thunderbolt drive recommendations`
- `Add FAQ entry for network drives`

## Code of conduct

Be respectful in issues and reviews. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Questions

Open a [GitHub issue](https://github.com/sylvestrelucia/cursor-external-drive/issues) for questions that are not security-sensitive.
