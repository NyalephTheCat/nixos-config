{ config, pkgs, lib, ... }:

{
  # Base essential utilities - always available system-wide
  environment.systemPackages = with pkgs; lib.mkDefault [
    # Basic utilities
    vim
    git
    wget
    curl
    jq
    yq
    
    # System utilities
    htop
    btop
    tree
    ripgrep
    fd
    bat
    eza
    unzip
    zip
    p7zip
    neofetch
    man-pages
    man-pages-posix
    tmux
    screen
    ncdu
    duf
    procs
    dust
    zoxide
    fzf          # Fuzzy finder
    tealdeer     # Fast tldr client (use with 'tldr' command)
    nix-index    # Fast package search (use with 'nix-locate')
    
    # Archive tools
    rar
    unrar
  ];
}

