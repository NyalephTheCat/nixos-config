{ lib, ... }:

{
  # Default host configuration
  # This provides sensible defaults for host configuration
  defaultHostConfig = {
    system = "x86_64-linux";
    users = [];
    nixpkgsConfig = {
      allowUnfree = true;
      permittedInsecurePackages = [];
    };
    hardwareModules = [];
    extraModules = [];
  };

  # Merge host configuration with defaults
  # Usage: mergeHostConfig { system = "aarch64-linux"; users = [ "user1" ]; }
  mergeHostConfig = config:
    lib.recursiveUpdate defaultHostConfig config;

  # Create host configuration type
  # This can be used in option definitions for type checking
  hostConfigType = lib.types.submodule {
    options = {
      system = lib.mkOption {
        type = lib.types.str;
        default = "x86_64-linux";
        description = "System architecture (e.g., x86_64-linux, aarch64-linux)";
      };
      
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of users for this host";
      };
      
      nixpkgsConfig = lib.mkOption {
        type = lib.types.attrs;
        default = {
          allowUnfree = true;
          permittedInsecurePackages = [];
        };
        description = "Nixpkgs configuration for this host";
      };
      
      hardwareModules = lib.mkOption {
        type = lib.types.listOf lib.types.unspecified;
        default = [];
        description = "nixos-hardware modules to enable for this host";
      };
      
      extraModules = lib.mkOption {
        type = lib.types.listOf lib.types.unspecified;
        default = [];
        description = "Additional NixOS modules to include";
      };
    };
  };

  # Common hardware module presets
  hardwarePresets = {
    # AMD CPU and GPU
    amdDesktop = [
      # These would be imported from nixos-hardware
      # nixos-hardware.nixosModules.common-cpu-amd
      # nixos-hardware.nixosModules.common-gpu-amd
    ];
    
    # NVIDIA GPU
    nvidiaDesktop = [
      # nixos-hardware.nixosModules.common-gpu-nvidia
    ];
    
    # Intel CPU with integrated graphics
    intelLaptop = [
      # nixos-hardware.nixosModules.common-cpu-intel
      # nixos-hardware.nixosModules.common-pc-laptop
    ];
    
    # Generic laptop
    genericLaptop = [
      # nixos-hardware.nixosModules.common-pc-laptop
    ];
  };

  # Helper to get hardware modules from preset name
  # Usage: getHardwareModules "amdDesktop"
  getHardwareModules = presetName:
    hardwarePresets.${presetName} or [];

  # Validate system architecture
  # Returns true if system is supported
  isValidSystem = system:
    lib.elem system [
      "x86_64-linux"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

  # Get default nixpkgs config for a system
  # Can be extended with system-specific defaults
  getDefaultNixpkgsConfig = system: {
    allowUnfree = true;
    permittedInsecurePackages = [];
  };
}

