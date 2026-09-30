#!/bin/sh

set -eu

if pgrep -x Ghostty >/dev/null 2>&1; then
  osascript \
    -e 'tell application "Ghostty" to activate' \
    -e 'tell application "Ghostty" to set win to new window'
else
  open -a Ghostty
fi
