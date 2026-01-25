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
    discord.enable = true;
    firefox.enable = true;
    thunderbird.enable = true;
    steam.enable = true;
    cursor.enable = true;
    vscode.enable = true;
    obs.enable = true;
    krita.enable = true;
    qbittorrent.enable = true;
    audacity.enable = true;
    libreoffice.enable = true;
    vlc.enable = true;
    r2modman.enable = true;
    lutris.enable = true;
    zapzap.enable = true;
    obsidian.enable = true;
  };

  # Emulator configuration
  emulators = {
    enable = true;
    retroarch.enable = true;
    duckstation.enable = true;
    pcsx2.enable = true;
    rpcs3.enable = true;
    dolphin.enable = true;
    mupen64plus.enable = true;
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
    userName = "chloe magnier";
    userEmail = "chloe@magnier.dev";
  };
}

