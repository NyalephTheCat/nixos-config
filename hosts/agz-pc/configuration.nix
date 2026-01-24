{ config, pkgs, lib, ... }:

{
  # Per-host nixpkgs configuration
  # You can configure nixpkgs settings here, or create hosts/agz-pc/nixpkgs.nix
  # Example nixpkgs.nix:
  # { lib }: {
  #   allowUnfree = true;
  #   permittedInsecurePackages = [ "openssl-1.0.2" ];
  # }
  #
  # Or configure in flake.nix:
  # mkHost "agz-pc" {
  #   nixpkgsConfig = { allowUnfree = true; };
  #   hardwareModules = [ nixos-hardware.nixosModules.common-cpu-amd ];
  # }

  imports = [
    # Note: features.nix is automatically imported by mkHost in flake.nix
    # Core system modules (options must be imported first)
    ../../modules/nixos/core/options.nix
    ../../modules/nixos/core/boot.nix
    ../../modules/nixos/core/locale.nix
    ../../modules/nixos/core/networking.nix
    ../../modules/nixos/core/nix.nix
    ../../modules/nixos/core/systemd.nix
    ../../modules/nixos/core/performance.nix
    
    # Hardware modules
    ../../modules/nixos/hardware
    
    # Desktop environment
    ../../modules/nixos/desktop
    
    # Optional features (conditionally loaded)
    ../../modules/nixos/features
    
    # Security
    ../../modules/nixos/security
    
    # Services and packages
    ../../modules/nixos/services
    ../../modules/nixos/packages
  ];

  # System state version
  system.stateVersion = "25.11";

  # Hostname
  networking.hostName = "agz-pc";

  # User configuration for this host
  # Groups are conditionally added based on features
  users.users.agz-cadentis = {
    isNormalUser = true;
    description = "agz";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
    ] ++ lib.optionals config.features.virtualization.docker [ "docker" ]
      ++ lib.optionals config.features.virtualization.libvirt [ "libvirtd" ];
    # TODO: Set initial password with: mkpasswd -m sha-512
    # initialHashedPassword = "...";
  };

  # Host-specific sudo configuration
  # Note: NOPASSWD is a security risk. Consider using password authentication
  # or key-based authentication for better security.
  security.sudo.extraRules = lib.mkDefault [
    {
      users = [ "agz-cadentis" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ]; # Remove if password prompts are desired
        }
      ];
    }
  ];

  # TODO: Add hardware-configuration.nix for this system
  # Run: nixos-generate-config --show-hardware-config > hardware-configuration.nix
}

