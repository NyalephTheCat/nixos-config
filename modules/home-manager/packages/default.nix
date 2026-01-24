{ config, pkgs, lib, ... }:

{
  # Aggregate all user package modules
  imports = [
    ./communication.nix
    ./development.nix
    ./editors.nix
    ./media.nix
    ./utilities.nix
  ];
}

