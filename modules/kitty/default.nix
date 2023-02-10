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

        sync_to_monitor no
	disable_ligatures never

	enable_audio_bell no
	update_check_interval 0

	map ctrl+shift+q noop
	map ctrl+shift+w noop

	map ctrl+shift+p>n kitten hints --type=linenum --linenum-action=tab nvim +{line} {path}

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

