{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

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

  xdg.configFile."atuin" = { source = ../../atuin; recursive = true; force = true; };
  xdg.configFile."gh-dash" = { source = ../../gh-dash; recursive = true; force = true; };
  xdg.configFile."git" = { source = ../../git; recursive = true; force = true; };
  xdg.configFile."helix" = { source = ../../helix; recursive = true; force = true; };
  xdg.configFile."nix" = { source = ../../nix; recursive = true; force = true; };
  xdg.configFile."nvim" = { source = ../../nvim; recursive = true; force = true; };
  xdg.configFile."zed" = { source = ../../zed; recursive = true; force = true; };
  xdg.configFile."starship.toml" = {
    source = ../../starship/starship.toml;
    force = true;
  };
}
