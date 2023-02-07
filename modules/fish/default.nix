{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.fish;
in
{
  options.modules.fish = {
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
      oh-my-fish
      fzf
      grc
    ];

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
	set -g fish_key_bindings fish_default_key_bindings
      '';
      shellInit = builtins.readFile ./shellinit.fish;
      plugins = with pkgs.fishPlugins; [
        { 
	  name = "grc"; 
	  src = grc.src;
	}
	{ 
	  name = "z";
	  src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
	    repo = "z";
	    rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
	    sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
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
    };
  };
}
