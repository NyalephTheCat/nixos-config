{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./simple.nix
    ./steam.nix
  ];
}

