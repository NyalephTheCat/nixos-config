{ lib, ... }:

{
  # Override a package with new attributes
  # Usage: overridePackageAttrs pkgs.myPackage { version = "custom"; }
  overridePackageAttrs = pkg: attrs:
    pkg.overrideAttrs (old: attrs);

  # Override a package's dependencies
  # Usage: overridePackageDeps pkgs.myPackage { dep1 = pkgs.newDep1; }
  overridePackageDeps = pkg: deps:
    pkg.override deps;

  # Merge package lists, removing duplicates by name
  # Usage: mergePackageLists [ pkgs.pkg1 ] [ pkgs.pkg2 pkgs.pkg1 ]
  mergePackageLists = lists:
    let
      # Extract package name for deduplication
      getPkgName = pkg:
        if lib.isDerivation pkg then pkg.name
        else if lib.isString pkg then pkg
        else toString pkg;
      
      # Deduplicate by name
      unique = list:
        lib.foldl' (acc: pkg:
          let name = getPkgName pkg;
          in if lib.any (p: getPkgName p == name) acc
            then acc
            else acc ++ [ pkg ]
        ) [] list;
    in
    unique (lib.concatLists lists);

  # Filter packages by name pattern
  # Usage: filterPackagesByName [ pkgs.git pkgs.curl ] "git"
  filterPackagesByName = packages: pattern:
    lib.filter (pkg:
      let name = if lib.isDerivation pkg then pkg.name else toString pkg;
      in lib.hasInfix pattern name
    ) packages;

  # Filter packages by attribute path
  # Usage: filterPackagesByPath pkgs [ "python3Packages" "requests" ]
  filterPackagesByPath = pkgs: path:
    lib.attrByPath path null pkgs;

  # Get all packages from an attribute set
  # Usage: getPackagesFromAttrs { pkg1 = pkgs.git; pkg2 = pkgs.curl; }
  getPackagesFromAttrs = attrs:
    lib.attrValues attrs;

  # Create a package set from a list of package names
  # Usage: createPackageSet pkgs [ "git" "curl" "vim" ]
  createPackageSet = pkgs: names:
    lib.genAttrs names (name: pkgs.${name} or null);

  # Override multiple packages at once
  # Usage: overridePackages pkgs { git = { version = "custom"; }; }
  overridePackages = pkgs: overrides:
    lib.mapAttrs (name: attrs:
      if lib.hasAttr name pkgs
      then overridePackageAttrs pkgs.${name} attrs
      else throw "Package ${name} not found in pkgs"
    ) overrides;

  # Add build inputs to a package
  # Usage: addBuildInputs pkgs.myPackage [ pkgs.cmake pkgs.pkg-config ]
  addBuildInputs = pkg: inputs:
    pkg.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ inputs;
    });

  # Add native build inputs to a package
  # Usage: addNativeBuildInputs pkgs.myPackage [ pkgs.cmake ]
  addNativeBuildInputs = pkg: inputs:
    pkg.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ inputs;
    });

  # Set environment variables for a package build
  # Usage: setPackageEnv pkgs.myPackage { CUSTOM_VAR = "value"; }
  setPackageEnv = pkg: env:
    pkg.overrideAttrs (old: {
      preBuild = (old.preBuild or "") + ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "export ${name}=${value}") env)}
      '';
    });

  # Apply patches to a package
  # Usage: patchPackage pkgs.myPackage [ ./patch1.patch ./patch2.patch ]
  patchPackage = pkg: patches:
    pkg.overrideAttrs (old: {
      patches = (old.patches or []) ++ patches;
    });

  # Change package source
  # Usage: changePackageSource pkgs.myPackage (pkgs.fetchFromGitHub { ... })
  changePackageSource = pkg: src:
    pkg.overrideAttrs (old: {
      inherit src;
    });

  # Create a package set from a list (alias for createPackageSet)
  # Usage: mkPackageSet pkgs [ "git" "curl" "vim" ]
  mkPackageSet = createPackageSet;

  # Filter packages by architecture
  # Usage: filterPackagesByArch pkgs "x86_64-linux" [ pkgs.pkg1 pkgs.pkg2 ]
  filterPackagesByArch = pkgs: arch: packages:
    lib.filter (pkg:
      if lib.isDerivation pkg
      then lib.elem arch (pkg.meta.platforms or [])
      else true
    ) packages;

  # Extract version from package
  # Usage: getPackageVersion pkgs.git
  getPackageVersion = pkg:
    if lib.isDerivation pkg
    then pkg.version or "unknown"
    else "unknown";

  # Deep merge configurations
  # Usage: mergeConfigs baseConfig overrideConfig
  mergeConfigs = lib.recursiveUpdate;

  # Apply defaults to config
  # Usage: applyDefaults config { enable = false; }
  applyDefaults = config: defaults:
    lib.recursiveUpdate defaults config;

  # Sanitize config by removing invalid options
  # Usage: sanitizeConfig config validOptions
  sanitizeConfig = config: validOptions:
    lib.filterAttrs (name: _: lib.elem name validOptions) config;
}

