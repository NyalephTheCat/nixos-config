{ lib, ... }:

with lib;

let
  # Type for features that can be either a bool or an attrset with enable, packages, overrides
  featureType = types.either types.bool (types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable this feature";
      };
      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Additional packages to include with this feature";
      };
      overrides = mkOption {
        type = types.attrs;
        default = {};
        description = "Custom overrides for this feature (module-specific)";
      };
    };
  });
in

{
  # Custom options for host features
  hostFeatures = {
    gaming = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable gaming optimizations and software";
      };
    };
    
    virtualization = {
      docker = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Docker containerization";
      };
      
      libvirt = mkOption {
        type = types.bool;
        default = false;
        description = "Enable libvirt/QEMU virtualization";
      };
    };
    
    development = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable development tools and environments";
      };
    };
    
    desktop = {
      environment = mkOption {
        type = types.enum [ "plasma" "gnome" "none" ];
        default = "plasma";
        description = "Desktop environment to use";
      };
    };
    
    hardware = {
      gpu = mkOption {
        type = types.enum [ "amd" "nvidia" "intel" "none" ];
        default = "amd";
        description = "GPU vendor for hardware-specific optimizations";
      };
      
      type = mkOption {
        type = types.enum [ "desktop" "laptop" ];
        default = "desktop";
        description = "Hardware type for power management";
      };
    };
    
    printing = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable printing services (CUPS)";
      };
    };
  };

  # Custom options for user features
  # These support both simple bool and complex attrset with enable, packages, overrides
  userFeatures = {
    gaming-tools = mkOption {
      type = featureType;
      default = false;
      description = ''
        Install gaming-related applications (Discord, etc.).
        Can be a bool or an attrset:
        - bool: true/false to enable/disable
        - attrset: { enable = true; packages = [...]; overrides = {...}; }
      '';
    };
    
    content-creation = mkOption {
      type = featureType;
      default = false;
      description = ''
        Install content creation tools (GIMP, Inkscape, video editors).
        Can be a bool or an attrset:
        - bool: true/false to enable/disable
        - attrset: { enable = true; packages = [...]; overrides = {...}; }
      '';
    };
    
    streaming = mkOption {
      type = featureType;
      default = false;
      description = ''
        Install streaming and recording tools (OBS).
        Can be a bool or an attrset:
        - bool: true/false to enable/disable
        - attrset: { enable = true; packages = [...]; overrides = {...}; }
      '';
    };
    
    development = mkOption {
      type = featureType;
      default = false;
      description = ''
        Install development tools and IDEs.
        Can be a bool or an attrset:
        - bool: true/false to enable/disable
        - attrset: { enable = true; packages = [...]; overrides = {...}; }
      '';
    };
  };

  # Host configuration options
  host = {
    system = mkOption {
      type = types.str;
      default = "x86_64-linux";
      description = "System architecture for this host";
      example = "aarch64-linux";
    };
    
    nixpkgs = {
      allowUnfree = mkOption {
        type = types.bool;
        default = true;
        description = "Allow unfree packages in nixpkgs";
      };
      
      permittedInsecurePackages = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of insecure package names to allow";
        example = [ "openssl-1.0.2" ];
      };
      
      config = mkOption {
        type = types.attrs;
        default = {};
        description = "Additional nixpkgs configuration options";
      };
    };
    
    overlays = mkOption {
      type = types.listOf types.unspecified;
      default = [];
      description = "Additional overlays to apply for this host";
      example = [ (final: prev: { myPackage = prev.myPackage.overrideAttrs (old: { ... }); }) ];
    };
    
    hardwareModules = mkOption {
      type = types.listOf types.unspecified;
      default = [];
      description = "nixos-hardware modules to enable for this host";
      example = [ "common-cpu-amd" "common-gpu-amd" ];
    };
  };

  # Package override options
  packageOverrides = mkOption {
    type = types.attrsOf types.unspecified;
    default = {};
    description = ''
      Per-host package overrides.
      Keys are package names, values are override functions or attribute sets.
      
      Example:
      packageOverrides = {
        git = old: old.overrideAttrs (attrs: { version = "custom"; });
        vim = { enablePython3 = true; };
      };
    '';
  };
}

