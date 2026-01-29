{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.network;
in
{
  options.system.network = {
    enable = mkEnableOption "network configuration";

    hostName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "System hostname.";
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Network domain name.";
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of DNS nameservers.";
      example = [ "1.1.1.1" "8.8.8.8" ];
    };

    search = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of DNS search domains.";
    };

    useDHCP = mkOption {
      type = types.bool;
      default = true;
      description = "Use DHCP for network configuration.";
    };

    useNetworkd = mkOption {
      type = types.bool;
      default = false;
      description = "Use systemd-networkd instead of NetworkManager.";
    };

    wireless = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable wireless networking.";
      };

      userControlled = mkOption {
        type = types.bool;
        default = true;
        description = "Allow users to control wireless interfaces.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking = {
      hostName = mkIf (cfg.hostName != null) cfg.hostName;
      domain = mkIf (cfg.domain != null) cfg.domain;
      nameservers = mkIf (cfg.nameservers != []) cfg.nameservers;
      search = mkIf (cfg.search != []) cfg.search;
      useDHCP = cfg.useDHCP;
      useNetworkd = cfg.useNetworkd;
    };

    networking.wireless = mkIf cfg.wireless.enable {
      enable = true;
      userControlled = cfg.wireless.userControlled;
    };
  };
}
