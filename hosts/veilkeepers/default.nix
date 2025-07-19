{ lib, nixos-hardware, ... }:

{
  imports = [ ./configuration.nix ./hardware-configuration.nix ];

  hardware.nvidia.prime = {
    amdgpuBusId = lib.mkForce "PCI:5:0:0"; # Your correct AMD bus
    nvidiaBusId = lib.mkForce "PCI:1:0:0"; # Your correct NVIDIA bus
    sync.enable = lib.mkForce true;
    offload.enable = lib.mkForce false;
  };
}
