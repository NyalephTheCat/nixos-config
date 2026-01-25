{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.applications.obs;
in
{
  options.applications.obs = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable OBS Studio.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.obs-studio;
      defaultText = "pkgs.obs-studio";
      description = "The OBS Studio package to use.";
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.obs-studio-plugins.obs-vaapi ];
      defaultText = "[ pkgs.obs-studio-plugins.obs-vaapi ]";
      description = "List of OBS Studio plugins to install.";
      example = "[ pkgs.obs-studio-plugins.obs-vaapi pkgs.obs-studio-plugins.wlrobs ]";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install alongside OBS Studio.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ cfg.plugins ++ cfg.extraPackages;
  };
}

