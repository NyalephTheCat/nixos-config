{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development.containers;
in
{
  options.modules.development.containers = {
    enable = mkEnableOption "container development tools";
    
    docker = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Docker";
      };
      
      enableOnBoot = mkOption {
        type = types.bool;
        default = true;
        description = "Start Docker on boot";
      };
      
      autoPrune = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable automatic pruning of unused Docker resources";
        };
        
        flags = mkOption {
          type = types.listOf types.str;
          default = ["--all"];
          description = "Flags to pass to docker system prune";
        };
        
        dates = mkOption {
          type = types.str;
          default = "weekly";
          description = "How often to run pruning";
        };
      };
      
      storageDriver = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Docker storage driver to use";
      };
    };
    
    podman = {
      enable = mkEnableOption "Podman container runtime";
      
      dockerCompat = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Docker compatibility";
      };
    };
    
    kubernetes = {
      enable = mkEnableOption "Kubernetes development tools";
      
      minikube = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Minikube";
      };
      
      kind = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Kind (Kubernetes in Docker)";
      };
      
      k3s = mkOption {
        type = types.bool;
        default = false;
        description = "Enable K3s";
      };
    };
    
    tools = {
      compose = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Docker Compose";
      };
      
      buildkit = mkOption {
        type = types.bool;
        default = true;
        description = "Enable BuildKit";
      };
      
      registry = mkOption {
        type = types.bool;
        default = false;
        description = "Enable local Docker registry";
      };
    };
  };

  config = mkIf cfg.enable {
    # Docker configuration
    virtualisation.docker = mkIf cfg.docker.enable {
      enable = true;
      enableOnBoot = cfg.docker.enableOnBoot;
      storageDriver = cfg.docker.storageDriver;
      autoPrune = {
        enable = cfg.docker.autoPrune.enable;
        flags = cfg.docker.autoPrune.flags;
        dates = cfg.docker.autoPrune.dates;
      };
      
      daemon.settings = {
        features = {
          buildkit = cfg.tools.buildkit;
        };
        
        # Better performance settings
        max-concurrent-downloads = 10;
        max-concurrent-uploads = 5;
        
        # Logging
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
      };
    };
    
    # Podman configuration
    virtualisation.podman = mkIf cfg.podman.enable {
      enable = true;
      dockerCompat = cfg.podman.dockerCompat;
      defaultNetwork.settings.dns_enabled = true;
    };
    
    # Container tools
    environment.systemPackages = with pkgs; 
      # Docker tools
      (optionals cfg.docker.enable [
        docker-client
        docker-buildx
      ]) ++
      
      # Podman tools
      (optionals cfg.podman.enable [
        podman-compose
        podman-tui
      ]) ++
      
      # Compose tools
      (optionals cfg.tools.compose [
        docker-compose
        lazydocker # Docker TUI
      ]) ++
      
      # Kubernetes tools
      (optionals cfg.kubernetes.enable [
        kubectl
        kubernetes-helm
        helmfile
        kustomize
        kubeseal
        telepresence2
        tilt
        skaffold
        kompose # Convert docker-compose to k8s
      ]) ++
      (optionals cfg.kubernetes.minikube [ minikube ]) ++
      (optionals cfg.kubernetes.kind [ kind ]) ++
      
      # Container management tools
      [
        dive # Explore docker images
        skopeo # Work with remote images
        crane # Container registry tool
        regctl # Registry client
        cosign # Container signing
        trivy # Vulnerability scanner
        grype # Vulnerability scanner
        syft # SBOM generator
        hadolint # Dockerfile linter
        docker-slim # Optimize containers
        ctop # Container metrics
        oxker # Docker TUI
      ] ++
      
      # Build tools
      (optionals cfg.tools.buildkit [
        buildkit
        nerdctl # Docker-compatible CLI for containerd
      ]) ++
      
      # Registry tools
      (optionals cfg.tools.registry [
        docker-registry
        docker-registry-frontend
      ]);
    
    # Add user to necessary groups
    users.users.${config.modules.development.user} = {
      extraGroups = 
        (optionals cfg.docker.enable [ "docker" ]) ++
        (optionals cfg.podman.enable [ "podman" ]);
    };
    
    # System settings for containers
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = mkIf (cfg.docker.enable || cfg.podman.enable) 1;
    };
    
    # Enable k3s if requested
    services.k3s = mkIf cfg.kubernetes.k3s {
      enable = true;
      role = "server";
    };
    
    # Local registry
    services.dockerRegistry = mkIf cfg.tools.registry {
      enable = true;
      port = 5000;
      enableDelete = true;
      enableGarbageCollect = true;
    };
  };
}