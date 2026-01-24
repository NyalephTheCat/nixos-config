{ config, pkgs, lib, ... }:

{
  # User packages - media applications
  home.packages = with pkgs; [
    # Add media apps here
    # vlc # Add per-user if needed
    # qbittorrent # Add per-user if needed
  ];
}

