{ config, pkgs, lib, ... }:

{
  # Aggregate all feature modules (optional features)
  imports = [
    ./gaming.nix
    ./virtualization.nix
    ./development.nix
    ./printing.nix
  ];
}

