{ config, pkgs, lib, ... }:

{
  # Security tools - encryption and security utilities
  environment.systemPackages = with pkgs; lib.mkDefault [
    gnupg
    pass
    age
  ];
}

