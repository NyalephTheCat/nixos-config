{ config, pkgs, lib, ... }:

{
  # Systemd improvements and optimizations

  # Systemd service limits
  # Note: Additional config can be added in performance.nix
  systemd.settings.Manager = {
    DefaultLimitNOFILE = lib.mkDefault 65536;
    DefaultLimitNPROC = lib.mkDefault 4096;
  };

  # Systemd journal configuration
  # Note: Many journald options are configured via extraConfig, not direct options
  services.journald = {
    # Enable persistent storage
    storage = lib.mkDefault "persistent";
    # Rate limit
    rateLimitInterval = lib.mkDefault "30s";
    rateLimitBurst = lib.mkDefault 10000;  # Must be an integer, not a string
    # Additional journald settings via extraConfig
    extraConfig = lib.mkDefault ''
      SystemMaxUse=10G
      MaxRetentionSec=30day
    '';
  };

  # Systemd networkd wait-online improvements
  systemd.network.wait-online = {
    # Wait for all interfaces
    anyInterface = lib.mkDefault true;
    # Timeout for waiting
    timeout = lib.mkDefault 5;
    # Ignore specific interfaces (e.g., loopback)
    ignoredInterfaces = lib.mkDefault [ "lo" ];
  };

  # Enable systemd user services
  systemd.user.services = lib.mkDefault {};

  # Systemd timer improvements
  systemd.timers = lib.mkDefault {};

  # OOM (Out of Memory) killer adjustments
  systemd.oomd = {
    enable = lib.mkDefault true;
    enableRootSlice = lib.mkDefault true;
    enableUserSlices = lib.mkDefault true;  # Renamed from enableUserServices
  };
}

