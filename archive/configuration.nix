{ config, pkgs, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";

  imports = [
    # Hardware configuration
    ./hardware-configuration.nix

    # System modules
    ./modules/system/boot.nix
    ./modules/system/locale.nix
    ./modules/system/networking.nix

    # Hardware modules
    ./modules/hardware/hardware.nix

    # Nix configuration
    ./modules/nix/nix.nix

    # Users
    ./modules/users/users.nix

    # Packages
    ./modules/packages/packages.nix

    # Programs
    ./modules/programs/programs.nix

    # Services
    ./modules/services/services.nix

    # Desktop
    ./modules/desktop/desktop.nix

    # Security
    ./modules/security/security.nix

    # Performance
    ./modules/performance/performance.nix

    # Virtualization
    ./modules/virtualization/virtualization.nix

    # Shell
    ./modules/shell/shell.nix

    # Gaming
    ./modules/gaming/gaming.nix

    # Backup
    ./modules/backup/backup.nix
  ];
}

