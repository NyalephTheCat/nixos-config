{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./simple.nix
    ./obs.nix
  ];
}

