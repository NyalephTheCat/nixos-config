{ config, pkgs, ... }:

{
  # Essential system packages
  environment.systemPackages = with pkgs; [
    # File management
    # Note: dolphin and ark are KDE applications - they're included with Plasma6 by default
    # If you need them as separate packages, uncomment and adjust:
    # (if pkgs ? libsForQt6 && pkgs.libsForQt6 ? dolphin then pkgs.libsForQt6.dolphin else if pkgs ? libsForQt5 && pkgs.libsForQt5 ? dolphin then pkgs.libsForQt5.dolphin else null)
    # (if pkgs ? libsForQt6 && pkgs.libsForQt6 ? ark then pkgs.libsForQt6.ark else if pkgs ? libsForQt5 && pkgs.libsForQt5 ? ark then pkgs.libsForQt5.ark else null)
    file
    
    # Text editors
    nano
    vim
    
    # System utilities
    htop
    neofetch
    git
    wget
    curl
    
    # Archive tools
    unzip
    zip
    
    # Network tools
    networkmanagerapplet
  ];

  # Enable network manager
  networking.networkmanager.enable = true;

  # Enable automatic system upgrades
  system.autoUpgrade = {
    enable = false; # Set to true if desired
    allowReboot = false;
  };
}

