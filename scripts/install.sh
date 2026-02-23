#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Install screenshot-linker launch agent.

Usage:
  scripts/install.sh [--dir <path>] [--no-notify]

Options:
  --dir <path>   Screenshot directory (default: ~/Pictures/Screenshots)
  --no-notify    Disable macOS notifications
  -h, --help     Show this help
USAGE
}

xml_escape() {
  local s="$1"
  s=${s//&/&amp;}
  s=${s//</&lt;}
  s=${s//>/&gt;}
  s=${s//\"/&quot;}
  s=${s//\'/&apos;}
  printf '%s' "$s"
}

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
NOTIFY="1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --dir" >&2
        exit 1
      fi
      SCREENSHOT_DIR="$2"
      shift 2
      ;;
    --no-notify)
      NOTIFY="0"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

LABEL="io.github.screenshot-linker.clipboard"
INSTALL_DIR="$HOME/Library/Application Support/macos-screenshot-linker"
RUNTIME_SCRIPT="$INSTALL_DIR/screenshot_copy_link.sh"
AGENT_PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_OUT="/tmp/$LABEL.out.log"
LOG_ERR="/tmp/$LABEL.err.log"

mkdir -p "$SCREENSHOT_DIR" "$HOME/Library/LaunchAgents" "$INSTALL_DIR"
cp "$REPO_ROOT/scripts/screenshot_copy_link.sh" "$RUNTIME_SCRIPT"
chmod +x "$RUNTIME_SCRIPT"

escaped_runtime_script="$(xml_escape "$RUNTIME_SCRIPT")"
escaped_screenshot_dir="$(xml_escape "$SCREENSHOT_DIR")"
escaped_log_out="$(xml_escape "$LOG_OUT")"
escaped_log_err="$(xml_escape "$LOG_ERR")"

cat >"$AGENT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>

  <key>ProgramArguments</key>
  <array>
    <string>$escaped_runtime_script</string>
  </array>

  <key>EnvironmentVariables</key>
  <dict>
    <key>SCREENSHOT_DIR</key>
    <string>$escaped_screenshot_dir</string>
    <key>NOTIFY</key>
    <string>$NOTIFY</string>
  </dict>

  <key>WatchPaths</key>
  <array>
    <string>$escaped_screenshot_dir</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>$escaped_log_out</string>

  <key>StandardErrorPath</key>
  <string>$escaped_log_err</string>
</dict>
</plist>
PLIST

# Make screenshots save to the watched folder.
defaults write com.apple.screencapture location "$SCREENSHOT_DIR"
killall SystemUIServer >/dev/null 2>&1 || true

launchctl bootout "gui/$(id -u)" "$AGENT_PLIST" >/dev/null 2>&1 || true
launchctl enable "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$AGENT_PLIST"
launchctl kickstart -k "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true

echo "Installed."
echo "Screenshots directory: $SCREENSHOT_DIR"
echo "LaunchAgent: $AGENT_PLIST"
echo "Try: Cmd+Shift+4 and then run pbpaste"
