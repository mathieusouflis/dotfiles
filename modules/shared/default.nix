{ pkgs, ... }:

{
  home.packages = with pkgs; [
    atuin
    direnv
    eza
    fzf
    gh
    gh-dash
    git
    helix
    jq
    neovim
    ripgrep
    starship
    vim
    zoxide
  ];

  programs.home-manager.enable = true;

  home.file.".zshrc" = {
    source = ../../zsh/.zshrc;
    force = true;
  };
  home.file.".vimrc" = {
    source = ../../vim/.vimrc;
    force = true;
  };

  xdg.configFile."atuin" = { source = ../../atuin; force = true; };
  xdg.configFile."gh-dash" = { source = ../../gh-dash; force = true; };
  xdg.configFile."git" = { source = ../../git; force = true; };
  xdg.configFile."helix" = { source = ../../helix; force = true; };
  xdg.configFile."nix" = { source = ../../nix; force = true; };
  xdg.configFile."nvim" = { source = ../../nvim; force = true; };
  xdg.configFile."zed" = { source = ../../zed; force = true; };
  xdg.configFile."starship.toml" = {
    source = ../../starship/starship.toml;
    force = true;
  };
}
