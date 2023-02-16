{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.docker;
in
{
  options.modules.docker = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable docker.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.docker ];
  };
}
