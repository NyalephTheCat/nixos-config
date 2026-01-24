{ config, pkgs, lib, ... }:

{
  # Networking configuration
  # NetworkManager provides easy network management via GUI and CLI
  # Handles WiFi, Ethernet, VPN, and mobile broadband connections
  networking.networkmanager.enable = lib.mkDefault true;
  
  # System hostname - should be overridden in host configuration
  networking.hostName = lib.mkDefault "nixos";
  
  # Optional: Static IP configuration (uncomment and configure if needed)
  # networking.interfaces.eth0.ipv4.addresses = [ {
  #   address = "192.168.1.100";
  #   prefixLength = 24;
  # } ];
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
}

