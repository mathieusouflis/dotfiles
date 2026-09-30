#!/bin/sh

set -eu

if osascript -e 'application "Ghostty" is running' 2>/dev/null | grep -q true; then
  osascript \
    -e 'tell application "Ghostty"' \
    -e 'activate' \
    -e 'set win to new window' \
    -e 'end tell'
else
  open -a Ghostty
fi
