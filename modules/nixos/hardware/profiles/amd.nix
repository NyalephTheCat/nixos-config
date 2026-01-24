{ config, pkgs, lib, ... }:

{
  # AMD GPU optimizations and configuration
  # Use this profile when features.hardware.gpu = "amd"
  
  config = lib.mkIf ((config.features.hardware.gpu or "none") == "amd") {
    # AMD GPU drivers
    # Note: Use hardware.graphics instead of hardware.opengl (deprecated)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;  # Renamed from driSupport32Bit
    };

    # AMD GPU-specific settings
    # Enable AMDGPU kernel module
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    # Performance optimizations for AMD GPUs
    # These can be tuned based on your specific GPU
    boot.kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff"  # Enable all powerplay features
      # Additional AMD optimizations
      "amdgpu.gpu_recovery=1"            # Enable GPU recovery
      "radeon.cik_support=0"            # Disable old Radeon CIK support if using newer GPUs
      "radeon.si_support=0"              # Disable old Radeon SI support if using newer GPUs
    ];

    # AMD GPU power management
    services.xserver.videoDrivers = [ "amdgpu" ];
    
    # Enable AMD GPU monitoring tools
    environment.systemPackages = with pkgs; [
      radeontop  # GPU monitoring
      # rocm-smi is not always available in nixpkgs, so it's commented out
      # If you need ROCm System Management Interface, install it separately or add it to your overlay
    ];
  };
}

