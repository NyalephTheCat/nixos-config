{ lib, pkgs, ... }:

{
  imports = [
    ./plasma.nix
    ./browsers.nix
    ./audio.nix
    ./fonts.nix
    ./printing.nix
    ./bluetooth.nix
    ./media.nix
  ];

  # Common desktop configuration that applies regardless of DE choice
  config = {
    # Enable X11
    services.xserver.enable = lib.mkDefault true;

    # Enable touchpad support (if laptop)
    services.libinput.enable = lib.mkDefault true;

    # Common desktop packages
    environment.systemPackages = with pkgs; [
      file-roller  # Archive manager
      evince       # PDF viewer
      libreoffice  # Office suite
    ];

    # Enable network discovery
    services.avahi = {
      enable = lib.mkDefault true;
      nssmdns4 = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };
    
    # Enable the new modular components with sensible defaults
    modules.desktop = {
      audio.enable = lib.mkDefault true;
      fonts.enable = lib.mkDefault true;
      printing.enable = lib.mkDefault true;
      bluetooth.enable = lib.mkDefault true;
      media.enable = lib.mkDefault true;
    };
  };
}
