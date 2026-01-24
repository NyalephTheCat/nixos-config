{ config, pkgs, lib, ... }:

{
  # Automatic security updates
  # Note: When using flakes, updates are handled via `nix flake update`
  # This auto-upgrade will rebuild from the current flake inputs
  # For flake-based configs, consider disabling this and using manual updates
  system.autoUpgrade = {
    enable = lib.mkDefault false; # Disabled by default for flake-based configs
    allowReboot = lib.mkDefault false; # Set to true if you want automatic reboots
    dates = lib.mkDefault "daily";
    flake = lib.mkDefault null; # Set to your flake path if using flakes
  };

  # Sudo configuration - should be customized per-user in host config
  security.sudo = {
    enable = true;
    wheelNeedsPassword = lib.mkDefault true; # Require password for sudo
    execWheelOnly = lib.mkDefault false; # Set to true for stricter security
  };

  # Polkit for privilege elevation
  security.polkit.enable = true;

  # Additional security hardening
  # CPU mitigations are enabled by default for security
  # Set boot.kernelParams = [ "mitigations=off" ] in host config to disable for performance
  boot.kernelParams = lib.mkDefault [
    "slab_nomerge"  # Prevent slab merging (security hardening)
    "pti=on"        # Page Table Isolation (protects against Meltdown)
    # CPU mitigations are enabled by default in NixOS
  ];

  # Additional security options
  security.protectKernelImage = lib.mkDefault true;
  security.allowUserNamespaces = lib.mkDefault true;
}

