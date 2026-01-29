{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.security;
in
{
  options.system.security = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system security hardening.";
    };

    firewall = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable firewall.";
      };

      allowedTCPPorts = mkOption {
        type = types.listOf types.port;
        default = [];
        description = "List of TCP ports to open in the firewall.";
        example = [ 22 80 443 ];
      };

      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [];
        description = "List of UDP ports to open in the firewall.";
        example = [ 53 67 ];
      };

      allowedTCPPortRanges = mkOption {
        type = types.listOf (types.submodule {
          options = {
            from = mkOption { type = types.port; };
            to = mkOption { type = types.port; };
          };
        });
        default = [];
        description = "List of TCP port ranges to open.";
        example = [ { from = 8000; to = 8010; } ];
      };

      allowedUDPPortRanges = mkOption {
        type = types.listOf (types.submodule {
          options = {
            from = mkOption { type = types.port; };
            to = mkOption { type = types.port; };
          };
        });
        default = [];
        description = "List of UDP port ranges to open.";
        example = [ { from = 8000; to = 8010; } ];
      };

      interfaces = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            allowedTCPPorts = mkOption {
              type = types.listOf types.port;
              default = [];
              description = "TCP ports allowed on this interface.";
            };
            allowedUDPPorts = mkOption {
              type = types.listOf types.port;
              default = [];
              description = "UDP ports allowed on this interface.";
            };
          };
        });
        default = {};
        description = "Interface-specific firewall rules.";
      };
    };

    fail2ban = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable fail2ban intrusion prevention system.";
      };

      bantime = mkOption {
        type = types.str;
        default = "1h";
        description = "Duration for which an IP is banned.";
      };

      findtime = mkOption {
        type = types.str;
        default = "10m";
        description = "Time window for counting failures.";
      };

      maxretry = mkOption {
        type = types.int;
        default = 5;
        description = "Number of failures before banning.";
      };

      ignoreIP = mkOption {
        type = types.listOf types.str;
        default = [ "127.0.0.1/8" "::1" ];
        description = "IP addresses to ignore (whitelist).";
      };
    };

    hardening = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable system security hardening.";
      };

      enableAppArmor = mkOption {
        type = types.bool;
        default = false;
        description = "Enable AppArmor mandatory access control.";
      };

      enableKernelHardening = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kernel security hardening options.";
      };

      restrictSystemdUserServices = mkOption {
        type = types.bool;
        default = false;
        description = "Restrict systemd user services for better security.";
      };
    };

    auditd = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable audit daemon for security auditing.";
      };
    };

    sudo = {
      pwfeedback = mkOption {
        type = types.bool;
        default = true;
        description = "Show asterisks when typing the password in sudo (visual feedback).";
      };
    };
  };

  config = mkIf cfg.enable {
    # Firewall configuration
    networking.firewall = mkIf cfg.firewall.enable {
      enable = true;
      allowedTCPPorts = cfg.firewall.allowedTCPPorts;
      allowedUDPPorts = cfg.firewall.allowedUDPPorts;
      allowedTCPPortRanges = cfg.firewall.allowedTCPPortRanges;
      allowedUDPPortRanges = cfg.firewall.allowedUDPPortRanges;
      interfaces = lib.mapAttrs (name: ifCfg: {
        allowedTCPPorts = ifCfg.allowedTCPPorts;
        allowedUDPPorts = ifCfg.allowedUDPPorts;
      }) cfg.firewall.interfaces;
    };

    # Fail2ban configuration
    services.fail2ban = mkIf cfg.fail2ban.enable {
      enable = true;
      # Note: fail2ban configuration is typically done via jail.local files
      # These options may need to be set differently depending on NixOS version
      extraSettings = ''
        [DEFAULT]
        bantime = ${cfg.fail2ban.bantime}
        findtime = ${cfg.fail2ban.findtime}
        maxretry = ${toString cfg.fail2ban.maxretry}
        ignoreip = ${concatStringsSep " " cfg.fail2ban.ignoreIP}
      '';
    };

    # Security hardening and sudo (merged to avoid defining security twice)
    security = mkMerge [
      (mkIf cfg.hardening.enable {
        # AppArmor
        apparmor = mkIf cfg.hardening.enableAppArmor {
          enable = true;
          packages = [ pkgs.apparmor-utils ];
        };

        # Kernel hardening
        protectKernelImage = cfg.hardening.enableKernelHardening;
        lockKernelModules = cfg.hardening.enableKernelHardening;
      })
      (mkIf cfg.sudo.pwfeedback {
        sudo.extraConfig = "Defaults pwfeedback";
      })
    ];

    # Audit daemon
    # Note: auditd is not available as a NixOS service by default
    # If you need auditd, you may need to install it manually or use a different approach
  };
}
