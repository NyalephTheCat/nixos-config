{ lib, ... }:

{
  # Validation helpers for configuration

  # Validate feature configuration
  # Usage: validateFeatureConfig config.features.gaming { enable = false; }
  validateFeatureConfig = feature: expected:
    if lib.isBool feature
    then feature == (expected.enable or false)
    else lib.all (name: lib.hasAttr name feature) (lib.attrNames expected);

  # Validate host configuration
  # Usage: validateHostConfig config { system = "x86_64-linux"; }
  validateHostConfig = config: expected:
    lib.all (name: lib.hasAttr name config) (lib.attrNames expected);

  # Check if required options are set
  # Usage: checkRequiredOptions config [ "features.gaming.enable" "features.desktop.environment" ]
  checkRequiredOptions = config: required:
    let
      getOption = path: lib.attrByPath (lib.splitString "." path) null config;
      checkOption = path:
        let value = getOption path;
        in value != null && value != {};
    in
    lib.all checkOption required;

  # Validate feature dependencies
  # Usage: validateFeatureDependencies config { gaming = [ "desktop" ]; }
  validateFeatureDependencies = config: dependencies:
    let
      checkDependency = feature: deps:
        let
          featureEnabled = lib.attrByPath (lib.splitString "." feature) false config;
          depsEnabled = map (dep: lib.attrByPath (lib.splitString "." dep) false config) deps;
        in
        if featureEnabled
        then lib.all (x: x) depsEnabled
        else true;
    in
    lib.all (name: checkDependency name dependencies.${name}) (lib.attrNames dependencies);

  # Detect feature conflicts
  # Usage: detectFeatureConflicts config { gaming = [ "server" ]; }
  detectFeatureConflicts = config: conflicts:
    let
      checkConflict = feature: conflicting:
        let
          featureEnabled = lib.attrByPath (lib.splitString "." feature) false config;
          conflictingEnabled = map (conf: lib.attrByPath (lib.splitString "." conf) false config) conflicting;
        in
        if featureEnabled
        then lib.any (x: x) conflictingEnabled
        else false;
    in
    lib.filter (name: checkConflict name conflicts.${name}) (lib.attrNames conflicts);
}

