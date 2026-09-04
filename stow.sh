#!/bin/sh
# stows every package to its target. standalone, also aliased as
# `restow` in zsh/.zshrc.
set -e
cd "$(dirname "$0")"

mkdir -p ~/.config/ghostty ~/.config/git ~/.config/nvim ~/.config/atuin ~/.config/gh-dash ~/.config/nix ~/.config/zed

stow -t ~/.config/ghostty ghostty
stow -t ~/.config/git git
stow -t ~/.config/nvim nvim
stow -t ~/.config/atuin atuin
stow -t ~/.config/gh-dash gh-dash
stow -t ~/.config starship
stow -t ~/.config/nix nix
stow -t ~/.config/zed zed
stow -t ~ zsh
stow -t ~ vim
stow -t ~ aerospace
stow -t ~/.config/karabiner karabiner --adopt

echo "stowed"
