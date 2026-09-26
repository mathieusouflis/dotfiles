{
  description = "Mathieu's cross-platform home and Darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:

    let
      # every Mac this flake applies to. Onboarding a new one is just
      # adding its hostname here, unless it needs different packages or
      # is Intel rather than Apple Silicon.
      hostnames = [
        "MacBook-Pro-de-Mathieu"
      ];

      mkConfiguration = hostName: { pkgs, config, ... }: {
        nix.settings.experimental-features = "nix-command flakes";
        # Determinate Nix manages the Nix daemon on this machine, so
        # nix-darwin should not also try to.
        nix.enable = false;

        programs.zsh.enable = true;
        nixpkgs.hostPlatform = "aarch64-darwin";

        networking.hostName = hostName;
        system.primaryUser = "mathieusouflis";

        security.pam.services.sudo_local.touchIdAuth = true;

        # macOS uses lower values for faster key repeat. These are the
        # fastest stable settings exposed by the global keyboard preferences.
        system.defaults.NSGlobalDomain = {
          # Disable the accent popup so holding a letter repeats it.
          ApplePressAndHoldEnabled = false;
          KeyRepeat = 1;
          InitialKeyRepeat = 10;
        };

        environment.systemPackages = [
          pkgs.vim
          pkgs.neovim
          pkgs.nixfmt
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
          # sourced by .zshrc from share/ (see pathsToLink below)
          pkgs.zsh-autosuggestions
          pkgs.zsh-syntax-highlighting
          pkgs.devenv
          pkgs.jq
          pkgs.pnpm
          pkgs.nodejs
          pkgs.yarn
          pkgs.bun
          pkgs.helix
          pkgs.alacritty
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
          # Chromium-based; see the postActivation/Raycast notes below for
          # how it's wired up as the default browser.
          "helium-browser"
          "figma"
          "obsidian"
          "raycast"
          "spotify"
          "zed"
          "karabiner-elements"
          {
            name = "nikitabobko/tap/aerospace";
            trusted = true;
          }
        ];
        homebrew.brews = [
          "thefuck"
          # Mac cleanup/uninstall/monitoring CLI (`mo`); not in nixpkgs.
          "mole"
          # sets the macOS default handler for http(s) links; see
          # postActivation below.
          "duti"
        ];

        # Raycast keeps almost everything it knows (per-extension hotkeys,
        # aliases, quicklinks, snippets, fallbacks, window-management
        # shortcuts, AI presets, theme) in an encrypted SQLite database at
        # ~/Library/Application Support/com.raycast.macos/raycast-enc.sqlite.
        # None of that is reachable from here. What follows is the whole of
        # what Raycast exposes as plain preferences, which is why there is no
        # `raycast/` stow package: there is no file to stow.
        system.defaults.CustomUserPreferences."com.raycast.macos" = {
          raycastGlobalHotkey = "Command-49"; # <Modifiers>-<keycode>, 49 = Space
          raycastPreferredWindowMode = "compact";
          raycastShouldFollowSystemAppearance = true;
          useHyperKeyIcon = false;
          faviconProvider = "legacy";
          emojiPicker_skinTone = "standard";
          preferredGoogleBrowser = "net.imput.helium";

          showGettingStartedLink = false;
          onboarding_showTasksProgress = false;
          teamsWalkthrough_showsWalkthrough = false;
          ios_showAnnouncement = false;
          raycastFocus_raycastFocusHasStatusItem = false;
        };

        # Raycast caches its preferences in memory and rewrites the whole
        # plist on quit, so anything written underneath a running Raycast is
        # silently reverted the next time it exits. Activation order is
        # preActivation -> extraActivation -> userDefaults -> postActivation,
        # so quitting here means the writes above always win.
        #
        # Deliberately no matching relaunch in postActivation. Activation runs
        # under sudo, and `launchctl asuser ... sudo --user=... open -a Raycast`
        # yields a process with no GUI login session, so Raycast cannot reach
        # the login keychain, fails to read the `database_key` item that
        # decrypts raycast-enc.sqlite, and offers to reset itself to defaults.
        # nix-darwin uses that same asuser/sudo pattern for `defaults write`,
        # which never touches the keychain; launching a GUI app is not the
        # same thing. Relaunch Raycast by hand instead.
        system.activationScripts.extraActivation.text = ''
          killall -qu ${config.system.primaryUser} Raycast || true
        '';

        # duti (installed via homebrew.brews above) sets the macOS default
        # handler for a URL scheme, which is what makes Helium open when
        # something clicks an http(s) link system-wide. This has to run
        # after homebrew installs the helium-browser cask, so it's
        # postActivation (see the activation-order note above), and as the
        # primary user rather than root since the handler lives in that
        # user's LaunchServices database. Unlike Raycast, this doesn't touch
        # the keychain or a GUI session, so the sudo -u pattern nix-darwin
        # already uses for `defaults write` is safe here.
        system.activationScripts.postActivation.text = ''
          sudo -u ${config.system.primaryUser} /opt/homebrew/bin/duti -s net.imput.helium http || true
          sudo -u ${config.system.primaryUser} /opt/homebrew/bin/duti -s net.imput.helium https || true
        '';

        # Helium's default search engine and its preinstalled extension set
        # are NOT set here, on purpose. Both are only reachable, on macOS, as
        # a Chromium enterprise policy (DefaultSearchProvider*,
        # ExtensionInstallForcelist) delivered via a configuration profile —
        # a plain `defaults write` like the Raycast block above is silently
        # ignored by Chromium's policy loader, which only honors values from
        # the "managed preferences" domain. And since macOS 11, `profiles
        # install` no longer exists (`profiles tool no longer supports
        # installs. Use System Settings Profiles to add configuration
        # profiles.`), so there is no scriptable way to install a profile
        # from an activation script either. That leaves a one-time manual
        # setup after installing Helium:
        #   1. Settings -> Search engine -> DuckDuckGo
        #   2. Install these extensions from the Chrome Web Store:
        #      - uBlock Origin       cjpalhdlnbpafiamejdnhcphjbkeiagm
        #      - uBlock Origin Lite  ddkjiahejlhfcafbddmgiahcphecmpfh
        #      - Vimium               dbepggeogbaibhgnhhndojpepiihcmeb
        #      - Wappalyzer           gppongmhjkpfnbhagpmjfkannfbllamg
        #      - JSON Formatter       bcjindcccaagfpapjjmafapmmgkkhgoa
        #      - Octotree             bkhaagjahfmjljalopjnoealnfndnagc
        #      - 1Password            aeblfdkhhhdcdjpifhhbdiojplfjncoa
        #      - Unhook               khncfooichmfjbepaaaebmommgaepoid
        #      https://chromewebstore.google.com/detail/<id> for each.

        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;
      };
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs hostnames (
        hostName:
        nix-darwin.lib.darwinSystem {
          modules = [
            (mkConfiguration hostName)
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.mathieusouflis = {
                home.homeDirectory = nixpkgs.lib.mkForce "/Users/mathieusouflis";
                imports = [
                  ../modules/shared
                  ../hosts/home
                ];
              };
            }
          ];
        }
      );

      homeConfigurations = {
        # This is the real EPITA target.
        "math@school" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ../modules/shared
            ../hosts/school
          ];
        };

        # Native Apple-Silicon Linux VM target. It has the same modules and
        # settings, but uses the VM's aarch64-linux package set.
        "math@school-aarch64" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          modules = [
            ../modules/shared
            ../hosts/school
          ];
        };
      };

      nixosConfigurations = {
        # Exact architecture used by the school machines.
        school-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { modulesPath = "${nixpkgs}/nixos/modules"; };
          modules = [
            home-manager.nixosModules.home-manager
            ../hosts/school/vm.nix
          ];
        };

        # Fast VM target for Apple-Silicon Macs running an ARM64 NixOS VM.
        school-vm-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { modulesPath = "${nixpkgs}/nixos/modules"; };
          modules = [
            home-manager.nixosModules.home-manager
            ../hosts/school/vm.nix
          ];
        };
      };

      # used by `nix eval .#darwinPackages.<name>.outPath` to check a
      # package builds before adding it to systemPackages.
      darwinPackages = (builtins.head (builtins.attrValues self.darwinConfigurations)).pkgs;
    };
}
