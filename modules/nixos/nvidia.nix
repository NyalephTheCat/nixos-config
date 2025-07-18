{ config, lib, pkgs, ... }:
{
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
      };

      # Bus ID of the NVIDIA GPU
      nvidiaBusId = "PCI:1:0:0";

      # Bus ID of the AMD GPU (not Intel!)
      amdgpuBusId = "PCI:5:0:0";
    };
  };
}
