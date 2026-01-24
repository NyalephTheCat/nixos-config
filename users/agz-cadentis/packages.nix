{ config, pkgs, lib, ... }:

{
  # User-specific packages for agz-cadentis
  # Customize this based on her preferences
  home.packages = with pkgs; [
    # Communication
    # discord # Enable if desired
    
    # Productivity
    # libreoffice-fresh
    
    # Media
    vlc
    
    # Utilities
    jq
    curl
    wget
    ripgrep
    fd
    bat
    eza
    fzf
    
    # Add more packages as needed
  ];
}

