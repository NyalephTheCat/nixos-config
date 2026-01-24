{ config, pkgs, lib, ... }:

let
  cfg = config.features.user.libreoffice or false;
  # Support both bool and attrset with enable, packages, overrides
  enabled = if lib.isBool cfg then cfg else (cfg.enable or false);
  customPackages = if lib.isBool cfg then [] else (cfg.packages or []);
  basePackages = with pkgs; [
    libreoffice-fresh  # Full LibreOffice suite
  ];
  allPackages = basePackages ++ customPackages;
  overrides = if lib.isBool cfg then {} else (cfg.overrides or {});
in
{
  config = lib.mkIf enabled {
    home.packages = allPackages;
    
    # Apply any overrides if provided
    _module.args = lib.mkIf (overrides != {}) {
      libreofficeOverrides = overrides;
    };
  };
}

