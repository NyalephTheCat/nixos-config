{ config, pkgs, lib, ... }:

{
  # Aggregate all hardware modules
  imports = [
    ./graphics.nix
    ./audio.nix
    ./bluetooth.nix
    ./power.nix
    ./profiles  # Hardware-specific profiles (AMD, NVIDIA, Intel, Laptop)
  ];
}

