{ config, lib, pkgs, ... }:
{
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;  # see the note above

  hardware.nvidia.prime = {
      sync.enable = true;

      # Bus ID of the NVIDIA GPU
      nvidiaBusId = "PCI:01:00:0";

      # Bus ID of the AMD GPU (not Intel!)
      amdgpuBusId = "PCI:05:00:0";
  };
}
