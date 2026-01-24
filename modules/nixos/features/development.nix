{ config, pkgs, lib, ... }:

let
  cfg = config.features.development or { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    # Development packages
    environment.systemPackages = with pkgs; [
      # Core compilers and build tools
      gcc
      gnumake
      cmake
      pkg-config
      
      # Version control
      git
      gh          # GitHub CLI
      tig         # Git TUI
      lazygit     # Git TUI
      delta       # Git diff viewer
      
      # Language toolchains (basic versions)
      python3
      nodejs
      rustc
      cargo
      go
      
      # Docker tools
      docker-compose
      
      # Build utilities
      automake
      autoconf
      libtool
      
      # Task runners
      just        # Justfile runner
      
      # Version managers
      mise        # Modern version manager (replaces asdf)
    ];

    # Enable direnv system-wide for development environments
    programs.direnv.enable = true;
  };
}

