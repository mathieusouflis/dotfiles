{ lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  system.stateVersion = "26.05";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.windowManager.i3.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    feh
    git
    home-manager
    picom
    xorg.xset
  ];

  users.users.mathieu = {
    isNormalUser = true;
    password = "school";
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  home-manager.users.mathieu = {
    imports = [
      ../../modules/shared
      ./default.nix
    ];
    home.username = lib.mkForce "mathieu";
    home.homeDirectory = lib.mkForce "/home/mathieu";
  };
}
