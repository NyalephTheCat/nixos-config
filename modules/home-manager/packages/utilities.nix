{ config, pkgs, lib, ... }:

{
  # User packages - utilities
  # Note: Many utilities are available system-wide, but some user-specific ones are here
  home.packages = with pkgs; [
    # JSON processor
    jq
    
    # File utilities
    ripgrep  # Fast grep alternative
    fd       # Fast find alternative
    bat      # Cat with syntax highlighting
    eza      # Modern ls alternative
    fzf      # Fuzzy finder
    
    # System info
    neofetch
    
    # Archive tools (if not system-wide)
    unzip
    zip
    
    # Network tools
    curl
    wget
    
    # Text processing
    tree
    less
  ];
}

