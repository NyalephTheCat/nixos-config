
{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.zsh;
in
let bat_config = config.modules.bat;
in
{
  options.modules.zsh = {
    enable = mkOption {
     default = true;
     example = true;
     description = "Whether to enable zsh.";
     type = types.bool;
    };

    pretty = mkOption {
      default = true;
      example = true;
      description = "Make it pretty";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pkgs.zsh
      pkgs.exa
    ] ++ optionals cfg.pretty [
      bat
      bat-extras.batman
      bat-extras.batpipe
      bat-extras.batgrep
      bat-extras.batdiff
      bat-extras.batwatch
      bat-extras.prettybat
    ];

    programs.command-not-found = {
      enable = true;
    };

    programs.zsh = {
      enable = true;

      autocd = true;
      dotDir = ".config/zsh";
      enableCompletion = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;

      oh-my-zsh = {
        enable = true;
	plugins = [
	  "command-not-found"
	  "git"
	  "gh"
	  "rust" # Add check to only use if needed
	  "autopep8"
	];
      };

      # .zshrc
      initExtra = ''
      PROMPT="%F{blue}%n@%m %~%b "$'\n'"%(?.%F{green}%Bλ%b |.%F{red}?) %f"
      RPROMPT="[%*]"
      '';

      # basically aliases for directories:
      # `cd ~dots` will cd into ~/.config/nixos
      dirHashes = {
        dots = "$HOME/.config/nixos";
	media = "/run/media/$USER";
	junk = "$HOME/other";
      };

      # Tweak settings for history
      history = {
        save = 1000;
	size = 1000;
	path = "$HOME/.cache/zsh_history";
	ignoreDups = true;
	ignoreSpace = true;
	extended = true;
	share = true;
      };

      # Set some aliases
      shellAliases = {
        c = "clear";
	mkdir = "mkdir -vp";
	rm = "rm -rifv";
	mv = "mv -iv";
	cp = "cp -riv";
	cat = mkIf cfg.pretty "bat";
	man = mkIf cfg.pretty "batman";
	diff = mkIf cfg.pretty "batdiff";
	grep = mkIf cfg.pretty "batgrep";
	watch = mkIf cfg.pretty "batwatch";
	ls = "exa -a --icons";
	tree = "exa --tree --icons";
	nd = "nix develop -c $SHELL";
	ns = "nix-shell -p";
	rebuild = "doas nixos-rebuild switch --flake $NIXOS_CONFIG_DIR";
      };

      # Source all plugins, nix-style
      plugins = with pkgs; [
        {
	  name = "auto-ls";
	  src = pkgs.fetchFromGitHub {
	    owner = "notusknot";
	    repo = "auto-ls";
	    rev = "62a176120b9deb81a8efec992d8d6ed99c2bd1a1";
	    sha256 = "08wgs3sj7hy30x03m8j6lxns8r2kpjahb9wr0s0zyzrmr4xwccj0";
	  };
	}
      ];
    };
  };
}
