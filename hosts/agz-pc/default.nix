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
  
  # Hostname
  networking.hostName = "agz-pc";
  
  # Time zone
  time.timeZone = "America/Sao_Paulo";
  
  # Locale
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Keyboard layout
  services.xserver = {
    xkb = {
      layout = "br";
      variant = "abnt2";
    };
  };

  # Users
  users.users.agz-cadentis = {
    isNormalUser = true;
    description = "agz-cadentis";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
    shell = pkgs.zsh;
  };

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.agz-cadentis = import ../../home/users/agz-cadentis.nix;
    extraSpecialArgs = { inherit pkgs lib customUtils; };
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

