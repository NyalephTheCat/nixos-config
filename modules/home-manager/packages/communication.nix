{ config, pkgs, lib, ... }:

{
  # User packages - communication applications
  # Note: Discord and Vesktop are also available via gaming-tools feature
  # They are included here for users who want them without enabling gaming-tools
  home.packages = with pkgs; [
    discord
    vesktop
  ];
}

