# nix

User-level Nix settings (the devenv/cachix substituters and trusted
keys) that nix-darwin doesn't own, since Determinate Nix manages the
daemon on this machine (`nix.enable = false` in the flake).
