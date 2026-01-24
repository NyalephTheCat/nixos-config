{ config, pkgs, lib, ... }:

let
  hardwareType = config.features.hardware.type or "desktop";
  isLaptop = hardwareType == "laptop";
  isDesktop = hardwareType == "desktop";
in
{
  # Power management configuration
  # Based on hardware type (desktop/laptop) from features.hardware.type

  # CPU governor settings
  # Desktop: performance governor for maximum performance
  # Laptop: balanced or powersave governor for battery life
  powerManagement = {
    enable = lib.mkDefault true;
    cpuFreqGovernor = if isDesktop then (lib.mkDefault "performance") else (lib.mkDefault "ondemand");
  };

  # Laptop-specific power management
  services = lib.mkMerge [
    # Laptop-specific services
    (lib.mkIf isLaptop {
      # TLP for advanced power management (laptops)
      tlp = {
        enable = lib.mkDefault true;
        settings = {
          # CPU settings
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          
          # CPU frequency scaling
          CPU_SCALING_MIN_FREQ_ON_AC = 0;
          CPU_SCALING_MAX_FREQ_ON_AC = 0;
          CPU_SCALING_MIN_FREQ_ON_BAT = 0;
          CPU_SCALING_MAX_FREQ_ON_BAT = 0;
          
          # Power saving on battery
          START_CHARGE_THRESH_BAT0 = 75;
          STOP_CHARGE_THRESH_BAT0 = 80;
        };
      };

      # Power profile daemon (alternative to TLP, used by some desktop environments)
      power-profiles-daemon.enable = lib.mkDefault false; # Disable if using TLP
    })
    
    # Thermal management (laptops)
    {
      thermald.enable = lib.mkDefault isLaptop;
    }
    
    # Power button action
    # Note: Use services.logind.settings.Login for all power-related settings
    {
      logind = {
        settings.Login = {
          HandlePowerKey = lib.mkDefault "poweroff";
          HandleSuspendKey = lib.mkDefault "suspend";
          HandleHibernateKey = lib.mkDefault "hibernate";
          HandleLidSwitch = lib.mkDefault "suspend";  # Renamed from lidSwitch
          HandleLidSwitchExternalPower = lib.mkDefault "ignore";  # Renamed from lidSwitchExternalPower
          HandleLidSwitchDocked = lib.mkDefault "ignore";  # Renamed from lidSwitchDocked
        };
      };
    }
  ];

  # Suspend/hibernate settings
  systemd.sleep.extraConfig = lib.mkDefault ''
    # Suspend mode: deep (default), s2idle, or shallow
    [Sleep]
    SuspendMode=deep
    HibernateMode=shutdown
  '';
}

