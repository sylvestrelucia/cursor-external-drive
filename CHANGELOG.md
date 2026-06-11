# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-06-11

### Added

- Initial release: symlink-based Cursor cache and user data migration for macOS
- Scripts: `setup-cursor-cache`, `sync-cursor-data`, `finalize-cursor-data`, `verify`, `mount-external-volume`, `watch-and-finalize`
- `install.sh` / `uninstall.sh` with LaunchAgent for hourly symlink maintenance
- Auto-detection of Cursor app cache folder via `CFBundleIdentifier`
- Documentation: architecture, troubleshooting, contributing guides
- Config via `~/.config/cursor-external-drive/config.env`

[1.0.0]: https://github.com/sylvestrelucia/cursor-external-drive/releases/tag/v1.0.0
