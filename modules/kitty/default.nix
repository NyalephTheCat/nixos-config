{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.kitty;
in
{
  options.modules.kitty = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable kitty.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ 
      pkgs.kitty
    ];
  };
}
