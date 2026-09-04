#!/bin/sh
# bootstraps this machine: prerequisites, nix-darwin, stow, gh-dash.
set -e
cd "$(dirname "$0")"

# ~/.zprofile only loads for login shells, so PATH is set explicitly
# here to work regardless of how this script gets invoked.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

log() { printf '==> %s\n' "$1"; }
warn() { printf 'warning: %s\n' "$1" >&2; }

log "Checking prerequisites..."

if ! command -v nix >/dev/null 2>&1; then
  cat >&2 <<'EOF'
error: Nix is not installed.

Install it (Determinate Nix, used on this machine):
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install

Then re-run this script.
EOF
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  cat >&2 <<'EOF'
error: Homebrew is not installed (required by nix-darwin's homebrew.casks).

Install it:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then re-run this script.
EOF
  exit 1
fi

log "Applying nix-darwin flake..."
if command -v darwin-rebuild >/dev/null 2>&1; then
  darwin-rebuild switch --flake "$PWD/nix-darwin"
else
  log "No darwin-rebuild on PATH yet, first-time bootstrap (needs sudo)"
  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake "$PWD/nix-darwin"
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "error: stow still not on PATH after applying the flake, check nix-darwin/flake.nix" >&2
  exit 1
fi

log "Stowing dotfiles..."
./stow.sh

if command -v gh >/dev/null 2>&1; then
  if ! gh extension list 2>/dev/null | grep -q dlvhdr/gh-dash; then
    log "Installing gh-dash extension..."
    gh extension install dlvhdr/gh-dash
  fi
else
  warn "gh not found, skipping gh-dash extension install"
fi

open /Applications/Raycast.app/
open /Applications/AeroSpace.app/

log "Done. Remaining manual steps (Xcode CLT, per-project devenv setup) are in README.md."
