{ config, pkgs, lib, customUtils, ... }:

let
  baseModule = (customUtils.mkSimpleEmulator {
    name = "retroarch";
    defaultPackage = pkgs.retroarch-full;
    description = "RetroArch";
    packageName = "retroarch-full";
    packageExample = "pkgs.retroarch";
    extraOptions = {
      cores = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional RetroArch cores to install.";
        example = lib.literalExpression "[ pkgs.libretro.mgba pkgs.libretro.snes9x ]";
      };
    };
  }) { inherit config pkgs lib; };
in
baseModule // {
  config = baseModule.config // {
    home.packages = lib.mkIf config.emulators.retroarch.enable
      ([ config.emulators.retroarch.package ]
       ++ config.emulators.retroarch.cores
       ++ config.emulators.retroarch.extraPackages);
  };
}
