<div align="center">
  <h1>macOS Screenshot Linker</h1>
  <p>Automatically copy a <code>file://</code> link to the latest screenshot on macOS.</p>

  <p>
    <a href="https://github.com/SergeyAlbina/macos-screenshot-linker/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/SergeyAlbina/macos-screenshot-linker"></a>
    <a href="https://github.com/SergeyAlbina/macos-screenshot-linker/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/SergeyAlbina/macos-screenshot-linker"></a>
    <a href="https://github.com/SergeyAlbina/macos-screenshot-linker/actions/workflows/ci.yml"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/SergeyAlbina/macos-screenshot-linker/ci.yml?branch=main"></a>
    <a href="https://github.com/SergeyAlbina/macos-screenshot-linker/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/SergeyAlbina/macos-screenshot-linker"></a>
  </p>
</div>

## Why

When you take screenshots all day, sharing paths manually is slow. This tool watches your screenshot folder and instantly copies the latest screenshot link to clipboard.

## Features

- Auto-detects new screenshots (`png`, `jpg`, `jpeg`, `heic`)
- Copies `file://...` URL to clipboard immediately
- Optional macOS notification after each screenshot
- Installs as a user `launchd` agent
- One-command install and uninstall

## Quick Start

```bash
git clone https://github.com/SergeyAlbina/macos-screenshot-linker.git
cd macos-screenshot-linker
./scripts/install.sh
```

Take a screenshot with `Cmd+Shift+4`, then run:

```bash
pbpaste
```

Expected output:

```text
file:///Users/<you>/Pictures/Screenshots/Screen%20Shot%202026-02-23%20at%2015.44.12.png
```

## Install Options

```bash
# Custom screenshot directory
./scripts/install.sh --dir "$HOME/Pictures/MyShots"

# Disable macOS notifications
./scripts/install.sh --no-notify
```

## Uninstall

```bash
./scripts/uninstall.sh
```

## How It Works

1. `launchd` watches your screenshot directory.
2. On new file creation, it runs `scripts/screenshot_copy_link.sh`.
3. The script finds the newest screenshot and writes its `file://` URL to clipboard.
4. State file prevents duplicate clipboard updates.

## Project Layout

```text
scripts/
  install.sh
  uninstall.sh
  screenshot_copy_link.sh
launchd/
  io.github.screenshot-linker.clipboard.plist.example
```

## Roadmap

See [`ROADMAP.md`](ROADMAP.md).

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).

## Troubleshooting

- Agent status:

```bash
launchctl print "gui/$(id -u)/io.github.screenshot-linker.clipboard"
```

- Check logs:

```bash
tail -n 100 /tmp/io.github.screenshot-linker.clipboard.err.log
tail -n 100 /tmp/io.github.screenshot-linker.clipboard.out.log
```

- Verify screenshot location:

```bash
defaults read com.apple.screencapture location
```

## Contributing

PRs are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

MIT, see [`LICENSE`](LICENSE).
