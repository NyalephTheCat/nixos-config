{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./communication
    ./development
    ./gaming
    ./media
    ./productivity
    ./utilities
    ./security
    ./system
    ./network
  ];
}

