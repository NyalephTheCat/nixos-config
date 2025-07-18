{ pkgs, ... }:

{
  # System configuration
  networking.hostName = "veilkeepers";
  networking.networkmanager.enable = true;

  # Locale and timezone
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
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
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };
  console.keyMap = "us";

  # User configuration
  users.users.nyaleph = {
    isNormalUser = true;
    description = "nyaleph";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "audio" ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable modules
  modules = {
    desktop.plasma.enable = true;
    gaming.enable = true;
    communication.enable = true;
    development = {
      enable = true;
      languages = {
        enable = true;
        nix.enable = true;
        rust.enable = true;
        go.enable = true;
        python.enable = true;
        javascript.enable = true;
      };
      tools.enable = true;
      containers.enable = true;
      databases = {
        enable = true;
        postgresql.enable = true;
        redis.enable = true;
      };
    };
  };

  # Enable Docker
  virtualisation.docker.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  system.stateVersion = "25.05";
}
