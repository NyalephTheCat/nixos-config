{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development;
in
{
  imports = [
    ./languages.nix
    ./tools.nix
    ./containers.nix
    ./databases.nix
  ];

  options.modules.development = {
    enable = mkEnableOption "development environment";
    
    user = mkOption {
      type = types.str;
      default = "nyaleph";
      description = "User to configure development environment for";
    };
  };

  config = mkIf cfg.enable {
    # Enable common development features
    programs.git.enable = true;
    
    # Common development packages
    environment.systemPackages = with pkgs; [
      # Version control
      git
      git-lfs
      gh
      lazygit
      
      # Basic tools
      gnumake
      cmake
      gcc
      binutils
      pkg-config
      
      # Debugging
      gdb
      strace
      ltrace
      valgrind
      
      # Performance analysis
      perf-tools
      hyperfine
      
      # Documentation
      man-pages
      man-pages-posix
    ];
    
    # Development-friendly system settings
    boot.kernel.sysctl = {
      # Allow more watches for development tools
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 512;
      
      # Better performance for development
      "vm.max_map_count" = mkDefault 262144;
    };
    
    # Enable documentation
    documentation = {
      enable = true;
      dev.enable = true;
      man.enable = true;
      info.enable = true;
    };
  };
}