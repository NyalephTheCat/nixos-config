{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.bluetooth;
in {
  options.modules.desktop.bluetooth = {
    enable = mkEnableOption "Bluetooth support";
    
    audio = {
      enable = mkEnableOption "Bluetooth audio support" // { default = true; };
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
          FastConnectable = true;
          
          # Better audio quality
          MultiProfile = "multiple";
        };
        
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # Bluetooth GUI manager
    services.blueman.enable = true;

    # Packages for better Bluetooth experience
    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
      bluez-alsa
      blueberry  # Alternative GTK Bluetooth manager
    ];

    # Ensure the Bluetooth service can be managed by users
    systemd.services.bluetooth.serviceConfig.ExecStart = [
      ""
      "${pkgs.bluez}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf"
    ];
  };
}