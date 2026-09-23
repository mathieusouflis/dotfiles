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
