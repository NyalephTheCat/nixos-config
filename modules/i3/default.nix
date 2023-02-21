{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.i3;
in
{
  options.modules.i3 = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable i3.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.i3-gaps ];
  };
}
