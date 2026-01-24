{ config, pkgs, lib, ... }:

{
  # NVIDIA GPU optimizations and configuration
  # Use this profile when features.hardware.gpu = "nvidia"
  
  config = lib.mkIf ((config.features.hardware.gpu or "none") == "nvidia") {
    # NVIDIA GPU drivers
    services.xserver.videoDrivers = [ "nvidia" ];
    
    hardware.nvidia = {
      # Enable NVIDIA drivers
      open = false;  # Use proprietary drivers (set to true for open-source)
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      
      # Power management
      powerManagement.enable = true;
      
      # Modesetting (required for Wayland)
      modesetting.enable = true;
    };

    # OpenGL support
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}

