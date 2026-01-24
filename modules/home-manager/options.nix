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
  # Custom options for user features
  # These support both simple bool and complex attrset with enable, packages, overrides
  options.features.user = {
    gaming-tools = mkOption {
      type = featureType;
      default = true;
      description = ''
        Install gaming-related applications (Discord, etc.).
        Can be a bool or an attrset:
        - bool: true/false to enable/disable
        - attrset: { enable = true; packages = [...]; overrides = {...}; }
      '';
    };
    
    content-creation = mkOption {
      type = featureType;
      default = true;
      description = ''
        Install content creation tools (GIMP, Inkscape, video editors).
        Can be a bool or an attrset:
        - bool: true/false to enable/disable
        - attrset: { enable = true; packages = [...]; overrides = {...}; }
      '';
    };
    
    streaming = mkOption {
      type = featureType;
      default = true;
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
    
    libreoffice = mkOption {
      type = featureType;
      default = true;
      description = ''
        Install LibreOffice office suite.
        Can be a bool or an attrset:
        - bool: true/false to enable/disable
        - attrset: { enable = true; packages = [...]; overrides = {...}; }
      '';
    };
  };
}

