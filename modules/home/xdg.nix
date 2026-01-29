{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.home.xdg;
in
{
  options.home.xdg = {
    enable = mkEnableOption "XDG directory and MIME type configuration";

    userDirs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable XDG user directories.";
      };

      createDirectories = mkOption {
        type = types.bool;
        default = true;
        description = "Create XDG directories if they don't exist.";
      };

      desktop = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Desktop directory path.";
      };

      documents = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Documents directory path.";
      };

      download = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Download directory path.";
      };

      music = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Music directory path.";
      };

      pictures = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Pictures directory path.";
      };

      videos = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Videos directory path.";
      };

      templates = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Templates directory path.";
      };

      publicShare = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Public share directory path.";
      };
    };

    mimeApps = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable MIME type associations.";
      };

      defaultApplications = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = {};
        description = "Default applications for MIME types.";
        example = {
          "text/plain" = [ "nvim.desktop" ];
          "text/html" = [ "firefox.desktop" ];
        };
      };

      associations = {
        added = mkOption {
          type = types.attrsOf (types.listOf types.str);
          default = {};
          description = "MIME type associations to add.";
        };

        removed = mkOption {
          type = types.attrsOf (types.listOf types.str);
          default = {};
          description = "MIME type associations to remove.";
        };
      };
    };

    configFile = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          text = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "File content as text.";
          };
          source = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "File source path.";
          };
          target = mkOption {
            type = types.str;
            description = "Target file path (relative to XDG config home).";
          };
          executable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether the file should be executable.";
          };
        };
      });
      default = {};
      description = "Additional XDG config files.";
    };

    dataFile = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          text = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          source = mkOption {
            type = types.nullOr types.path;
            default = null;
          };
          target = mkOption {
            type = types.str;
            description = "Target file path (relative to XDG data home).";
          };
        };
      });
      default = {};
      description = "Additional XDG data files.";
    };
  };

  config = mkIf cfg.enable {
    # Note: xdg.userDirs is already provided by Home Manager's built-in module
    # Configure it directly using Home Manager's options if needed

    xdg.mimeApps = mkIf cfg.mimeApps.enable {
      enable = true;
      defaultApplications = cfg.mimeApps.defaultApplications;
      associations = {
        added = cfg.mimeApps.associations.added;
        removed = cfg.mimeApps.associations.removed;
      };
    };

    # Additional config files
    xdg.configFile = lib.mapAttrs' (name: file: {
      name = file.target;
      value = (if file.text != null then { text = file.text; } else {})
        // (if file.source != null then { source = file.source; } else {})
        // { executable = file.executable; };
    }) (lib.filterAttrs (name: file: file.text != null || file.source != null) cfg.configFile);

    # Additional data files
    xdg.dataFile = lib.mapAttrs' (name: file: {
      name = file.target;
      value = (if file.text != null then { text = file.text; } else {})
        // (if file.source != null then { source = file.source; } else {});
    }) (lib.filterAttrs (name: file: file.text != null || file.source != null) cfg.dataFile);
  };
}
