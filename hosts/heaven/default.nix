{ config, pkgs, lib, home-manager, customUtils, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/plasma6.nix
    ../../modules/system/amd-drivers.nix
    ../../modules/system/basic-apps.nix
  ];

  # System configuration
  system.stateVersion = "25.11";
  
  # Bootloader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  
  # Hostname
  networking.hostName = "heaven";
  
  # Time zone
  time.timeZone = "Europe/Paris";
  
  # Locale
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Keyboard layout
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "intl";
    };
  };

  # Enable zsh at system level (required when user shell is zsh)
  programs.zsh.enable = true;

  # Users
  users.users.nyaleph = {
    isNormalUser = true;
    description = "nyaleph";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
    shell = pkgs.zsh;
  };

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nyaleph = import ../../home/users/nyaleph.nix;
    extraSpecialArgs = { inherit pkgs lib customUtils; };
    # Backup files that would be overwritten
    backupFileExtension = "bkp";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}

