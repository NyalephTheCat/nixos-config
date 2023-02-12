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

	# vim:ft=kitty

	## name: Tokyo Night
	## license: MIT
	## author: Folke Lemaitre
	## upstream: https://github.com/folke/tokyonight.nvim/raw/main/extras/kitty/tokyonight_night.conf


	background #1a1b26
	foreground #c0caf5
	selection_background #33467c
	selection_foreground #c0caf5
	url_color #73daca
	cursor #c0caf5
	cursor_text_color #1a1b26

	# Tabs
	active_tab_background #7aa2f7
	active_tab_foreground #16161e
	inactive_tab_background #292e42
	inactive_tab_foreground #545c7e
	#tab_bar_background #15161e

	# Windows
	active_border_color #7aa2f7
	inactive_border_color #292e42

	# normal
	color0 #15161e
	color1 #f7768e
	color2 #9ece6a
	color3 #e0af68
	color4 #7aa2f7
	color5 #bb9af7
	color6 #7dcfff
	color7 #a9b1d6

	# bright
	color8 #414868
	color9 #f7768e
	color10 #9ece6a
	color11 #e0af68
	color12 #7aa2f7
	color13 #bb9af7
	color14 #7dcfff
	color15 #c0caf5

	# extended colors
	color16 #ff9e64
	color17 #db4b4b
      '';
      font = {
        package = (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; });
	name = "FiraCode Nerd Font";
	size = 16;
      };
    };
  };
}

