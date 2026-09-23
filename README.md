# dotfiles

cross-platform config for macOS and school Linux. The existing Stow
bootstrap remains available while the Home Manager migration is validated.
Each package folder has its own README with what it's for -- this file is an
index, plus the rule for how that documentation stays honest.

forking this for yourself? see [FORKING.md](FORKING.md) for what's
hardcoded to me and needs to change first.

## the rule

docs live at the point of decision, not in a wiki that rots. a
package's README says what it's for; anything non-obvious about a
specific line (a constraint, a workaround, an ordering requirement)
is a comment on that line, in that file -- see the SECTION comments in
`zsh/.zshrc` or the notes throughout `nix-darwin/flake.nix` for what
that looks like in practice. this file only holds what's genuinely
about the whole repo: how the packages map to targets, and how to
install.

## layout

The repository has three layers:

- the existing tool folders, which remain the source files and keep their
  history;
- `modules/shared`, which exposes those files to Home Manager on both
  machines;
- `hosts/home` and `hosts/school`, which contain platform-specific files and
  activation settings.

each folder is a package, one dotfile per folder, flat, no nesting.

| package | purpose | target |
|---|---|---|
| [ghostty](ghostty/README.md) | terminal | `~/.config/ghostty/` |
| [git](git/README.md) | git config + ignore | `~/.config/git/` |
| [nvim](nvim/README.md) | editor (LazyVim) | `~/.config/nvim/` |
| [atuin](atuin/README.md) | shell history | `~/.config/atuin/` |
| [gh-dash](gh-dash/README.md) | `gh` dashboard extension | `~/.config/gh-dash/` |
| [starship](starship/README.md) | prompt | `~/.config/starship.toml` |
| [nix](nix/README.md) | user-level Nix settings | `~/.config/nix/` |
| [zed](zed/README.md) | editor | `~/.config/zed/` |
| [zsh](zsh/README.md) | shell | `~/.zshrc` |
| [vim](vim/README.md) | editor (plain vimrc) | `~/.vimrc` |
| [nix-darwin](nix-darwin/README.md) | system flake, not stowed | n/a |

they don't all land in the same place: ghostty, git, nvim, atuin,
gh-dash, nix, and zed each get their own folder under `~/.config`.
starship's file sits right in `~/.config` with no subfolder. zsh and
vim have no XDG spot at all, so they target `$HOME` directly. `init.sh`
(and `.stowrc`'s ignore patterns) handle this.

every themeable tool here runs the same [Version 14](https://github.com/version14)
palette (Dark/Black/Light) -- see each package's own README for where
its copy lives and which variant is active.

`nix-darwin` and raycast aren't stow packages; see
[nix-darwin/README.md](nix-darwin/README.md) for both, plus the
default-browser and devenv setup.

## init

```bash
./init.sh
```
checks that Nix and Homebrew are installed (prints instructions and
exits if not; it won't run their installers for you, since those need
sudo), applies the `nix-darwin` flake (first-time bootstrap via
`nix run nix-darwin` if `darwin-rebuild` isn't on `PATH` yet, otherwise
`darwin-rebuild switch` directly), runs `stow.sh` (below), and installs
the `gh-dash` extension if `gh` is present. safe to re-run any time,
every step it takes is idempotent. During the migration it still runs Stow;
do not remove that step until Home Manager has been tested on both machines.

The flake also exposes the two Home Manager entry points:

```bash
# macOS, through nix-darwin
darwin-rebuild switch --flake ~/dotfiles/nix-darwin

# school Linux, standalone and without root
home-manager switch --flake ~/dotfiles/nix-darwin#math@school
```

On EPITA machines, the session entry point is the repository's `install.sh`:
EPITA calls `$AFS_DIR/.confs/install.sh` at login. It pulls the latest `main`,
enables flakes in the user Nix configuration, checks the host Nix version,
activates the pinned Home Manager generation, and restores an optional
wallpaper link. The repository must therefore be cloned at `$AFS_DIR/.confs`.

The school configuration uses Nixpkgs and Home Manager `26.05`, locked in
`nix-darwin/flake.lock`. The host Nix installation is not replaced by the
flake; it must be Nix 2.4 or newer because flakes were introduced there.

`stow.sh` just does the stow half, every package to its correct
target, without the prerequisite checks or the flake apply. useful on
its own after editing a config, so it's also aliased as `restow` in
`.zshrc`:
```bash
./stow.sh
# or, from anywhere, once the alias is stowed:
restow
```
to stow packages by hand, or just one:
```bash
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
```
add `-n -v` to any of those to preview what it would do first.

## adding a package

make a folder named after the tool, put its file(s) in flat with no
extra nesting, add a short README (what it's for), then add a line to
`stow.sh` (and the table above) with the right target, the folder that
would directly contain those files once deployed.
