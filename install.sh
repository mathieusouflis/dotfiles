#!/usr/bin/env bash
set -euo pipefail

# EPITA calls $AFS_DIR/.confs/install.sh at the start of every session.
# AFS is the persistent filesystem; $HOME is the ephemeral deployed target.
afs_dir="${AFS_DIR:?AFS_DIR must point to your persistent AFS directory}"
dotfiles_dir="$afs_dir/.confs"

if [ ! -d "$dotfiles_dir/.git" ]; then
  printf 'error: expected the dotfiles Git checkout at %s\n' "$dotfiles_dir" >&2
  exit 1
fi

cd "$dotfiles_dir"
git pull --ff-only origin main

mkdir -p "$HOME/.config/nix"
if ! grep -q '^experimental-features =.*nix-command.*flakes' "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  printf '%s\n' 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"
fi

nix_version="$(nix --version | awk '{print $3}')"
nix_major="${nix_version%%.*}"
nix_minor="${nix_version#*.}"
nix_minor="${nix_minor%%.*}"
if [ "$nix_major" -lt 2 ] || { [ "$nix_major" -eq 2 ] && [ "$nix_minor" -lt 4 ]; }; then
  printf 'error: Nix %s is too old; this flake requires Nix 2.4 or newer for flakes.\n' "$nix_version" >&2
  exit 1
fi

nix --extra-experimental-features 'nix-command flakes' run \
  github:nix-community/home-manager/release-26.05 -- \
  switch --flake "$dotfiles_dir/nix-darwin#math@school"

# Keep an optional image in persistent AFS while deploying it to ephemeral
# $HOME. The i3 config only calls feh when this link exists.
wallpaper_source="$dotfiles_dir/hosts/school/wallpaper"
if [ -f "$wallpaper_source" ]; then
  mkdir -p "$HOME/.config"
  ln -sfn "$wallpaper_source" "$HOME/.config/wallpaper"
fi
