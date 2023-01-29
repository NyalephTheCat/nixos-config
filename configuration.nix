{ config, pkgs, hyprland, lanzaboote, ... }:

let
  nixpkgs = pkgs;
  recApply = list:
    if ((builtins.length list) == 1) then (builtins.head list) else
    { "${builtins.head list}" = recApply (builtins.tail list); };
  getAttrOrDefault = s: set: default: (builtins.getAttr (if builtins.hasAttr s set then s else default) set);
  nixOsVersion = "23.05"; # Replace with actual test
  paths = {
    "23.05" = [ "settings" "dns_enabled" true ];
    default = [ "dnsname" "enable" true ];
  };
in
{
  boot.loader.systemd-boot.enable = true;
  boot.lanzaboote = {
    enable = false;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = nixpkgs.linuxPackages_5_15;
  boot.bootspec.enable = true;
  networking.hostName = "hades";
  networking.networkmanager.enable = true;

  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.utf8";

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };
  programs.hyprland.enable = true;

  console.keyMap = "fr";

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    media-session.config.bluez-monitor = {
      properties = { bluez5.codecs = [ "ldac" "aptx_hd" ]; };
      rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
              # mSBC is not expected to work on all headset + adapter combinations.
              "bluez5.msbc-support" = true;
              # SBC-XQ is not expected to work on all headset + adapter combinations.
              "bluez5.sbc-xq-support" = true;
            };
          };
        }
        {
          matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
          actions = {
            "node.pause-on-idle" = false;
          };
        }
      ];
    };
  };

  users.users.root.initialPassword = "rootPassword";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    extra-platforms = [ "aarch64-linux" ];
  };
  nix.registry = { };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = with nixpkgs; [
    vim
    wget
    fish
    micro
    gnome.gnome-screenshot
    virt-manager
    gnome.gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnome.adwaita-icon-theme
    gnomeExtensions.appindicator
    git # Now needed for Flakes compat
    sbctl
  ];

  environment.gnome.excludePackages = (with nixpkgs; [
    gnome-tour
  ]) ++ (with nixpkgs.gnome; [
    cheese # webcam tool
    epiphany # web browser
    geary # email reader
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    gnome-maps
  ]);


  programs.dconf.enable = true;
  programs.fish.enable = true;
  users.users.chloe.shell = nixpkgs.fish;

  fonts.fonts = with nixpkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "CascadiaCode"
        "UbuntuMono"
        "Ubuntu"
      ];
    })
  ];

  system.stateVersion = "22.05"; # Did you read the comment?

  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    users = [ "chloe" ];
    keepEnv = true;
    persist = true;
  }];

  services.flatpak.enable = true;
  programs.steam.enable = true;
}
