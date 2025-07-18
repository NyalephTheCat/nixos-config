{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.bluetooth;
in
{
  options.modules.desktop.bluetooth = {
    enable = mkEnableOption "Bluetooth support";
    
    package = mkOption {
      type = types.package;
      default = pkgs.bluez;
      description = "Bluetooth package to use";
    };
    
    powerOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to power on the Bluetooth controller on boot";
    };
    
    hsphfpd.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable hsphfpd for headset support";
    };
    
    settings = {
      general = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable general Bluetooth settings";
        };
        
        controllerMode = mkOption {
          type = types.enum [ "dual" "bredr" "le" ];
          default = "dual";
          description = "Controller mode";
        };
        
        fastConnectable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable fast connectable mode";
        };
        
        experimental = mkOption {
          type = types.bool;
          default = true;
          description = "Enable experimental features";
        };
      };
      
      policy = {
        autoEnable = mkOption {
          type = types.bool;
          default = true;
          description = "Auto enable Bluetooth controllers";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable Bluetooth
    hardware.bluetooth = {
      enable = true;
      package = cfg.package;
      powerOnBoot = cfg.powerOnBoot;
      hsphfpd.enable = cfg.hsphfpd.enable;
      
      settings = mkMerge [
        (mkIf cfg.settings.general.enable {
          General = {
            Enable = "Source,Sink,Media,Socket";
            ControllerMode = cfg.settings.general.controllerMode;
            FastConnectable = cfg.settings.general.fastConnectable;
            Experimental = cfg.settings.general.experimental;
            
            # Better audio quality settings
            MultiProfile = "multiple";
            
            # Privacy settings
            Privacy = "device";
            JustWorksRepairing = "always";
            
            # Power saving
            Class = "0x000100";
            
            # Name
            Name = "%h";
            
            # Discoverable timeout (0 = always discoverable)
            DiscoverableTimeout = 0;
            
            # Pairable timeout (0 = always pairable)
            PairableTimeout = 0;
          };
        })
        
        {
          Policy = {
            AutoEnable = cfg.settings.policy.autoEnable;
          };
        }
      ];
    };
    
    # Bluetooth manager
    services.blueman.enable = true;
    
    # Bluetooth audio configuration
    services.pipewire.wireplumber.configPackages = mkIf config.services.pipewire.enable [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
    
    # Bluetooth utilities
    environment.systemPackages = with pkgs; [
      bluez-tools
      bluetuith # TUI bluetooth manager
    ] ++ optionals config.services.xserver.enable [
      # GUI tools only if we have X11
      blueberry
    ];
    
    # Ensure Bluetooth service is enabled
    systemd.services.bluetooth.wantedBy = [ "multi-user.target" ];
    
    # User permissions for Bluetooth
    users.users.nyaleph = {
      extraGroups = [ "lp" ]; # For Bluetooth audio
    };
  };
}