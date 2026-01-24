{ lib, inputs, ... }:

let
  # Import package utilities
  packageUtils = import ./packages.nix { inherit lib; };
  
  # Import host utilities
  hostUtils = import ./host.nix { inherit lib; };
  
  # Import validation utilities
  validationUtils = import ./validation.nix { inherit lib; };
  
  # Helper to extract enable state from feature config (bool or attrset)
  isFeatureEnabled = feature:
    if lib.isBool feature then feature else (feature.enable or false);

  # Helper to get packages from feature config
  getFeaturePackages = feature:
    if lib.isBool feature then [] else (feature.packages or []);

  # Helper to get overrides from feature config
  getFeatureOverrides = feature:
    if lib.isBool feature then {} else (feature.overrides or {});

  # Feature presets
  featurePresets = {
    "gaming-desktop" = {
      gaming.enable = true;
      desktop.environment = "plasma";
      hardware.type = "desktop";
    };
    "development-laptop" = {
      development.enable = true;
      desktop.environment = "gnome";
      hardware.type = "laptop";
    };
    "minimal-server" = {
      desktop.environment = "none";
      gaming.enable = false;
      development.enable = false;
    };
  };
in

{
  # Re-export package utilities
  inherit (packageUtils)
    overridePackageAttrs
    overridePackageDeps
    mergePackageLists
    filterPackagesByName
    filterPackagesByPath
    getPackagesFromAttrs
    createPackageSet
    overridePackages
    addBuildInputs
    addNativeBuildInputs
    setPackageEnv
    patchPackage
    changePackageSource
    mkPackageSet
    filterPackagesByArch
    getPackageVersion
    mergeConfigs
    applyDefaults
    sanitizeConfig;
  
  # Re-export host utilities
  inherit (hostUtils)
    defaultHostConfig
    mergeHostConfig
    hostConfigType
    hardwarePresets
    getHardwareModules
    isValidSystem
    getDefaultNixpkgsConfig;
  
  # Re-export validation utilities
  inherit (validationUtils)
    validateFeatureConfig
    validateHostConfig
    checkRequiredOptions
    validateFeatureDependencies
    detectFeatureConflicts;
  # Helper function to create a NixOS system configuration
  # Note: This function expects paths to be passed in, as path resolution
  # depends on the context where it's called from (flake.nix)
  mkHost = { hostname, system ? "x86_64-linux", users ? [], hostConfigPath, hardwareConfigPath, featuresPath ? null, userConfigPaths, modules ? [] }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { 
        inherit inputs; 
        # Use standard NixOS lib - don't extend it to avoid issues with Home Manager's internal modules
        # Home Manager's internal modules (like mako) expect the standard NixOS lib
        # If NixOS modules need Home Manager's lib, they can access it via inputs.home-manager.lib.hm
      };
      modules = [
        # Home Manager integration
        # Note: We use standard lib for NixOS modules to avoid issues with Home Manager's internal modules
        # Home Manager user modules can access Home Manager's lib via extraSpecialArgs if needed
        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { 
              inherit inputs; 
              # Pass Home Manager's lib to user modules if they need it
              # User modules can access it via the lib parameter (which will be Home Manager's lib in their context)
              # or via inputs.home-manager.lib.hm
            };
            # Backup existing files before Home Manager overwrites them
            backupFileExtension = "backup";
            # Import user configurations for each user on this host
            users = userConfigPaths;
          };
        }
        
        # Host-specific configuration
        hostConfigPath
        hardwareConfigPath
      ] ++ lib.optional (featuresPath != null) featuresPath
        ++ modules;
    };

  # Helper to enable/disable features conditionally
  mkFeature = { enable ? false, config }:
    lib.mkIf enable config;

  # Helper to merge user packages
  mkUserPackages = { base ? [], optional ? [] }:
    base ++ optional;

  # Helper to create user configuration with defaults
  mkUser = { username, fullName, email, shell ? "zsh", extraGroups ? [], features ? {} }:
    {
      isNormalUser = true;
      description = fullName;
      inherit extraGroups;
      home = "/home/${username}";
    };

  # Helper for conditional imports based on feature flags
  importIfEnabled = feature: path:
    lib.optional feature path;

  # Helper to merge feature configs (useful for extending features)
  mergeFeatureConfig = base: override:
    if lib.isBool base && lib.isBool override then override
    else if lib.isBool base then override
    else if lib.isBool override then { enable = override; }
    else lib.recursiveUpdate base override;

  # Service configuration helpers
  
  # Enable a service with common settings
  # Usage: mkService { name = "myService"; enable = true; user = "myuser"; }
  mkService = { name, enable ? true, user ? null, description ? null, execStart ? null, ... }@attrs:
    lib.mkIf enable {
      systemd.services.${name} = {
        enable = true;
        description = if description != null then description else name;
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
        } // lib.optionalAttrs (user != null) {
          User = user;
        } // lib.optionalAttrs (execStart != null) {
          ExecStart = execStart;
        } // (attrs.serviceConfig or {});
      } // lib.optionalAttrs (attrs.after != null) {
        after = attrs.after;
      } // lib.optionalAttrs (attrs.wants != null) {
        wants = attrs.wants;
      };
    };
  
  # Create a timer service
  # Usage: mkTimer { name = "myTimer"; onCalendar = "daily"; serviceConfig = { ... }; }
  mkTimer = { name, onCalendar, enable ? true, ... }@attrs:
    lib.mkIf enable {
      systemd.timers.${name} = {
        enable = true;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = onCalendar;
        } // (attrs.timerConfig or {});
      };
      systemd.services.${name} = attrs.serviceConfig or {};
    };
  
  # Enhanced feature flag utilities
  
  # Check if feature is enabled (supports bool or attrset)
  checkFeature = isFeatureEnabled;
  
  # Get feature configuration with defaults
  # Usage: getFeatureConfig feature { enable = false; packages = []; }
  getFeatureConfig = feature: defaults:
    if lib.isBool feature
    then lib.recursiveUpdate defaults { enable = feature; }
    else lib.recursiveUpdate defaults feature;
  
  # Apply feature-based package list
  # Usage: applyFeaturePackages feature basePackages
  applyFeaturePackages = feature: basePackages:
    if isFeatureEnabled feature
    then basePackages ++ getFeaturePackages feature
    else basePackages;
  
  # Apply feature-based configuration overrides
  # Usage: applyFeatureOverrides feature baseConfig
  applyFeatureOverrides = feature: baseConfig:
    if isFeatureEnabled feature
    then lib.recursiveUpdate baseConfig (getFeatureOverrides feature)
    else baseConfig;

  # Feature dependency helpers
  
  # Check if feature dependencies are met
  # Usage: checkFeatureDependencies config { gaming = [ "desktop" ]; }
  checkFeatureDependencies = config: dependencies:
    let
      getFeatureValue = path:
        lib.attrByPath (lib.splitString "." path) false config;
      checkDependency = feature: deps:
        let
          featureEnabled = getFeatureValue feature;
          depsEnabled = map getFeatureValue deps;
        in
        if featureEnabled
        then lib.all (x: x) depsEnabled
        else true;
    in
    lib.all (name: checkDependency name dependencies.${name}) (lib.attrNames dependencies);
  
  # Warn about missing feature dependencies
  # Usage: warnFeatureDependencies config { gaming = [ "desktop.environment" ]; }
  warnFeatureDependencies = config: dependencies:
    let
      getFeatureValue = path:
        lib.attrByPath (lib.splitString "." path) false config;
      checkDependency = feature: deps:
        let
          featureEnabled = getFeatureValue feature;
          missingDeps = lib.filter (dep: !(getFeatureValue dep)) deps;
        in
        if featureEnabled && missingDeps != []
        then lib.warn "Feature '${feature}' requires: ${lib.concatStringsSep ", " missingDeps}" null
        else null;
    in
    lib.forEach (lib.attrNames dependencies) (name: checkDependency name dependencies.${name});
  
  # Feature presets
  # Usage: applyFeaturePreset config "gaming-desktop"
  applyFeaturePreset = config: presetName:
    let preset = featurePresets.${presetName} or {};
    in lib.recursiveUpdate config preset;

  # Additional service helpers
  
  # Create a user systemd service
  # Usage: mkUserService { name = "myService"; user = "myuser"; execStart = "..."; }
  # Note: This requires pkgs to be available in the calling context
  mkUserService = { name, user, enable ? true, description ? null, execStart, pkgs, ... }@attrs:
    lib.mkIf enable {
      systemd.user.services.${name} = {
        enable = true;
        description = if description != null then description else name;
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
        } // lib.optionalAttrs (execStart != null) {
          ExecStart = execStart;
        } // (attrs.serviceConfig or {});
      } // lib.optionalAttrs (attrs.after != null) {
        after = attrs.after;
      } // lib.optionalAttrs (attrs.wants != null) {
        wants = attrs.wants;
      };
    };
  
  # Create a oneshot service helper
  # Usage: mkOneshotService { name = "myService"; script = "..."; pkgs = pkgs; }
  # Note: This requires pkgs to be available in the calling context
  mkOneshotService = { name, enable ? true, script, user ? null, description ? null, pkgs, ... }@attrs:
    lib.mkIf enable {
      systemd.services.${name} = {
        enable = true;
        description = if description != null then description else name;
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        } // lib.optionalAttrs (user != null) {
          User = user;
        } // lib.optionalAttrs (script != null) {
          ExecStart = "${pkgs.writeShellScript "${name}-script" script}";
        } // (attrs.serviceConfig or {});
      };
    };
  
  # Create a timer service (combines timer + service)
  # Usage: mkTimerService { name = "myTimer"; onCalendar = "daily"; serviceConfig = { ExecStart = "..."; }; }
  mkTimerService = { name, onCalendar, enable ? true, serviceConfig, ... }@attrs:
    lib.mkIf enable {
      systemd.timers.${name} = {
        enable = true;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = onCalendar;
        } // (attrs.timerConfig or {});
      };
      systemd.services.${name} = serviceConfig;
    };
}

