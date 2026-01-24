{ config, pkgs, lib, ... }:

{
  # Network tools - system-wide network utilities
  environment.systemPackages = with pkgs; lib.mkDefault [
    nmap
    wireshark
    tcpdump
    mtr
  ];
}

