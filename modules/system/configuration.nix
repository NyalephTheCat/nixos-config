{ config, pkgs, inputs, ... }:

{
  # Remove unecessary preinstalled packages
  environment.defaultPackages = [ ];

  programs.zsh.enable = true;

  # Laptop-specific packages (the other ones are installed in `packages.nix`)
  environment.systemPackages = with pkgs; [
    sbctl
    fish
    wget
    vim
    git
  ];

  # Install fonts
  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override { 
        fonts = [ 
          "FiraCode" 
          "CascadiaCode" 
          "UbuntuMono" 
          "Ubuntu" 
        ];
      })
    ];

    fontconfig = {
      hinting.autohint = true;
      defaultFonts = {
        emoji = [ "OpenMoji Color" ];
      };
    };
  };


  # Wayland stuff: enable XDG integration, allow sway to use brillo
  xdg = {
    portal = {
      enable = true;
    };
  };

  programs.hyprland.enable = true;

  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = [ "chloe" ];
    settings.substituters = [ "https://hyprland.cachix.org" ];
    settings.trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
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

  # Boot settings: clean /tmp/, latest kernel and enable bootloader
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

  # Set up locales (timezone and keyboard layout)
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  # Set up user and enable sudo
  users.users.chloe = {
    isNormalUser = true;
    extraGroups = [ "input" "wheel" ];
    shell = pkgs.zsh;
  };

  # Set up networking and secure it
  networking = {
    networkmanager.enable = true;
  };

  # Set environment variables
  environment.variables = {
    NIXOS_CONFIG = "$HOME/.config/nixos/configuration.nix";
    NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
    XDG_DATA_HOME = "$HOME/.local/share";
    PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
    GTK_RC_FILES = "$HOME/.local/share/gtk-1.0/gtkrc";
    GTK2_RC_FILES = "$HOME/.local/share/gtk-2.0/gtkrc";
    MOZ_ENABLE_WAYLAND = "1";
    ZK_NOTEBOOK_DIR = "$HOME/stuff/notes/";
    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
    ANKI_WAYLAND = "1";
    DISABLE_QT5_COMPAT = "0";
  };

  # Security 
  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [{
        users = [ "chloe" ];
        keepEnv = true;
        persist = true;
      }];
    };

    # Extra security
    protectKernelImage = true;
  };

  # Sound
  sound = {
    enable = true;
  };

  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  
  # Disable bluetooth, enable pulseaudio, enable opengl (for Wayland)
  services = {
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
      };
      desktopManager = {
        gnome.enable = true;
      };
      videoDrivers = [ "modesetting" "nvidia" ];
      layout = "us";
      xkbVariant = "";
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

  # Do not touch
  system.stateVersion = "22.05";
}
