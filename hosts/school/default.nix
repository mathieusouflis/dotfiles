{ pkgs, ... }:

{
  home.username = "mathieusouflis";
  home.homeDirectory = "/home/mathieusouflis";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    alacritty
    dmenu
    i3
    i3status
    xorg.xinit
  ];

  xdg.configFile."alacritty".source = ../../alacritty;
  xdg.configFile."i3/config".source = ./i3/config;
  home.file.".xinitrc".source = ./xinitrc;
}
