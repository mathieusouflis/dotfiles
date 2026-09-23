# School host

EPITA's [AFS documentation](https://docs.forge.epita.fr/epita/environment/from-school/afs/)
explains why this host is bootstrapped on every session: only the AFS folder
survives a reboot, while the rest of the home directory is reconstructed.

The school machines reset everything outside AFS at reboot. The repository
therefore lives at `$AFS_DIR/.confs`, while Home Manager deploys links into
`$HOME` on every session through `install.sh`.

To use a wallpaper, place an image named `wallpaper` in this directory. It
will be linked to `$HOME/.config/wallpaper` and applied by i3 with `feh`.

The file is intentionally not included in Git; keep personal images in AFS
or add a project-specific image yourself.
