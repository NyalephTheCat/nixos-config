{ config, pkgs, lib, ... }:

{
  # User-specific packages for nyaleph
  home.packages = with pkgs; [
    # Communication
    discord
    vesktop
    
    # Development
    code-cursor
    gcc
    gnumake
    cmake
    pkg-config
    openssl
    alsa-lib
    systemd
    nodejs_22
    python3
    python3Packages.pip
    rustup
    
    # Utilities
    jq
    curl
    wget
    ripgrep
    fd
    bat
    eza
    fzf
    
    # Media
    vlc
    qbittorrent
    
    # Gaming
    r2modman
    
    # LaTeX
    texlive.combined.scheme-full
  ];
}

