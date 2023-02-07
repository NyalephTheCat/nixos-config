{ config, pkgs, inputs, ... }:

{
  # Create safe but clean environment
  environment = {
    defaultPackages = [ ]; # Remove unnecessary preinstalled packages
    systemPackages = with pkgs; [ # Safety net
      sbctl
      fish
      wget
      vim
      git
      firefox
      sqlite
    ];
  };

  xdg.portal.enable = true;

  # Nix settings to cleanup and enable flakes
  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-users = [ "chloe" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # Boot using lanzaboote and clean /tmp/
  boot = {
    cleanTmpDir = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
    loader = {
      systemd-boot.enable = pkgs.lib.mkForce false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
    kernelPackages = pkgs.linuxPackages_5_15;
    bootspec.enable = true;
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  # Setup the chloe user
  users.users.chloe = {
    isNormalUser = true;
    extraGroups = [ "input" "wheel" ];
    shell = pkgs.zsh;
  };

  # Setup networking
  networking.networkmanager.enable = true;

  # Set environement variables
  environment.variables = {
    NIXOS_CONIG_DIR = "$HOME/.config/nixos";
    XDG_DATA_HOME = "$HOME/.local/share";
  };
  environment.shells = with pkgs; [ zsh ];

  # Security
  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          users = [ "chloe" ];
          keepEnv = true;
          persist = true;
        }
      ];
    };
    protectKernelImage = true;
  };

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;

  # Enable nvidia drivers
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "modesetting" "nvidia" ];
      layout = "us";
      xkbVariant = "";

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      open = true;
    };
    bluetooth.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
    };
  };

  system.stateVersion = "22.05";
}
