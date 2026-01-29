{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    # Application modules (organized by category)
    ./applications
    
    # Emulator modules
    ./emulators/default.nix
    
    # Terminal modules
    ./terminal/kitty.nix
    ./terminal/zsh.nix
    ./terminal/alacritty.nix
    ./terminal/tmux.nix
    ./terminal/fish.nix
    
    # Program modules
    ./programs/git.nix
    # Note: Most program modules removed - Home Manager already provides
    # programs.* for direnv, nix-direnv, neovim, bat, exa, fd, ripgrep, fzf,
    # htop, emacs, micro, ssh, gh, docker, kubectl.
    # Configure them directly using Home Manager's built-in options.
    
    # Font management
    ./fonts.nix
    
    # XDG configuration
    ./xdg.nix
    
    # User services
    ./services.nix
  ];

  # Global home manager options
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}

