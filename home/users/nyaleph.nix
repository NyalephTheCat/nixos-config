{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ../../modules/home
  ];

  home = {
    username = "nyaleph";
    homeDirectory = "/home/nyaleph";
  };

  # User-specific application configuration
  applications = {
  };

  # Emulator configuration
  emulators = {
    enable = true;
    citra.enable = false;
    yuzu.enable = false;
  };

  # Terminal configuration
  terminal = {
    kitty.enable = true;
    zsh.enable = true;
  };

  # Locale environment variables
  home.sessionVariables = {
    LANG = "fr_FR.UTF-8";
    LC_ALL = "fr_FR.UTF-8";
  };

  # Plasma dark mode configuration
  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=Breeze Dark
    Name=Breeze Dark
  '';

  # Git configuration
  tools.git = {
    enable = true;
    userName = "Chloe Magnier";
    userEmail = "chloe@magnier.dev";
  };
}

