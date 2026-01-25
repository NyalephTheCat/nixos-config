{ config, pkgs, ... }:

{
  # AMD GPU drivers (hardware.opengl.* has been renamed to hardware.graphics.*)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Mesa with AMD support
  # Note: amdvlk has been deprecated and removed. RADV (Mesa's Vulkan driver) is enabled by default.
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  # Enable hardware acceleration
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
}

