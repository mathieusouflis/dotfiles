{ ... }:

{
  home.username = "mathieusouflis";
  home.homeDirectory = "/Users/mathieusouflis";
  home.stateVersion = "26.05";

  home.file.".aerospace.toml".source = ../../aerospace/.aerospace.toml;
  xdg.configFile."ghostty".source = ../../ghostty;
  xdg.configFile."karabiner".source = ../../karabiner;
}
