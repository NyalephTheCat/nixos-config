{ config, pkgs, lib, ... }:

{
  # Aggregate all program configuration modules
  imports = [
    ./git.nix
    ./shell.nix
    ./terminal.nix
    ./development.nix
    ./thunderbird.nix
    ./vim.nix
    ./shell-aliases.nix
    ./environment.nix
    ./bat.nix
    ./eza.nix
    ./fonts.nix
    ./themes.nix
    ./wallpapers.nix
  ];
}

