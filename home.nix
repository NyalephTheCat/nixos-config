{ config, pkgs, isNotWSL, kitty, ... }:

{
  users.users.chloe = {
    isNormalUser = true;
    description = "Chloe";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "video" ];
    packages = [ pkgs.firefox ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  home-manager.users.chloe = { config, pkgs, ... }:
    let
      plateformSpecificPackages =
        if (isNotWSL)
        then with pkgs; [
          # Coding stuff
          vscode
          rustup

          # We are *not* in WSL
          teams
          discord
          clip
          remmina
          
          # Gnome
          gnomeExtensions.dash-to-panel
          gnomeExtensions.night-theme-switcher
          gnomeExtensions.appindicator

          # Hyprland
          libsForQt5.dolphin
          wofi
          waybar
        ]
        else with pkgs; [
          # We *are* in WSL
          wslu
        ];

      commonPackages = with pkgs; [
        any-nix-shell
        file
        fish
	home-manager
	luajit
	luajitPackages.luarocks
	luajitPackages.luasocket
	neofetch
	nodePackages.pyright
	nodePackages.typescript-language-server
	nodePackages.vscode-html-languageserver-bin
	nodePackages.vscode-json-languageserver
	nodePackages.yaml-language-server
        openssh
        powershell
        rnix-lsp
	sqlite
	stylua
	sumneko-lua-language-server
	texlab
	tree
	tree-sitter
        unzip
        xclip
      ];
      emailInfo = builtins.import ./smtpCredentials.nix;
    in
    rec {
      home = {
	username = "chloe";
	homeDirectory = "/home/chloe";
        stateVersion = "22.11"; ######## /!\ DO NOT CHANGE THIS AS IT AVOIDS BREAKAGES
      };

      xdg = {
        enable = true;
	userDirs = {
          enable = true;
          createDirectories = true;
        };
      };

      nixpkgs.config.allowUnfree = true;

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      dconf = {
        enable = isNotWSL;
        settings = {
          "org/gnome/shell".enabled-extensions = [
            "dash-to-panel@jderose9.github.com"
            "nightthemeswitcher-gnome-shell-extension@rmnvgr.gitlab.com"
            "appindicatorsupport@rgcjonas.gmail.com"
          ];
          "org/gnome/desktop/wm/preferences".num-workspaces = 2;
          "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";
          "org/gnome/desktop/wm/keybindings" = {
            switch-applications = "@as []";
            switch-applications-backward = "@as []";
            switch-windows = [ "<Alt>Tab" ];
            switch-windows-backward = [ "<Shift><Alt>Tab" ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Shift><Control>Escape";
            command = "gnome-system-monitor";
            name = "Task Manager";
          };
        };
      };

      home.packages = commonPackages ++ plateformSpecificPackages;

      # Some program config
      programs = {
        bat = {
          enable = true;
	  extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
	};

	direnv = {
          enable = true;
	  nix-direnv.enable = true;
	};
	
	firefox.enable = true;
	
	fish = {
	  enable = true;
	  functions = {
            gitignore = "curl -sL https://www.gitignore.io/api/$argv";
	  };
	  plugins = [];
	  shellInit = builtins.readFile ./fish/shellInit.fish;
	  shellAliases = {
            cls = "clear";
	    cat = "bat";
	    diff = "batdiff";
	    g = "git";
	    gl = "git log";
	    gc = "git commit -m";
	    gca = "git commit -am";
	    gws = "git status";
	    ghauth = "git auth login";
	    man = "batman";
	    nshell = "nix-shell -p";
	    ".." = "cd ..";
	    "..." = "cd ../..";
	  };
	};
	
	fzf = {
          enable = true;
	  enableFishIntegration = true;
	};
	
	gh = {
          enable = true;
	  settings = {
            editor = "nvim";
	    git_protocol = "ssh";
	  };
	};
	
	htop.enable = isNotWSL;
	
	jq.enable = true;
	
	kitty = {
          enable = true;
	  package = kitty;
	  font = {
            name = "FiraCode Nerd Font";
	    size = 16;
	  };
	  settings = {
            copy_on_select = true;
	    enabled_layouts = "*";
	    scollback_lines = 10000;
	  };
	};
	
	navi.enable = true;
       
        neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          # Config in ./neovim/*
        };


	nnn = {
          enable = true;
	  package = pkgs.nnn.override ({ withNerdIcons = true; });
	  extraPackages = with pkgs; [ ffmpegthumbnailer mediainfo sxiv ];
	};
        
	starship = {
          enable = true;
          settings = {
            command_timeout = 1000;
            character = {
              success_symbol = " [λ](bold green)";
              error_symbol = " [λ](bold red)";
            };
          };
        };
	
	tealdeer.enable = true;
	
	vscode = {
          enable = true;
	  extensions = with pkgs.vscode-extensions; [
            davidanson.vscode-markdownlint
	  ];
	  userSettings = {
            editor.fontFamily = "FiraCode Nerd Font";
	    editor.fontSize = 16;
	    telemetry.enableTelemetry = false;
	  };
	};
      };

      services.mpris-proxy.enable = isNotWSL;

      home.sessionVariables = {
        MOZ_WAYLAND =
          if (builtins.getEnv "XDG_SESSION_TYPE" == "wayland" && isNotWSL)
          then 1 else 0;
      };

      home.shellAliases = {
        g = "git";
        "..." = "cd ../..";
      };

      
      programs.git = {
        enable = true;
        aliases = {
          tree = "log --all --decorate --oneline --graph";
          pall = "push --all";
        };
        userEmail = "NyalephTheCat@gmail.com";
        userName = "NyalephTheCat";
        extraConfig = {
          sendemail = emailInfo;
          init.defaultBranch = "main";
        };
        package = pkgs.gitFull;
      };

      programs.gpg = {
        enable = true;
        homedir = "${config.xdg.configHome}/gnupg";
      };

      services.gpg-agent = {
        enable = true;
        pinentryFlavor = "gnome3";
        extraConfig = ''
          allow-loopback-pinentry
        '';
      };
    };

    security.sudo.enable = true;
}

