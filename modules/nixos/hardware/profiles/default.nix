{ config, pkgs, lib, ... }:

{
  # Aggregate all hardware profiles
  imports = [
    ./amd.nix
    ./nvidia.nix
    ./intel.nix
    ./laptop.nix
  ];
}

