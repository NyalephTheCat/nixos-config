/**
  Utility library for NixOS and Home Manager configurations.

  This library provides helper functions for:
  - Creating application and emulator modules with less boilerplate
  - Package management and validation
  - Configuration merging and manipulation
  - List and attribute set utilities
  - Type-safe option creation

  Usage:
    In your flake.nix:
      lib = import ./lib/utils.nix { inherit pkgs; };

    Then use the functions in your modules or flake outputs.
*/
{ pkgs, lib ? pkgs.lib, ... }:

rec {
  # ============================================================================
  # Application/Emulator Module Helpers
  # ============================================================================

  /**
    Create a simple application module with standard options.

    Example:
      mkSimpleApp {
        name = "cursor";
        defaultPackage = pkgs.cursor;
        description = "Cursor IDE";
        packageName = "cursor";  # For defaultText
        packageExample = "pkgs.cursor";  # Optional example
      }
  */
  mkSimpleApp = { name, defaultPackage, description, packageName ? name, packageExample ? null, extraOptions ? {}, extraConfig ? {} }:
    { config, pkgs, lib, ... }:
    with lib;
    let
      packageOption = {
        type = types.package;
        default = defaultPackage;
        defaultText = literalExpression "pkgs.${packageName}";
        description = "The ${description} package to use.";
      } // (if packageExample != null then { example = literalExpression packageExample; } else {});
    in
    {
      options.applications.${name} = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable ${description}.";
        };

        package = mkOption packageOption;

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [];
          description = "Additional packages to install alongside ${description}.";
        };
      } // extraOptions;

      config = mkIf config.applications.${name}.enable {
        home.packages = [ config.applications.${name}.package ] ++ config.applications.${name}.extraPackages;
      } // extraConfig;
    };

  /**
    Create a simple emulator module with standard options.

    Example:
      mkSimpleEmulator {
        name = "dolphin";
        defaultPackage = pkgs.dolphin-emu;
        description = "Dolphin (GameCube/Wii)";
        packageName = "dolphin-emu";  # For defaultText
      }
  */
  mkSimpleEmulator = { name, defaultPackage, description, packageName ? name, packageExample ? null, extraOptions ? {}, extraConfig ? {} }:
    { config, pkgs, lib, ... }:
    with lib;
    let
      packageOption = {
        type = types.package;
        default = defaultPackage;
        defaultText = literalExpression "pkgs.${packageName}";
        description = "The ${description} package to use.";
      } // (if packageExample != null then { example = literalExpression packageExample; } else {});
    in
    {
      options.emulators.${name} = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable ${description}.";
        };

        package = mkOption packageOption;

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [];
          description = "Additional packages to install alongside ${description}.";
        };
      } // extraOptions;

      config = mkIf config.emulators.${name}.enable {
        home.packages = [ config.emulators.${name}.package ] ++ config.emulators.${name}.extraPackages;
      } // extraConfig;
    };

  /**
    Create multiple simple application modules at once.

    Example:
      mkMultipleApps [
        { name = "discord"; defaultPackage = pkgs.discord; description = "Discord"; }
        { name = "cursor"; defaultPackage = pkgs.cursor; description = "Cursor IDE"; }
      ]
  */
  mkMultipleApps = apps:
    { config, pkgs, lib, ... }:
    let
      modules = map (app: (mkSimpleApp app) { inherit config pkgs lib; }) apps;
      mergedOptions = lib.foldl' (acc: mod: lib.recursiveUpdate acc (mod.options or {})) {} modules;
      # Use mkMerge to properly merge configs (Home Manager will merge lists correctly)
      mergedConfig = lib.mkMerge (map (mod: mod.config or {}) modules);
    in
    {
      options = mergedOptions;
      config = mergedConfig;
    };

  /**
    Create multiple simple emulator modules at once.

    Example:
      mkMultipleEmulators [
        { name = "dolphin"; defaultPackage = pkgs.dolphin-emu; description = "Dolphin"; packageName = "dolphin-emu"; }
        { name = "yuzu"; defaultPackage = pkgs.yuzu; description = "Yuzu (Switch)"; }
      ]
  */
  mkMultipleEmulators = emulators:
    { config, pkgs, lib, ... }:
    let
      modules = map (emu: (mkSimpleEmulator emu) { inherit config pkgs lib; }) emulators;
      mergedOptions = lib.foldl' (acc: mod: lib.recursiveUpdate acc (mod.options or {})) {} modules;
      mergedConfig = lib.foldl' (acc: mod: lib.recursiveUpdate acc (mod.config or {})) {} modules;
    in
    {
      options = mergedOptions;
      config = mergedConfig;
    };

  # ============================================================================
  # Package Utilities
  # ============================================================================

  /**
    Safely get a package from pkgs, returning null if not found.
    
    Example:
      getPackage "firefox" pkgs  # Returns pkgs.firefox or null
  */
  getPackage = name: pkgs.${name} or null;

  /**
    Get multiple packages, filtering out nulls.
    
    Example:
      getPackages [ "firefox" "chromium" "nonexistent" ] pkgs
      # Returns [ pkgs.firefox pkgs.chromium ]
  */
  getPackages = names: builtins.filter (p: p != null) (map (name: getPackage name) names);

  /**
    Check if a package exists in pkgs.
    
    Example:
      hasPackage "firefox" pkgs  # Returns true or false
  */
  hasPackage = name: builtins.hasAttr name pkgs;

  /**
    Get package with fallback.
    
    Example:
      getPackageWithFallback "firefox-wayland" "firefox" pkgs
      # Returns pkgs.firefox-wayland if exists, otherwise pkgs.firefox
  */
  getPackageWithFallback = preferred: fallback:
    if hasPackage preferred then pkgs.${preferred} else pkgs.${fallback};

  # ============================================================================
  # Configuration Utilities
  # ============================================================================

  /**
    Deep merge configurations, with user config taking precedence.
    
    Example:
      mergeConfigsDeep {
        host = { a = { b = 1; c = 2; }; };
        user = { a = { b = 3; }; };
      }
      # Returns { a = { b = 3; c = 2; }; }
  */
  mergeConfigsDeep = host: user:
    lib.recursiveUpdate host user;

  /**
    Merge application configurations, with user config taking precedence.
    
    Example:
      mergeAppConfigs { firefox.enable = true; } { firefox.package = pkgs.firefox-wayland; }
  */
  mergeAppConfigs = hostApps: userApps:
    lib.recursiveUpdate hostApps userApps;

  /**
    Filter enabled applications from a configuration.
    
    Example:
      enabledApps { firefox.enable = true; steam.enable = false; }
      # Returns { firefox = { enable = true; }; }
  */
  enabledApps = apps:
    lib.filterAttrs (name: config: config.enable or false) apps;

  /**
    Get list of enabled application names.
    
    Example:
      enabledAppNames { firefox.enable = true; steam.enable = false; }
      # Returns [ "firefox" ]
  */
  enabledAppNames = apps:
    lib.attrNames (enabledApps apps);

  # ============================================================================
  # Host/User Configuration Helpers
  # ============================================================================

  /**
    Create a host configuration structure.
    
    Example:
      mkHostConfig {
        hostname = "my-pc";
        system = "x86_64-linux";
        modules = [ ./hardware.nix ];
      }
  */
  mkHostConfig = { hostname, system ? "x86_64-linux", modules ? [], ... }@args:
    {
      inherit system hostname;
      modules = modules;
    } // (removeAttrs args [ "hostname" "system" "modules" ]);

  /**
    Create a user configuration structure.
    
    Example:
      mkUserConfig {
        username = "john";
        homeDirectory = "/home/john";
      }
  */
  mkUserConfig = { username, homeDirectory ? "/home/${username}", ... }@args:
    {
      inherit username homeDirectory;
    } // (removeAttrs args [ "username" "homeDirectory" ]);

  # ============================================================================
  # List Utilities
  # ============================================================================

  /**
    Remove duplicates from a list while preserving order.
    
    Example:
      unique [ 1 2 2 3 1 ]  # Returns [ 1 2 3 ]
  */
  unique = list:
    let
      go = acc: seen: list:
        if list == [] then acc
        else
          let
            x = lib.head list;
            xs = lib.tail list;
          in
          if builtins.elem x seen
          then go acc seen xs
          else go (acc ++ [x]) (seen ++ [x]) xs;
    in
    go [] [] list;

  /**
    Flatten a list of lists.
    
    Example:
      flatten [ [1 2] [3 4] ]  # Returns [ 1 2 3 4 ]
  */
  flatten = lib.flatten;

  /**
    Filter and map in one pass. The function should return null for items to skip.
    
    Example:
      filterMap (x: if x > 2 then x * 2 else null) [ 1 2 3 4 ]
      # Returns [ 6 8 ]
  */
  filterMap = f: list:
    let
      go = acc: xs:
        if xs == [] then acc
        else
          let
            x = lib.head xs;
            rest = lib.tail xs;
            result = f x;
          in
          if result == null then go acc rest
          else go (acc ++ [result]) rest;
    in
    go [] list;

  # ============================================================================
  # Attribute Set Utilities
  # ============================================================================

  /**
    Map over attribute set values.
    
    Example:
      mapAttrsValues (x: x * 2) { a = 1; b = 2; }
      # Returns { a = 2; b = 4; }
  */
  mapAttrsValues = f: attrs:
    lib.mapAttrs (name: value: f value) attrs;

  /**
    Filter attribute set by value predicate.
    
    Example:
      filterAttrsByValue (x: x > 2) { a = 1; b = 3; c = 2; }
      # Returns { b = 3; }
  */
  filterAttrsByValue = pred: attrs:
    lib.filterAttrs (name: value: pred value) attrs;

  /**
    Get all attribute names where the value satisfies a predicate.
    
    Example:
      attrNamesWhere (x: x.enable or false) { firefox.enable = true; steam.enable = false; }
      # Returns [ "firefox" ]
  */
  attrNamesWhere = pred: attrs:
    lib.attrNames (lib.filterAttrs (name: value: pred value) attrs);

  # ============================================================================
  # Type Utilities
  # ============================================================================

  /**
    Create a package option with description.
    
    Example:
      mkPackageOption pkgs.firefox "Firefox browser"
  */
  mkPackageOption = default: description:
    lib.mkOption {
      type = lib.types.package;
      default = default;
      defaultText = lib.literalExpression "pkgs.${default.pname or "package"}";
      description = description;
    };

  /**
    Create a list of packages option.
    
    Example:
      mkPackagesOption [] "Additional packages"
  */
  mkPackagesOption = default: description:
    lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = default;
      description = description;
    };

  # ============================================================================
  # Validation Utilities
  # ============================================================================

  /**
    Assert that a package exists, throw error if not.
    
    Example:
      assertPackageExists "firefox" pkgs
  */
  assertPackageExists = name:
    if hasPackage name
    then true
    else throw "Package '${name}' not found in pkgs";

  /**
    Assert that all packages in a list exist.
    
    Example:
      assertPackagesExist [ "firefox" "steam" ] pkgs
  */
  assertPackagesExist = names:
    builtins.map (name: assertPackageExists name) names;

  # ============================================================================
  # Module System Utilities
  # ============================================================================

  /**
    Merge multiple module configurations, with later modules taking precedence.
    
    Example:
      mergeModules [ module1 module2 module3 ]
  */
  mergeModules = modules:
    lib.foldl' (acc: mod: lib.recursiveUpdate acc mod) {} modules;

  /**
    Conditionally include a module based on a condition.
    
    Example:
      optionalModule (system == "x86_64-linux") ./some-module.nix
  */
  optionalModule = cond: mod: if cond then mod else {};

  /**
    Create a module that only applies when a condition is true.
    
    Example:
      mkConditionalModule (cfg.enable) { programs.something.enable = true; }
  */
  mkConditionalModule = cond: config:
    if cond then config else {};

  # ============================================================================
  # List Utilities (Additional)
  # ============================================================================

  /**
    Partition a list into two lists based on a predicate.
    
    Example:
      partition (x: x > 2) [ 1 2 3 4 5 ]
      # Returns { right = [ 3 4 5 ]; wrong = [ 1 2 ]; }
  */
  partition = pred: list:
    let
      go = right: wrong: xs:
        if xs == [] then { inherit right wrong; }
        else
          let
            x = lib.head xs;
            rest = lib.tail xs;
          in
          if pred x
          then go (right ++ [x]) wrong rest
          else go right (wrong ++ [x]) rest;
    in
    go [] [] list;

  /**
    Group a list by a key function.
    
    Example:
      groupBy (x: x % 2) [ 1 2 3 4 5 ]
      # Returns { "1" = [ 1 3 5 ]; "0" = [ 2 4 ]; }
  */
  groupBy = keyFn: list:
    lib.foldl' (acc: x:
      let k = toString (keyFn x); in
      acc // { ${k} = (acc.${k} or []) ++ [x]; }
    ) {} list;

  # ============================================================================
  # String Utilities
  # ============================================================================

  /**
    Capitalize the first letter of a string.
    
    Example:
      capitalize "hello"  # Returns "Hello"
  */
  capitalize = str:
    if str == "" then ""
    else (lib.toUpper (lib.substring 0 1 str)) + (lib.substring 1 (lib.stringLength str) str);

  /**
    Convert a string to a valid Nix identifier (replaces invalid chars with _).
    
    Example:
      toIdentifier "my-app"  # Returns "my_app"
  */
  toIdentifier = str:
    lib.stringAsChars (c: if lib.isAlphaNum c || c == "_" then c else "_") str;
}
