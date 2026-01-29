{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.ssh;
in
{
  options.system.ssh = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable SSH server.";
    };

    port = mkOption {
      type = types.port;
      default = 22;
      description = "SSH server port.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall port for SSH.";
    };

    permitRootLogin = mkOption {
      type = types.enum [ "yes" "no" "prohibit-password" "forced-commands-only" ];
      default = "no";
      description = "Whether to allow root login.";
    };

    passwordAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow password authentication.";
    };

    pubkeyAuthentication = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to allow public key authentication.";
    };

    authorizedKeysFiles = mkOption {
      type = types.str;
      default = "%h/.ssh/authorized_keys";
      description = "Authorized keys file pattern.";
    };

    maxStartups = mkOption {
      type = types.str;
      default = "10:30:100";
      description = "Maximum number of concurrent unauthenticated connections.";
    };

    maxAuthTries = mkOption {
      type = types.int;
      default = 3;
      description = "Maximum authentication attempts per connection.";
    };

    clientAliveInterval = mkOption {
      type = types.int;
      default = 0;
      description = "Client alive interval in seconds (0 to disable).";
    };

    clientAliveCountMax = mkOption {
      type = types.int;
      default = 3;
      description = "Number of client alive messages before disconnecting.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra SSH server configuration.";
    };

    hostKeys = mkOption {
      type = types.listOf (types.submodule {
        options = {
          type = mkOption {
            type = types.enum [ "rsa" "ed25519" "ecdsa" ];
            description = "Host key type.";
          };
          bits = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Key size in bits (for RSA/ECDSA).";
          };
          path = mkOption {
            type = types.str;
            description = "Path to host key file.";
          };
        };
      });
      default = [];
      description = "SSH host keys configuration.";
    };

    knownHosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          hostNames = mkOption {
            type = types.listOf types.str;
            description = "List of host names for this key.";
          };
          publicKey = mkOption {
            type = types.str;
            description = "Public key data.";
          };
        };
      });
      default = {};
      description = "Known SSH hosts for client configuration.";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        Port = toString cfg.port;
        PermitRootLogin = cfg.permitRootLogin;
        PasswordAuthentication = cfg.passwordAuthentication;
        PubkeyAuthentication = cfg.pubkeyAuthentication;
        AuthorizedKeysFile = cfg.authorizedKeysFiles;
        MaxStartups = cfg.maxStartups;
        MaxAuthTries = toString cfg.maxAuthTries;
        ClientAliveInterval = toString cfg.clientAliveInterval;
        ClientAliveCountMax = toString cfg.clientAliveCountMax;
      };
      extraConfig = cfg.extraConfig;
      hostKeys = map (key: {
        type = key.type;
        bits = key.bits;
        path = key.path;
      }) cfg.hostKeys;
    };

    # Open firewall if requested
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    # Note: Known hosts for SSH client should be configured in Home Manager, not here
  };
}
