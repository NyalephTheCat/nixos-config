{ lib, config, pkgs, ... }:
with lib;
let cfg = config.modules.thunderbird;
in
{
  options.modules.thunderbird = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable thunderbird.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.thunderbird ];
  };
}
