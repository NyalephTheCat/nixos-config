{ config, pkgs, lib, ... }:

{
  # System-wide applications available to all users
  environment.systemPackages = with pkgs; [
    # Web browsers
    firefox
    
    # Email client
    thunderbird
    
    # Gaming
    lutris
    
    # Streaming/Recording
    obs-studio
    
    # Torrent client
    qbittorrent
    
    # File managers
    nautilus  # GNOME file manager
    # dolphin is part of KDE/Plasma and should be installed via the desktop environment
    # If you need it standalone, use: pkgs.plasma5Packages.dolphin or pkgs.libsForQt5.dolphin
    ranger    # Terminal file manager
    
    # Media players
    vlc
    mpv
    
    # Content creation (also available via content-creation feature)
    krita      # Digital painting
    
    # System utilities (additional to base.nix)
    gnome-disk-utility  # Disk management (moved from gnome.gnome-disk-utility)
    gparted    # Partition editor
  ];
}

