{ config, pkgs, inputs, lib, ... }:
with lib;
let cfg = config.modules.gnome;
in
{
  options.modules.gnome = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable gnome.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
  };
}
