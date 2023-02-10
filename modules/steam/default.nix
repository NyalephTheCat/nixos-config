{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.steam;
in
{
  options.modules.steam = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable steam.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.steam ];
  };
}
