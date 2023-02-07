{ lib, config, pkgs, ... }:
with lib;
let cfg = config.modules.nvim;
in
{
  options.modules.nvim = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable neovim.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables.EDITOR = "nvim";
    
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;

      extraPackages = with pkgs; [
        yaml-language-server
        rnix-lsp nil # TODO move this to own optionals
      ];

      plugins = with pkgs.vimPlugins; [
        # TODO configure plugins here
      ];

      extraConfig = ''
      '';
    };
  };
}
