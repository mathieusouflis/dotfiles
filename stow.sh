#!/bin/sh

set -eu

DOTFILES="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
HOME="${HOME:?HOME is not set}"

cd "$DOTFILES"

# Helpers

ensure_dir() {
    if [ -e "$1" ] && [ ! -d "$1" ]; then
        echo "error: $1 exists but is not a directory" >&2
        exit 1
    fi

    mkdir -p "$1"
}

stow_package() {
    package="$1"
    target="$2"
    shift 2

    if [ ! -d "$DOTFILES/$package" ]; then
        echo "error: stow package does not exist: $package" >&2
        exit 1
    fi

    ensure_dir "$target"

    echo "→ $package → $target"
    stow --target="$target" "$@" "$package"
}

# Targets
stow_package ghostty   "$HOME/.config/ghostty"
stow_package git       "$HOME/.config/git"
stow_package nvim      "$HOME/.config/nvim"
stow_package atuin     "$HOME/.config/atuin"
stow_package gh-dash   "$HOME/.config/gh-dash"
stow_package starship  "$HOME/.config"
stow_package nix       "$HOME/.config/nix"
stow_package zed       "$HOME/.config/zed"
stow_package alacritty "$HOME/.config/alacritty" --adopt
stow_package helix     "$HOME/.config/helix" --adopt

stow_package zsh       "$HOME"
stow_package vim       "$HOME"
stow_package aerospace "$HOME"

stow_package karabiner "$HOME/.config/karabiner" --adopt

echo "✓ stowed"

