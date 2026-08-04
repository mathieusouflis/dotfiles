{
  description = "Mathieu's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:

  let
    # every Mac this flake applies to. Onboarding a new one is just
    # adding its hostname here, unless it needs different packages or
    # is Intel rather than Apple Silicon.
    hostnames = [
      "MacBook-Pro-de-Mathieu"
    ];

    mkConfiguration = hostName: { pkgs, ... }: {
        nix.settings.experimental-features = "nix-command flakes";
        # Determinate Nix manages the Nix daemon on this machine, so
        # nix-darwin should not also try to.
        nix.enable = false;

        programs.zsh.enable = true;
        nixpkgs.hostPlatform = "aarch64-darwin";

        networking.hostName = hostName;
        system.primaryUser = "mathieusouflis";

        security.pam.services.sudo_local.touchIdAuth = true;

        environment.systemPackages = [
          pkgs.vim
          pkgs.neovim
          pkgs.direnv
          pkgs.git
          pkgs.gh
          pkgs.gh-dash
          pkgs.eza
          pkgs.ripgrep
          pkgs.fzf
          pkgs.starship
          pkgs.atuin
          pkgs.zoxide
          pkgs.stow
          # sourced by .zshrc from share/, replacing what oh-my-zsh loaded
          pkgs.zsh-autosuggestions
          pkgs.zsh-syntax-highlighting
          pkgs.devenv
          pkgs.jq
          pkgs.pnpm
          pkgs.nodejs
          pkgs.yarn
          pkgs.bun
        ];

        # systemPackages only links a fixed set of subpaths into
        # /run/current-system/sw, and share/zsh-* is not one of them, so
        # .zshrc's two `source` lines would hit a missing file without this.
        environment.pathsToLink = [
          "/share/zsh-autosuggestions"
          "/share/zsh-syntax-highlighting"
        ];

        homebrew.enable = true;
        homebrew.casks = [
          "ghostty"
          "1password"
          "discord"
          "docker-desktop"
          "figma"
          "obsidian"
          "spotify"
          "zed"
        ];
        homebrew.brews = [
          "thefuck"
        ];

        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;
    };
  in
  {
    darwinConfigurations = nixpkgs.lib.genAttrs hostnames (hostName:
      nix-darwin.lib.darwinSystem {
        modules = [ (mkConfiguration hostName) ];
      }
    );

    # used by `nix eval .#darwinPackages.<name>.outPath` to check a
    # package builds before adding it to systemPackages.
    darwinPackages = (builtins.head (builtins.attrValues self.darwinConfigurations)).pkgs;
  };
}
