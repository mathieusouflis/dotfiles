{ ... }:

{
  home.username = "mathieusouflis";
  home.homeDirectory = "/Users/mathieusouflis";
  home.stateVersion = "24.11";

  home.file.".aerospace.toml".source = ../../aerospace/.aerospace.toml;
  xdg.configFile."ghostty".source = ../../ghostty;
  xdg.configFile."karabiner".source = ../../karabiner;
}
