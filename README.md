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

raycast is not a stow package either, and can't be. Raycast has no
config file: everything it knows lives in an encrypted SQLite database
(`~/Library/Application Support/com.raycast.macos/raycast-enc.sqlite`),
and the handful of settings it does expose are plain macOS defaults, so
they're declared in the flake instead. `~/.config/raycast/` exists but
is Raycast's own runtime state, downloaded extension bundles plus a
`config.json` holding an auth token, so it stays untracked. See
"raycast" below.

atuin also needs `eval "$(atuin init zsh)"` in .zshrc (already there) to
actually hook into the shell. the config.toml alone doesn't do that.

gh-dash is a `gh` CLI extension, not a standalone install. it needs
`gh extension install dlvhdr/gh-dash` once, separate from stow.

vim-plug (the plugin manager .vimrc bootstraps) and the plugins it
installs live at ~/.vim/autoload and ~/.vim/plugged, real downloaded
code, not dotfiles, so they stay out of git same as tmux's plugins did.

zsh runs no framework. `zsh-autosuggestions` and `zsh-syntax-highlighting`
are installed by the nix-darwin flake and sourced straight out of
`/run/current-system/sw/share/` in .zshrc, so `darwin-rebuild` is what
puts them there, not a clone under `~`.

.zshrc is grouped into `### SECTION ###` blocks and three of them are
order-sensitive, so keep them where they are: `bindkey -e` under OPTIONS
(without it zsh reads `$EDITOR`, sees nvim, and starts in vi mode),
autosuggestions above the `^w`/`^e`/`^u` bindkeys that use its widgets,
and syntax-highlighting on the very last line, since it only highlights
what's already defined above it. COLORS sits above COMPLETION because
the completion menu's `list-colors` is derived from `$LS_COLORS`.

the COLORS block and the `l` alias are hand-written replacements for
things oh-my-zsh's `lib/` used to define implicitly (`LS_COLORS`,
`LSCOLORS`, `autoload -U colors`, and `alias l='ls -lah'`). eza reads
`$LS_COLORS`, so dropping it silently changed every `ls`.

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

## raycast

Raycast has no dotfile. Per-extension hotkeys, aliases, quicklinks,
snippets, fallback commands, window-management shortcuts, AI presets,
and the theme all live in an encrypted SQLite database
(`~/Library/Application Support/com.raycast.macos/raycast-enc.sqlite`),
which nothing here can read or write. The only way to move them between
Macs is Raycast's own Settings > Advanced > Export, which produces an
opaque `.rayconfig` blob; that's a backup, not config, so it isn't kept
in this repo.

What Raycast *does* expose is a small set of plain macOS defaults, and
those are declared in the flake under
`system.defaults.CustomUserPreferences."com.raycast.macos"`: the global
hotkey, window mode, appearance-follows-system, hyperkey icon, favicon
provider, emoji skin tone, preferred browser, and a few first-run
prompts. Deliberately left out are window/menu-bar geometry
(`mainWindowPositionCache`, `NSStatusItem Preferred Position *`),
AppKit-generated status-item indices (`NSStatusItem Visible Item-N`,
which shift when Raycast updates or extensions change), and anything
identity- or telemetry-shaped (`raycastAnonymousId`, `store_*`,
`raycastAI_*`, migration flags).

Values there are booleans, not `0`/`1`. `defaults read` prints both the
same way, so check with `defaults read-type com.raycast.macos <key>`
before adding a key, and write `true`/`false` in the flake.

Raycast caches its preferences in memory and rewrites the whole plist
when it quits, so anything written underneath a running Raycast gets
silently reverted on its next exit. The flake works around this by
quitting Raycast in `extraActivation`, which runs before the
`defaults write`s. This means **every `darwin-rebuild switch` quits
Raycast**, not just the ones that touch these settings; reopen it
yourself afterwards.

There is deliberately no matching relaunch in `postActivation`, and
adding one is a trap. Activation runs under sudo, so the obvious
`launchctl asuser ... sudo --user=... open -a Raycast` starts Raycast
with no GUI login session. It then can't reach the login keychain,
can't read the `Raycast`/`database_key` item that decrypts
`raycast-enc.sqlite`, and puts up "A keychain cannot be found to store
'database_key'" offering Cancel or Reset To Defaults. **Reset To
Defaults wipes the database** and every hotkey, quicklink and snippet
in it. If you ever see that dialog, cancel it, quit Raycast, and
relaunch it normally from Finder or Spotlight; a normal GUI launch has
the keychain session and reopens the real database. Note nix-darwin
itself uses that asuser/sudo pattern for `defaults write`, which never
touches the keychain, so it is not evidence the pattern is safe for
launching apps.

three things the flake can't do for you, all one-time per Mac:

 - **the first install needs the app gone.** `brew` refuses to install
   a cask over an app it didn't install, and nix-darwin's cask options
   have no `adopt`. `rm -rf /Applications/Raycast.app` before the first
   `darwin-rebuild switch`. Settings and extensions survive (they're in
   `~/Library` and `~/.config/raycast`), but macOS will re-prompt for
   Accessibility, Screen Recording, and Automation, and the login item
   needs re-adding.
 - **Spotlight owns Cmd+Space on a fresh Mac.** The flake sets
   `raycastGlobalHotkey` but can't unbind Spotlight: that lives in
   `com.apple.symbolichotkeys`, and `CustomUserPreferences` writes one
   whole value per top-level key, so declaring it would replace the
   entire `AppleSymbolicHotKeys` dict and wipe every other system
   shortcut. Raycast's first-run flow offers to take Cmd+Space over;
   accept it. By hand: System Settings > Keyboard > Keyboard Shortcuts
   > Spotlight, uncheck "Show Spotlight search".
 - **`preferredGoogleBrowser` only picks which browser opens a Raycast
   search**, not which search engine Raycast uses; the search engine is
   a quicklink in the SQLite database and has to be set in Raycast
   itself. It's currently `com.duckduckgo.macos.browser` — see
   "default browser" below for the app itself.

## default browser

DuckDuckGo is installed via the `duckduckgo` Homebrew cask and set as
the system default handler for `http`/`https` links by `duti`, run as
the primary user from `postActivation` (after homebrew has installed
the cask). Both `activationScripts.*.text` commands end in `|| true`
because macOS increasingly gates default-handler changes behind a
one-time interactive confirmation (a `-54` error from `duti` even on a
change that otherwise takes effect), so a failure here shouldn't fail
the whole `darwin-rebuild switch`. If DuckDuckGo isn't actually the
default after a rebuild, set it by hand: System Settings > Desktop &
Dock > Default web browser (or open DuckDuckGo.app once and accept its
own "make default" prompt).

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
