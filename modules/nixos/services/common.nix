{ config, pkgs, lib, ... }:

{
  # Flatpak service for flatpak application support
  services.flatpak.enable = lib.mkDefault true;

  # Time synchronization
  services.timesyncd.enable = lib.mkDefault true;

  # Enable power management
  powerManagement.enable = lib.mkDefault true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Enable earlyoom (out-of-memory killer)
  services.earlyoom = {
    enable = lib.mkDefault true;
    freeMemThreshold = lib.mkDefault 10;
    freeSwapThreshold = lib.mkDefault 10;
  };

  # Zram swap for better memory management
  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = lib.mkDefault "zstd";
    memoryPercent = lib.mkDefault 50;
  };

  # Kernel sysctl settings for performance
  boot.kernel.sysctl = {
    # Network performance
    "net.core.rmem_max" = lib.mkDefault 134217728;
    "net.core.wmem_max" = lib.mkDefault 134217728;
    "net.ipv4.tcp_rmem" = lib.mkDefault "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = lib.mkDefault "4096 65536 134217728";
    
    # File system performance
    "vm.swappiness" = lib.mkDefault 10;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
    
    # CPU scheduler
    "kernel.sched_migration_cost_ns" = lib.mkDefault 5000000;
  };

  # Performance kernel parameters
  # WARNING: "mitigations=off" improves performance but reduces security
  boot.kernelParams = lib.mkDefault [
    "mitigations=off" # Disable CPU mitigations for performance
  ];
}

