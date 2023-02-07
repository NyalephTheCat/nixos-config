{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.fish;
in
{
  options.modules.discord = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable fish.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fish
      fzf
      grc
    ];

    home.defaultUserShell = pkgs.fish;

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
	set -g fish_key_bindings fist_default_key_bindings
      '';
      plugins = with pkgs.fishPlugins; [
        { 
	  name = "grc"; 
	  src = grc.src;
	}
	{ 
	  name = "z";
	  src = pkgs.fetchFromGithub {
            owner = "jethrokuan;
	    repo = "z";
	  };
	}
	{
          name = "tide";
	  src = tide.src;
	}
	{
          name = "sponge";
	  src = sponge.src;
	}
	{
          name = "puffer";
	  src = puffer.src;
	}
	{
          name = "done";
	  src = done.src;
	}
      ];
    }
  };
}
