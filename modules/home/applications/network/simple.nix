{ config, pkgs, lib, customUtils, ... }:

# Network tools and VPN clients
(customUtils.mkMultipleApps [
  { name = "wireshark"; defaultPackage = pkgs.wireshark; description = "Wireshark network analyzer"; }
  { name = "nmap"; defaultPackage = pkgs.nmap; description = "Nmap network scanner"; }
  { name = "mullvad-vpn"; defaultPackage = pkgs.mullvad-vpn; description = "Mullvad VPN client"; }
  { name = "openvpn"; defaultPackage = pkgs.openvpn; description = "OpenVPN client"; }
  { name = "wireguard-tools"; defaultPackage = pkgs.wireguard-tools; description = "WireGuard tools"; }
  { name = "networkmanager-openvpn"; defaultPackage = pkgs.networkmanager-openvpn; description = "NetworkManager OpenVPN plugin"; }
]) { inherit config pkgs lib; }
