{ config, pkgs, lib, ... }:

{
  # Aggregate all security modules
  imports = [
    ./firewall.nix
    ./ssh.nix
    ./updates.nix
  ];
}

