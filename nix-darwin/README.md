# nix-darwin

The system flake: packages, Homebrew casks/brews, and macOS defaults
shared across every Mac this is used on. Not a stow package -- `init.sh`
and `darwin-rebuild` read `flake.nix`/`flake.lock` directly from this
path. The same flake also exposes the standalone school Home Manager
configuration; its files live in the repository root's `modules/` and
`hosts/` directories.

```
darwin-rebuild switch --flake ~/dotfiles/nix-darwin
```

The school configuration is activated without root:

```bash
home-manager switch --flake ~/dotfiles/nix-darwin#math@school
```

The flake pins Nixpkgs and Home Manager to the matching `26.05` stable line.
The Nix executable itself is supplied by the host: school `install.sh`
checks that it is at least Nix 2.4 and enables `nix-command` and `flakes` in
the user configuration.
Idempotent, safe to re-run any time the flake changes. `darwin-rebuild`
auto-selects the `darwinConfigurations` entry matching the current
machine's hostname.

## adding another Mac

`hostnames` (top of the `let` block) lists every Mac this flake
applies to, and one `darwinConfigurations` entry gets generated per
hostname, all sharing the same packages, casks, and user. To bring a
new Mac in, add its hostname to that list -- nothing else needs to
change unless that machine needs different packages or is Intel rather
than Apple Silicon (give it its own entry with a different
`nixpkgs.hostPlatform` in that case, instead of going through
`mkConfiguration`).

## raycast

Raycast has no dotfile. Per-extension hotkeys, aliases, quicklinks,
snippets, fallback commands, window-management shortcuts, AI presets,
and the theme all live in an encrypted SQLite database
(`~/Library/Application Support/com.raycast.macos/raycast-enc.sqlite`),
which nothing here can read or write. The only way to move them
between Macs is Raycast's own Settings > Advanced > Export, which
produces an opaque `.rayconfig` blob -- that's a backup, not config, so
it isn't kept in this repo.

What Raycast *does* expose is a small set of plain macOS defaults,
declared under
`system.defaults.CustomUserPreferences."com.raycast.macos"`: the
global hotkey, window mode, appearance-follows-system, hyperkey icon,
favicon provider, emoji skin tone, preferred browser, and a few
first-run prompts. Deliberately left out are window/menu-bar geometry,
AppKit-generated status-item indices (which shift when Raycast updates
or extensions change), and anything identity- or telemetry-shaped.

Values there are booleans, not `0`/`1`. `defaults read` prints both the
same way, so check with `defaults read-type com.raycast.macos <key>`
before adding a key, and write `true`/`false` in the flake.

Raycast caches its preferences in memory and rewrites the whole plist
when it quits, so anything written underneath a running Raycast gets
silently reverted on its next exit. The flake works around this by
quitting Raycast in `extraActivation`, which runs before the `defaults
write`s -- **every `darwin-rebuild switch` quits Raycast**, not just
the ones that touch these settings. Reopen it yourself afterwards.

There is deliberately no matching relaunch in `postActivation`, and
adding one is a trap. Activation runs under sudo, so the obvious
`launchctl asuser ... sudo --user=... open -a Raycast` starts Raycast
with no GUI login session. It then can't reach the login keychain,
can't read the `Raycast`/`database_key` item that decrypts
`raycast-enc.sqlite`, and puts up "A keychain cannot be found to store
'database_key'" offering Cancel or Reset To Defaults. **Reset To
Defaults wipes the database** -- every hotkey, quicklink and snippet in
it. If you ever see that dialog, cancel it, quit Raycast, and relaunch
it normally from Finder or Spotlight; a normal GUI launch has the
keychain session and reopens the real database.

Three things the flake can't do for you, all one-time per Mac:

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
  itself. It's currently `net.imput.helium` -- see "default browser"
  below for the app itself.

## default browser

- **if `Helium.app` already exists in `/Applications` (e.g. a manual
  download), remove it first.** Unlike Raycast, `brew` doesn't refuse
  outright -- it tries to *adopt* the existing bundle, which means
  re-`chmod`-ing every file in it to fix permissions. If the app is
  still quarantine-flagged (Gatekeeper hasn't run on it yet), that
  chmod fails on `Contents/embedded.provisionprofile` with `Operation
  not permitted` -- even as root -- and the whole cask install aborts
  and purges. Fix: `rm -rf /Applications/Helium.app`, then re-run.

Helium is installed via the `helium-browser` Homebrew cask and set as
the system default handler for `http`/`https` links by `duti`, run as
the primary user from `postActivation` (after homebrew has installed
the cask). Both `activationScripts.*.text` commands end in `|| true`
because macOS increasingly gates default-handler changes behind a
one-time interactive confirmation (a `-54` error from `duti` even on a
change that otherwise takes effect), so a failure here shouldn't fail
the whole `darwin-rebuild switch`. If Helium isn't actually the
default after a rebuild, set it by hand: System Settings > Desktop &
Dock > Default web browser (or open Helium.app once and accept its
own "make default" prompt).

Helium's default search engine (DuckDuckGo) and its preinstalled
extension set are not declared by the flake -- see the comment above
`postActivation` in `flake.nix` for why (macOS removed scriptable
profile installs) and the one-time manual steps to set them up.

## devenv

[devenv](https://github.com/cachix/devenv) is installed system-wide by
this flake, so it's available in any project without a per-project
install:
```bash
devenv init
echo "use devenv" >> .envrc
direnv allow
```
That gives the project its own reproducible dev shell, defined in that
project's `devenv.nix`, activated automatically by direnv on `cd`.
