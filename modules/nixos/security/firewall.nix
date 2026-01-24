{ config, pkgs, lib, ... }:

{
  # Firewall configuration
  networking.firewall = {
    enable = lib.mkDefault true;
    # Allow SSH (if enabled)
    allowedTCPPorts = lib.mkDefault [ ];
    allowedUDPPorts = lib.mkDefault [ ];
    # Allow ping
    allowPing = lib.mkDefault true;
    # Log dropped packets (useful for debugging but can be verbose)
    logRefusedConnections = lib.mkDefault false;
    # Log dropped packets to syslog
    logRefusedUnicastsOnly = lib.mkDefault false;
    # Reject instead of drop (faster failure, but reveals firewall presence)
    rejectPackets = lib.mkDefault false;
    # Check reverse path filtering (prevents IP spoofing)
    checkReversePath = lib.mkDefault true;
  };
}

