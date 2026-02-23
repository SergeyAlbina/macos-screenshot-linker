#!/usr/bin/env bash
set -euo pipefail

LABEL="io.github.screenshot-linker.clipboard"
AGENT_PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
INSTALL_DIR="$HOME/Library/Application Support/macos-screenshot-linker"
RUNTIME_SCRIPT="$INSTALL_DIR/screenshot_copy_link.sh"

launchctl bootout "gui/$(id -u)" "$AGENT_PLIST" >/dev/null 2>&1 || true
launchctl disable "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true

rm -f "$AGENT_PLIST"
rm -f "$RUNTIME_SCRIPT"
rmdir "$INSTALL_DIR" >/dev/null 2>&1 || true

echo "Uninstalled launch agent and runtime script."
echo "Note: screenshot save location was not changed back."
