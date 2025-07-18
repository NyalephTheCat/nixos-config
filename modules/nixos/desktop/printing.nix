{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.printing;
in
{
  options.modules.desktop.printing = {
    enable = mkEnableOption "printing support";
    
    drivers = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        gutenprint
        gutenprintBin
        hplip
        splix
      ];
      description = "Printer drivers to install";
    };
    
    webInterface = mkOption {
      type = types.bool;
      default = true;
      description = "Enable CUPS web interface";
    };
    
    browsing = mkOption {
      type = types.bool;
      default = true;
      description = "Enable printer browsing and discovery";
    };
    
    defaultPaperSize = mkOption {
      type = types.str;
      default = "A4";
      example = "Letter";
      description = "Default paper size";
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra CUPS configuration";
    };
  };

  config = mkIf cfg.enable {
    # Enable CUPS printing service
    services.printing = {
      enable = true;
      drivers = cfg.drivers;
      webInterface = cfg.webInterface;
      browsing = cfg.browsing;
      defaultShared = false;
      
      extraConf = ''
        DefaultPaperSize ${cfg.defaultPaperSize}
        ${cfg.extraConfig}
      '';
    };
    
    # Enable printer discovery via Avahi
    services.avahi = mkIf cfg.browsing {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    
    # Printing utilities
    environment.systemPackages = with pkgs; [
      system-config-printer
      cups-filters
      ghostscript
    ] ++ optionals config.services.xserver.enable [
      # GUI tools only if we have X11
      simple-scan
    ];
    
    # Open firewall for CUPS if browsing is enabled
    networking.firewall = mkIf cfg.browsing {
      allowedTCPPorts = [ 631 ];
      allowedUDPPorts = [ 631 ];
    };
  };
}