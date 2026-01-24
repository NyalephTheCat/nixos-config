{ config, pkgs, lib, ... }:

let
  cfg = config.features.printing or { enable = true; };
in
{
  config = lib.mkIf cfg.enable {
    # Printing service (CUPS)
    services.printing.enable = true;
    
    # Optional: Enable printer discovery
    services.avahi = {
      enable = lib.mkDefault true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}

