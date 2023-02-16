{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.obs;
in
{
  options.modules.obs = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable obs.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.obs-studio ];
  };
}
