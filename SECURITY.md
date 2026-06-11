# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| `main` branch | Yes |

## Reporting a vulnerability

This project runs **local shell scripts only** — it does not expose network services or handle credentials.

If you find a security issue (e.g. unsafe `rm -rf` paths, symlink escape, destructive defaults):

1. **Do not** open a public issue with exploit details.
2. Open a private security advisory on GitHub: **Security → Advisories → New draft**, or contact the maintainer via GitHub.

Include steps to reproduce and affected script versions.

## Scope

- Scripts in `scripts/`, `install.sh`, `uninstall.sh`
- LaunchAgent plist generation in `install.sh`

Out of scope: Cursor IDE itself, macOS, or third-party drive firmware.
