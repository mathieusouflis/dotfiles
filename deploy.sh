#!/bin/sh
# deploys every package to its correct target.
# each tool gets its own target dir since they don't all live under the
# same root — see README for why.
set -e
cd "$(dirname "$0")"

mkdir -p ~/.config/ghostty ~/.config/git ~/.config/nvim

stow -t ~/.config/ghostty ghostty
stow -t ~/.config/git git
stow -t ~/.config/nvim nvim
stow -t ~/.config starship
stow -t ~ zsh

echo "done"
