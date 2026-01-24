{ config, pkgs, lib, ... }:

{
  # Laptop-specific optimizations
  # Use this profile when features.hardware.type = "laptop"
  
  config = lib.mkIf ((config.features.hardware.type or "desktop") == "laptop") {
    # Power management for laptops
    powerManagement = {
      enable = true;
      cpuFreqGovernor = lib.mkDefault "powersave";  # Use powersave for laptops
    };

    # TLP for advanced power management (optional, uncomment if desired)
    # services.tlp = {
    #   enable = true;
    #   settings = {
    #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
    #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    #   };
    # };

    # Enable laptop-specific services
    services.upower.enable = lib.mkDefault true;
    
    # Laptop-specific kernel parameters
    boot.kernelParams = [
      "acpi_osi=Linux"  # Better ACPI support
    ];
  };
}

