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
    programs.kitty = {
      enable = true;
      settings = literalExpression ''
	scrollback_lines 10000

	enable_audio_bell false
	update_check_interval 0

	window_margin_width 8
	single_window_margin_width 8

	disable_ligatures never

	tab_bar_edge bottom
	tab_bar_style slant
	tab_bar_align left
	tab_bar_min_tabs 2

	shell .
	editor .
      '';
      theme = "Ayu Mirage";
      font = {
        package = (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; });
	name = "FiraCode Nerd Font";
	size = 16;
      };
    };
  };
}

