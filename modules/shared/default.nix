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

  home.file.".zshrc".source = ../../zsh/.zshrc;
  home.file.".vimrc".source = ../../vim/.vimrc;

  xdg.configFile."atuin".source = ../../atuin;
  xdg.configFile."gh-dash".source = ../../gh-dash;
  xdg.configFile."git".source = ../../git;
  xdg.configFile."helix".source = ../../helix;
  xdg.configFile."nix".source = ../../nix;
  xdg.configFile."nvim".source = ../../nvim;
  xdg.configFile."zed".source = ../../zed;
  xdg.configFile."starship.toml".source = ../../starship/starship.toml;
}
