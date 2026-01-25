{ config, pkgs, ... }:

{
  # Hardware configuration for agz-pc
  # AMD-specific optimizations can be added here
  
  # Boot configuration
  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # CPU microcode
  hardware.cpu.amd.updateMicrocode = true;
}

