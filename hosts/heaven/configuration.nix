{ config, pkgs, lib, ... }:

{
  # Per-host nixpkgs configuration
  # You can configure nixpkgs settings here, or create hosts/heaven/nixpkgs.nix
  # Example nixpkgs.nix:
  # { lib }: {
  #   allowUnfree = true;
  #   permittedInsecurePackages = [ "openssl-1.0.2" ];
  # }
  #
  # Or configure in flake.nix:
  # mkHost "heaven" {
  #   nixpkgsConfig = { allowUnfree = true; };
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
  system.stateVersion = "25.11"; # DO NOT CHANGE

  # Hostname
  networking.hostName = "heaven";

  # User configuration for this host
  # Groups are conditionally added based on features
  users.users.nyaleph = {
    isNormalUser = true;
    description = "nyaleph";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
    ] ++ lib.optionals config.features.virtualization.docker [ "docker" ]
      ++ lib.optionals config.features.virtualization.libvirt [ "libvirtd" ];
    initialHashedPassword = "$6$Oa35NABtj91MIx8R$/B4tw/8iQUoaFUX8VBHLAy5dg2WQEaLJZRssC4ncUwEKlwM957ilo1sAN1KEC02YRDO9DsQTiEQTLE1pP08PT/";
  };

  # Host-specific sudo configuration
  # Note: NOPASSWD is a security risk. Consider using password authentication
  # or key-based authentication for better security.
  security.sudo.extraRules = lib.mkDefault [
    {
      users = [ "nyaleph" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}

