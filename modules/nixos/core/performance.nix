{ config, pkgs, lib, ... }:

let
  hardwareType = config.features.hardware.type or "desktop";
  isDesktop = hardwareType == "desktop";
in
{
  # Performance optimizations

  # CPU governor (handled by power.nix, but can be overridden here)
  powerManagement.cpuFreqGovernor = lib.mkIf isDesktop (lib.mkDefault "performance");

  # I/O scheduler tuning
  # For SSDs, use none or noop scheduler
  # For HDDs, use mq-deadline or bfq scheduler
  # Note: I/O scheduler is set via kernel parameters below

  # Swap configuration
  swapDevices = lib.mkDefault [];
  
  # Note: Zram swap is configured in modules/nixos/services/common.nix
  # Remove it from here to avoid conflicts

  # Kernel parameters for performance
  # Note: These are merged with other kernel parameters from other modules
  boot.kernelParams = lib.mkMerge [
    (lib.mkDefault [
      # Disable mitigations for performance (security trade-off)
      # "mitigations=off"  # Uncomment only if security is not a concern
      
      # CPU performance
      "intel_idle.max_cstate=1"  # Limit CPU idle states (Intel)
      
      # I/O performance
      # "elevator=none"  # For SSDs (uncomment if using SSD)
      # "elevator=mq-deadline"  # For HDDs (uncomment if using HDD)
    ])
  ];

  # Systemd service limits for performance
  # Note: This is merged with systemd.settings.Manager from systemd.nix
  # Disable accounting for better performance (use mkForce to override NixOS defaults)
  systemd.settings.Manager = {
    DefaultCPUAccounting = lib.mkForce false;
    DefaultIOAccounting = lib.mkForce false;
    DefaultMemoryAccounting = lib.mkForce false;
  };
}

