# School host

EPITA's [AFS documentation](https://docs.forge.epita.fr/epita/environment/from-school/afs/)
explains why this host is bootstrapped on every session: only the AFS folder
survives a reboot, while the rest of the home directory is reconstructed.

The school machines reset everything outside AFS at reboot. The repository
therefore lives at `$AFS_DIR/.confs`, while Home Manager deploys links into
`$HOME` on every session through `install.sh`.

To use a wallpaper, place an image named `wallpaper` in this directory. It
will be linked to `$HOME/.config/wallpaper` and applied by i3 with `feh`.

Alacritty transparency requires an X11 compositor. The school profile
installs and starts `picom` from the i3 configuration. Alacritty's `blur`
option is kept for platforms that support it, but opacity and blur are
separate features.

The file is intentionally not included in Git; keep personal images in AFS
or add a project-specific image yourself.

For SSH, put private keys and `known_hosts` in `$AFS_DIR/.ssh`, not in this
repository. `install.sh` links those files into `$HOME/.ssh` each session.
The AFS directory is persistent but is not Git-managed; protect it with the
usual `chmod 700` directory and `chmod 600` private-key permissions.

## Extra application configurations

`install.sh` also mirrors the ignored `$AFS_DIR/.confs/home/` tree into the
session's `$HOME`, preserving paths. For example:

```text
$AFS_DIR/.confs/home/.mozilla/          -> $HOME/.mozilla/
$AFS_DIR/.confs/home/.config/discord/   -> $HOME/.config/discord/
```

This is useful for Firefox, Discord, and similar applications whose config
is not worth modelling as a Home Manager option. Put only non-secret config
there: it is persistent AFS data, but it is not committed to Git. Existing
session files are moved to a `.pre-confs` backup before a symlink is created,
so login-time deployment does not silently destroy data.

The declared Nix configuration still owns shared tools such as Alacritty and
i3. The automatic tree is deliberately for additional application data, not
a second way to manage those same paths.

## VM test

From a Linux machine with Nix and flakes enabled, build and run the school
desktop VM:

```bash
nix build ./nix-darwin#nixosConfigurations.school-vm.config.system.build.vm
./result/bin/run-school-vm
```

The VM checks the NixOS/i3/Home Manager configuration without requiring an
EPITA AFS mount. It cannot reproduce EPITA's login wrapper or AFS itself; to
test that part, create a temporary fake tree at `$HOME/afs/.confs`, copy the
repository there, add a sample `home/.config/example/config`, and run
`AFS_DIR="$HOME/afs" ./install.sh` inside the VM.
