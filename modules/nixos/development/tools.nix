{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development.tools;
in
{
  options.modules.development.tools = {
    enable = mkEnableOption "development tools";
    
    editors = {
      vscode = mkEnableOption "Visual Studio Code";
      neovim = mkEnableOption "Neovim";
      emacs = mkEnableOption "Emacs";
      jetbrains = mkEnableOption "JetBrains IDEs";
    };
    
    terminal = {
      multiplexers = mkOption {
        type = types.bool;
        default = true;
        description = "Enable terminal multiplexers";
      };
      
      shells = mkOption {
        type = types.bool;
        default = true;
        description = "Enable alternative shells";
      };
    };
    
    networking = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable networking development tools";
      };
    };
    
    monitoring = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable system monitoring tools";
      };
    };
    
    virtualization = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable virtualization tools";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; 
      # Editors
      (optionals cfg.editors.vscode [ vscode ]) ++
      (optionals cfg.editors.neovim [ neovim ]) ++
      (optionals cfg.editors.emacs [ emacs ]) ++
      (optionals cfg.editors.jetbrains [
        jetbrains.idea-community
        jetbrains.pycharm-community
      ]) ++
      
      # Terminal tools
      (optionals cfg.terminal.multiplexers [
        tmux
        screen
        zellij
      ]) ++
      (optionals cfg.terminal.shells [
        zsh
        fish
        nushell
      ]) ++
      
      # Networking tools
      (optionals cfg.networking.enable [
        curl
        wget
        httpie
        xh # Better httpie
        insomnia
        postman
        wireshark
        tcpdump
        nmap
        netcat
        socat
        mtr
        iperf3
        dig
        whois
        openssl
        ngrok
      ]) ++
      
      # Monitoring tools
      (optionals cfg.monitoring.enable [
        htop
        btop
        iotop
        iftop
        nethogs
        ncdu
        duf # Better df
        dust # Better du
        procs # Better ps
        bottom # System monitor
        glances
        s-tui # Stress Terminal UI
      ]) ++
      
      # Virtualization tools
      (optionals cfg.virtualization.enable [
        qemu
        quickemu
        virt-manager
      ]) ++
      
      # General development tools
      [
        # Search and find
        ripgrep
        fd
        fzf
        ack
        silver-searcher
        
        # File manipulation
        jq
        yq
        xan # CSV toolkit
        hexyl # Hex viewer
        binwalk
        
        # Text processing
        bat
        eza # Better ls
        delta # Better diff
        difftastic # Structural diff
        
        # Archive tools
        unzip
        zip
        unrar
        p7zip
        
        # Documentation
        tldr
        cheat
        
        # Benchmarking
        hyperfine
        wrk
        
        # Process management
        killall
        procps # includes pgrep, pkill, etc.
        lsof
        
        # Development utilities
        direnv
        entr # Run commands on file change
        watchexec
        just # Command runner
        mkcert # Local HTTPS certificates
        
        # Terminal recording
        asciinema
        
        # JSON/YAML/TOML tools
        gron # Make JSON greppable
        fx # JSON viewer
        
        # Database clients
        sqlite
        postgresql
        mysql80
        redis
        mongosh
        
        # Cloud tools
        awscli2
        google-cloud-sdk
        azure-cli
        terraform
        packer
        ansible
        
        # Kubernetes tools
        kubectl
        kubernetes-helm
        k9s
        stern # Multi pod log tailing
        kubectx
        
        # API development
        grpcurl
        grpc-tools
        protobuf
        
        # Security tools
        age # Encryption
        sops # Secret management
        gnupg
        pass
        pwgen
        
        # Misc
        tree
        tokei # Code statistics
        onefetch # Git repo info
        neofetch
        glow # Markdown renderer
      ];
    
    # Enable Docker if virtualization is enabled
    virtualisation.docker = mkIf cfg.virtualization.enable {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    
    # Add user to docker group
    users.users.${config.modules.development.user} = mkIf cfg.virtualization.enable {
      extraGroups = [ "docker" ];
    };
  };
}