{ config, pkgs, lib, ... }:

{
  # Intel integrated graphics configuration
  # Use this profile when features.hardware.gpu = "intel"
  
  config = lib.mkIf ((config.features.hardware.gpu or "none") == "intel") {
    # Intel GPU drivers
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}

