{ pkgs, ... }:

{
  home.username = "mathieusouflis";
  home.homeDirectory = "/home/mathieusouflis";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    alacritty
    dmenu
    feh
    i3
    i3status
    xorg.xinit
  ];

  xdg.configFile."alacritty".source = ../../alacritty;
  xdg.configFile."i3/config".source = ./i3/config;
  home.file.".xinitrc".source = ./xinitrc;
}
