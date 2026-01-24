{ config, pkgs, lib, ... }:

{
  # Bluetooth hardware support
  hardware.bluetooth.enable = lib.mkDefault true;
  hardware.bluetooth.powerOnBoot = lib.mkDefault true;
  
  # Bluetooth service
  services.blueman.enable = lib.mkDefault true;
}

