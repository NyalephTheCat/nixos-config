{ config, pkgs, lib, ... }:

let
  cfg = config.features.user.development or false;
  # Support both bool and attrset with enable, packages, overrides
  enabled = if lib.isBool cfg then cfg else (cfg.enable or false);
  customPackages = if lib.isBool cfg then [] else (cfg.packages or []);
  basePackages = with pkgs; [
    # IDEs and editors
    vscode
    # Language tools are typically installed via development feature at system level
    # Add user-specific development tools here
  ];
  allPackages = basePackages ++ customPackages;
  overrides = if lib.isBool cfg then {} else (cfg.overrides or {});
in
{
  config = lib.mkIf enabled {
    home.packages = allPackages;
    
    # Apply any overrides if provided
    _module.args = lib.mkIf (overrides != {}) {
      developmentOverrides = overrides;
    };
  };
}

