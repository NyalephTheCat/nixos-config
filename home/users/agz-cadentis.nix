{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ../../modules/home
  ];

  home = {
    username = "agz-cadentis";
    homeDirectory = "/home/agz-cadentis";
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
    LANG = "pt_BR.UTF-8";
    LC_ALL = "pt_BR.UTF-8";
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
    userName = "MadLadyPercent";
    userEmail = "agata.calliw@outlook.com";
  };
}

