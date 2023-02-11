{ config, pkgs, inputs, lib, ... }:
with lib;
let cfg = config.modules.gnome;
in
{
  options.modules.gnome = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable gnome.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs.gnomeExtensions; with pkgs; [
      user-themes
      tray-icons-reloaded
      vitals
      dash-to-panel
      sound-output-device-chooser
      space-bar
      palenight-theme
      gnome.gnome-tweaks
      autohide-battery
    ];

    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "firefox.desktop"
	  "org.gnome.Terminal.desktop"
	  "discord.desktop"
	  "kitty.desktop"
	  "org.gnome.Nautilus.desktop"
	];
	disable-user-extensions = false;
	enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
	  "trayIconsReloaded@selfmade.pl"
	  "Vitals@CoreCoding.com"
	  "dash-to-panel@jderose9.github.com"
	  "sound-output-device-chooser@kgshank.net"
	  "space-bar@luchrioh"
	  "autohide-battery@sitnik.ru"
	];
      };
      "org/gnome/shell/extensions/dash-to-panel" = {
	 animate-appicon-hover = true;
	 animate-appicon-hover-animation-extent = "{'RIPPLE':4,'PLANK':4,'SIMPLE':1}";
	 appicon-margin = 8;
	 appicon-padding = 4;
	 dot-color-dominant = true;
	 dot-style-focused = "SOLID";
	 dot-style-unfocused = "METRO";
	 focus-highlight-dominant = true;
	 group-apps = true;
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
	enable-hot-corners = false;
      };
      "org/gnome/desktop/wm/preference" = {
        workspace-names = [ "Main" ];
      };
      "org/gnome/shell/extensions/user-theme" = {
        #name = "palenight";
      };
    };
  };
}
