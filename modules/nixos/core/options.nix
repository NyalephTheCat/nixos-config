{ lib, ... }:

{
  # Import and define feature options
  # This makes options available via config.features.*
  options.features = {
    # Gaming feature
    gaming = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable gaming optimizations and software";
      };
    };

    # Virtualization features
    virtualization = {
      docker = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Docker containerization";
      };

      libvirt = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable libvirt/QEMU virtualization";
      };
    };

    # Development feature
    development = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable development tools and environments";
      };
    };

    # Desktop environment
    desktop = {
      environment = lib.mkOption {
        type = lib.types.enum [ "plasma" "gnome" "none" ];
        default = "plasma";
        description = "Desktop environment to use";
      };
    };

    # Hardware configuration
    hardware = {
      gpu = lib.mkOption {
        type = lib.types.enum [ "amd" "nvidia" "intel" "none" ];
        default = "none";
        description = "GPU vendor for hardware-specific optimizations";
      };

      type = lib.mkOption {
        type = lib.types.enum [ "desktop" "laptop" ];
        default = "desktop";
        description = "Hardware type for power management";
      };
    };

    # Printing feature
    printing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable printing services (CUPS)";
      };
    };
  };

  # User-level features (for Home Manager)
  options.features.user = {
    gaming-tools = lib.mkOption {
      type = lib.types.either lib.types.bool (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable this feature";
          };
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Additional packages to include with this feature";
          };
          overrides = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Custom overrides for this feature";
          };
        };
      });
      default = false;
      description = "Install gaming-related applications (Discord, etc.)";
    };

    content-creation = lib.mkOption {
      type = lib.types.either lib.types.bool (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable this feature";
          };
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Additional packages to include with this feature";
          };
          overrides = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Custom overrides for this feature";
          };
        };
      });
      default = false;
      description = "Install content creation tools (GIMP, Inkscape, video editors)";
    };

    streaming = lib.mkOption {
      type = lib.types.either lib.types.bool (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable this feature";
          };
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Additional packages to include with this feature";
          };
          overrides = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Custom overrides for this feature";
          };
        };
      });
      default = false;
      description = "Install streaming and recording tools (OBS)";
    };

    development = lib.mkOption {
      type = lib.types.either lib.types.bool (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable this feature";
          };
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Additional packages to include with this feature";
          };
          overrides = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Custom overrides for this feature";
          };
        };
      });
      default = false;
      description = "Install development tools and IDEs";
    };
  };
}

