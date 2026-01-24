{ config, pkgs, lib, ... }:

{
  # Graphics and OpenGL support
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = true; # Support for 32-bit applications
  };
}

