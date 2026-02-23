#!/usr/bin/env bash
set -euo pipefail

SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
STATE_DIR="${STATE_DIR:-$HOME/Library/Caches}"
STATE_FILE="${STATE_FILE:-$STATE_DIR/io.github.screenshot-linker.last}"
NOTIFY="${NOTIFY:-1}"
MAX_AGE_SECONDS="${MAX_AGE_SECONDS:-60}"

mkdir -p "$SCREENSHOT_DIR" "$STATE_DIR"

shopt -s nullglob
files=(
  "$SCREENSHOT_DIR"/*.png
  "$SCREENSHOT_DIR"/*.jpg
  "$SCREENSHOT_DIR"/*.jpeg
  "$SCREENSHOT_DIR"/*.heic
)

if [[ ${#files[@]} -eq 0 ]]; then
  exit 0
fi

latest_file="${files[0]}"
for f in "${files[@]}"; do
  if [[ "$f" -nt "$latest_file" ]]; then
    latest_file="$f"
  fi
done

if [[ -f "$STATE_FILE" ]]; then
  last_file="$(<"$STATE_FILE")"
  if [[ "$latest_file" == "$last_file" ]]; then
    exit 0
  fi
fi

now_epoch="$(date +%s)"
mtime_epoch="$(stat -f %m "$latest_file" 2>/dev/null || echo 0)"
if (( now_epoch - mtime_epoch > MAX_AGE_SECONDS )); then
  exit 0
fi

if command -v python3 >/dev/null 2>&1; then
  file_url="$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).resolve().as_uri())' "$latest_file")"
else
  file_url="file://$latest_file"
fi

printf '%s' "$file_url" | pbcopy || true

if command -v osascript >/dev/null 2>&1; then
  escaped_url="${file_url//\\/\\\\}"
  escaped_url="${escaped_url//\"/\\\"}"
  osascript -e "set the clipboard to \"$escaped_url\"" >/dev/null 2>&1 || true

  if [[ "$NOTIFY" == "1" ]]; then
    osascript -e 'display notification "File link copied to clipboard" with title "Screenshot saved"' >/dev/null 2>&1 || true
  fi
fi

printf '%s' "$latest_file" >"$STATE_FILE"
