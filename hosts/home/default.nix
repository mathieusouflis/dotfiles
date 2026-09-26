{ ... }:

{
  home.username = "mathieusouflis";
  home.homeDirectory = "/Users/mathieusouflis";
  home.stateVersion = "26.05";

  home.file.".aerospace.toml" = {
    source = ../../aerospace/.aerospace.toml;
    force = true;
  };
  xdg.configFile."ghostty" = { source = ../../ghostty; recursive = true; force = true; };
  xdg.configFile."karabiner" = { source = ../../karabiner; recursive = true; force = true; };
}
