# Placeholder hardware configuration for agz-pc
# TODO: Replace this with actual hardware configuration
# Run on the target system: nixos-generate-config --show-hardware-config

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # TODO: Configure boot loader and file systems based on actual hardware
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # TODO: Configure file systems
  # fileSystems."/" = { ... };
  # fileSystems."/boot" = { ... };

  # TODO: Configure swap devices if any
  # swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

