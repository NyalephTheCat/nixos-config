{ config, pkgs, lib, ... }:

{
  # Bootloader configuration
  # systemd-boot is a simple UEFI boot manager
  # It's lightweight and integrates well with systemd
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  
  # Allow systemd-boot to modify EFI variables
  # Required for proper boot management on UEFI systems
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  
  # Alternative: GRUB bootloader (can be overridden in host config)
  # boot.loader.grub = {
  #   enable = false;
  #   device = "nodev";
  #   efiSupport = true;
  #   useOSProber = true; # Detect other OS installations
  # };
}

