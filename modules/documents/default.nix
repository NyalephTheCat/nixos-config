{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.documents;
in
{
  options.modules.documents = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable documents.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ libreoffice inkscape xournalpp ];
  };
}
