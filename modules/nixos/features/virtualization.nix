{ config, pkgs, lib, ... }:

let
  cfg = config.features.virtualization or { docker = false; libvirt = false; };
in
{
  config = lib.mkMerge [
    # Docker configuration
    (lib.mkIf cfg.docker {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        daemon.settings = {
          # Optional: configure Docker daemon
          # log-driver = "json-file";
          # log-opts = {
          #   max-size = "10m";
          #   max-file = "3";
          # };
        };
      };
    })

    # Libvirt/QEMU configuration
    (lib.mkIf cfg.libvirt {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true; # Software TPM for secure VMs
        };
      };

      # Firewall rules for virtualization services
      networking.firewall.allowedTCPPorts = lib.mkDefault [
        5900 # VNC (for remote VM access)
      ];
    })

    # Podman (alternative to Docker, commented by default)
    # (lib.mkIf cfg.podman {
    #   virtualisation.podman = {
    #     enable = true;
    #     dockerCompat = true;
    #     defaultNetwork.settings.dns_enabled = true;
    #   };
    # })
  ];
}

