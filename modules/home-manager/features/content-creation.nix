{ config, pkgs, lib, ... }:

let
  cfg = config.features.user.content-creation or false;
  # Support both bool and attrset with enable, packages, overrides
  enabled = if lib.isBool cfg then cfg else (cfg.enable or false);
  customPackages = if lib.isBool cfg then [] else (cfg.packages or []);
  basePackages = with pkgs; [
    gimp              # Image editing
    inkscape          # Vector graphics
    krita             # Digital painting
    blender           # 3D modeling
    kdenlive          # Video editing
    audacity          # Audio editor
  ];
  allPackages = basePackages ++ customPackages;
  overrides = if lib.isBool cfg then {} else (cfg.overrides or {});
in
{
  config = lib.mkIf enabled {
    home.packages = allPackages;
    
    # Apply any overrides if provided
    _module.args = lib.mkIf (overrides != {}) {
      contentCreationOverrides = overrides;
    };
  };
}

