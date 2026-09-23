{ pkgs, ... }:

{
  home.username = "mathieu.souflis";
  home.homeDirectory = "/home/mathieu.souflis";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    alacritty
    dmenu
    feh
    i3
    i3status
    picom
    xorg.xset
    xorg.xinit
  ];

  xdg.configFile."alacritty" = { source = ../../alacritty; recursive = true; force = true; };
  xdg.configFile."i3/config" = { source = ./i3/config; force = true; };
}
