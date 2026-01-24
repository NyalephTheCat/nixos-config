{ config, pkgs, lib, ... }:

{
  # Aggregate all package modules
  imports = [
    ./base.nix
    ./network.nix
    ./security.nix
    ./fonts.nix
    ./monitoring.nix
    ./programs.nix
    ./applications.nix
  ];
}

