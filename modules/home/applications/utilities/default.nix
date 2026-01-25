{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./simple.nix
    ./firefox.nix
  ];
}

