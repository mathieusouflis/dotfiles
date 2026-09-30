#!/usr/bin/env bash
set -euo pipefail

# EPITA normally exports AFS_DIR. The fallback matches the local school path
# and is also useful when testing the bootstrap in a VM.
afs_dir="${AFS_DIR:-$HOME/afs}"
dotfiles_dir="$afs_dir/.confs"

trap 'printf "error: school bootstrap failed near line %s\n" "$LINENO" >&2' ERR

if [ ! -d "$dotfiles_dir/.git" ]; then
  printf 'error: expected the dotfiles Git checkout at %s\n' "$dotfiles_dir" >&2
  printf 'hint: clone it with: git clone <repo-url> %s\n' "$dotfiles_dir" >&2
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

# Home Manager owns the repository's declared files. This separate tree is
# for extra school-only applications (for example Firefox or Discord) whose
# config layout should be copied exactly without adding a Nix declaration for
# every new application. It is ignored by Git and persists in AFS.
sync_home_tree() {
  source_root="$1"
  target_root="$2"

  [ -d "$source_root" ] || return 0
  mkdir -p "$target_root"

  find "$source_root" -mindepth 1 -print0 | while IFS= read -r -d '' source_path; do
    relative_path="${source_path#"$source_root"/}"
    target_path="$target_root/$relative_path"

    if [ -d "$source_path" ] && [ ! -L "$source_path" ]; then
      mkdir -p "$target_path"
      continue
    fi

    mkdir -p "$(dirname "$target_path")"
    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
      continue
    fi
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
      backup_path="$target_path.pre-confs"
      if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
        backup_path="$target_path.pre-confs.$(date +%s)"
      fi
      mv "$target_path" "$backup_path"
      printf 'backed up existing %s to %s\n' "$target_path" "$backup_path"
    fi
    ln -s "$source_path" "$target_path"
  done
}

sync_home_tree "$dotfiles_dir/home" "$HOME"

# Keep an optional image in persistent AFS while deploying it to ephemeral
# $HOME. The i3 config only calls feh when this link exists.
wallpaper_source="$dotfiles_dir/hosts/school/wallpaper"
if [ -f "$wallpaper_source" ]; then
  mkdir -p "$HOME/.config"
  ln -sfn "$wallpaper_source" "$HOME/.config/wallpaper"
fi

# SSH keys are persistent AFS data, never repository data. Link only files
# that the user has explicitly placed in $AFS_DIR/.ssh.
afs_ssh_dir="$afs_dir/.ssh"
if [ -d "$afs_ssh_dir" ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  for ssh_file in "$afs_ssh_dir"/*; do
    [ -f "$ssh_file" ] || continue
    ssh_name="$(basename "$ssh_file")"
    ln -sfn "$ssh_file" "$HOME/.ssh/$ssh_name"
    case "$ssh_name" in
      id_*|*.pem) chmod 600 "$ssh_file" ;;
    esac
  done
fi
