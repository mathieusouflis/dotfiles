# forking this

this is Mathieu's personal config. it's meant to be forked, not run
as-is -- a handful of fields are hardcoded to him and will fail or
misbehave on your machine until you change them.

```bash
gh repo fork mathieusouflis/dotfiles --clone
cd dotfiles
```
(or fork on github.com, then `git clone` your fork the normal way)

## must edit

these break for anyone who isn't Mathieu, on a clean clone:

| file | field | why |
|---|---|---|
| `git/config` | `user.email`, `user.name` | your git identity, not his |
| `git/config` | `user.signingkey`, with `commit.gpgsign` / `tag.gpgSign` on | commits and tags fail to sign until you point `signingkey` at a key you actually hold. either [generate and register your own GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key), or set both `gpgsign` and `gpgSign` to `false` in `git/config` to turn signing off |
| `nix-darwin/flake.nix` | `hostnames` list | the flake only applies to hostnames listed here. add yours (`scutil --get ComputerName`) |
| `nix-darwin/flake.nix` | `system.primaryUser` | must match your local macOS username (`whoami`) |

## worth reviewing

these won't fail, they're just Mathieu's taste baked into the flake --
prune or swap to your own:

- `homebrew.casks` / `homebrew.brews` in `nix-darwin/flake.nix` --
  his app picks (1Password, Discord, Docker Desktop, DuckDuckGo,
  Figma, Obsidian, Raycast, Spotify, Zed, thefuck, duti)
- `environment.systemPackages` in the same file -- the CLI tool list,
  prune to what you actually use
- the `duti` postActivation block -- sets DuckDuckGo as the system
  default browser; remove or change the bundle id if you want
  something else
- `system.defaults.CustomUserPreferences."com.raycast.macos"` --
  his Raycast hotkey and window-mode prefs
- zsh aliases/functions in `zsh/.zshrc`, and each themeable package's
  copy of the Version 14 palette (see that package's own README for
  where it lives)

once you've gone through the must-edit table, follow the [init
section](README.md#init) to install.
