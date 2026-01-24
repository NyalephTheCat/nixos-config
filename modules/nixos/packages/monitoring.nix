{ config, pkgs, lib, ... }:

{
  # Monitoring tools - system monitoring utilities
  environment.systemPackages = with pkgs; lib.mkDefault [
    iotop
    nethogs
  ];
}

