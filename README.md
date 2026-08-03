# dotfiles

my mac config, managed with stow.

## layout

each folder is a package, one dotfile per folder, flat, no nesting.
```
 ghostty/config       >  ~/.config/ghostty/config
 ghostty/themes/...   >  ~/.config/ghostty/themes/...
 git/config           >  ~/.config/git/config
 git/ignore           >  ~/.config/git/ignore
 nvim/...             >  ~/.config/nvim/...
 atuin/config.toml    >  ~/.config/atuin/config.toml
 atuin/themes/...     >  ~/.config/atuin/themes/...
 gh-dash/config.yml   >  ~/.config/gh-dash/config.yml
 starship/starship.toml  >  ~/.config/starship.toml
 nix/nix.conf         >  ~/.config/nix/nix.conf
 zed/settings.json    >  ~/.config/zed/settings.json
 zed/keymap.json      >  ~/.config/zed/keymap.json
 zed/tasks.json       >  ~/.config/zed/tasks.json
 zed/AGENTS.md        >  ~/.config/zed/AGENTS.md
 zsh/.zshrc           >  ~/.zshrc
 vim/.vimrc           >  ~/.vimrc
```
each package needs its own target, since they don't all land in the same
place. ghostty, git, nvim, atuin, gh-dash, nix, and zed each get their
own folder under ~/.config. starship's file sits right in ~/.config with
no subfolder. zsh and vim have no XDG spot at all, so they target $HOME
directly. `init.sh` (and `.stowrc`'s ignore patterns) handle this. See
"init" below.

zed's package deliberately does not cover everything under
~/.config/zed. `prompts/` (an LMDB database, not a hand-authored file),
`conversations/` (chat history), `settings_backup.json`, and any
`keymap.json.*.bak` are generated or backup state, not real dotfiles,
and stay untracked on the live machine. It also has no `themes/`
folder. Zed's `"Version 14 Dark"`/`"Version 14 Light"` themes
(referenced in `settings.json`) come from the
[version14/zed-theme](https://github.com/version14/zed-theme)
extension, installed through Zed itself, not a vendored file.

### theming

every themeable tool here runs the same [Version 14](https://github.com/version14)
palette (Dark/Black/Light), one repo per tool:
```
 ghostty   >  vendored copy in ghostty/themes/, from version14/ghostty-theme
 starship  >  palette table pasted into starship.toml, from version14/starship-theme
 gh-dash   >  theme.colors block pasted into config.yml, from version14/gh-dash-theme
 atuin     >  vendored copy in atuin/themes/, from version14/atuin-theme
 nvim      >  version14/nvim-theme plugin (see colorscheme.lua)
 vim       >  version14/vim-theme plugin (see .vimrc)
 zed       >  version14/zed-theme extension, installed through Zed itself
```
`zed-theme` is the palette's canonical source (`themes/version14.json`);
the rest are hand-ported from it, not generated. `nvim-theme`,
`vim-theme`, and `vscode-theme` carry the same palette, so every repo
in the suite is visually consistent.

`nix-darwin/` is not a stow package. It holds the system flake
(`flake.nix`, `flake.lock`) that `darwin-rebuild` reads directly from
its path, not something symlinked into `$HOME`. See "nix-darwin" below.

atuin also needs `eval "$(atuin init zsh)"` in .zshrc (already there) to
actually hook into the shell. the config.toml alone doesn't do that.

gh-dash is a `gh` CLI extension, not a standalone install. it needs
`gh extension install dlvhdr/gh-dash` once, separate from stow.

vim-plug (the plugin manager .vimrc bootstraps) and the plugins it
installs live at ~/.vim/autoload and ~/.vim/plugged, real downloaded
code, not dotfiles, so they stay out of git same as tmux's plugins did.

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
every step it takes is idempotent.

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

## nix-darwin

`nix-darwin/flake.nix` declares system packages, Homebrew casks, and
macOS defaults, shared across every Mac this flake is used on.
`init.sh` applies it automatically. to do it by hand:

 darwin-rebuild switch --flake ~/dotfiles/nix-darwin

run that again any time the flake changes. it's idempotent otherwise.
`darwin-rebuild` auto-selects the `darwinConfigurations` entry matching
the current machine's hostname, so this same command works unmodified
on any machine already listed in the flake.

Determinate Nix already manages the Nix install and daemon here
(`nix.enable = false` in the flake), so `nix/nix.conf` (stowed above)
carries the user-level Nix settings nix-darwin doesn't touch, including
the substituter and trusted key for devenv's binary cache.

### adding another Mac

the flake covers multiple machines. `hostnames` (top of the `let`
block) lists every Mac it applies to, and one `darwinConfigurations`
entry gets generated per hostname, all sharing the same packages, casks,
and the same `mathieusouflis` user. to bring a new Mac in, add its
hostname to that list. nothing else needs to change unless that machine
needs different packages or is Intel rather than Apple Silicon (give it
its own entry with a different `nixpkgs.hostPlatform` in that case,
instead of going through `mkConfiguration`).

## devenv

`devenv` (github.com/cachix/devenv) is installed system-wide by the
nix-darwin flake, so it's available in any project without a per-project
install. to use it in a project:
```bash
 devenv init
 echo "use devenv" >> .envrc
 direnv allow
```
that gives the project its own reproducible dev shell, defined in that
project's `devenv.nix`, activated automatically by direnv on `cd`.

## adding a package

make a folder named after the tool, put its file(s) in flat with no extra
nesting, then add a line to `stow.sh` (and the table above) with the
right target, the folder that would directly contain those files once
deployed.
