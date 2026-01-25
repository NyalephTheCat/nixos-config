{ config, pkgs, lib, ... }:

with lib;

{
  options.emulators = {
    enable = mkEnableOption "all emulators";
  };

  imports = [
    ./retroarch.nix
    ./simple.nix
  ];
}

