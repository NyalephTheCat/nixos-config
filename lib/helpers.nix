{ lib, ... }:

with lib;

rec {
  # Host creation helper
  mkHost = { system ? "x86_64-linux", modules ? [], specialArgs ? {} }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit lib; } // specialArgs;
      modules = modules;
    };

  # User creation helper for home-manager
  mkUser = { system ? "x86_64-linux", modules ? [], extraSpecialArgs ? {} }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit lib; } // extraSpecialArgs;
      modules = modules;
    };

  # Option creation helpers
  mkOpt = type: default: description:
    mkOption {
      inherit type default description;
    };

  mkOptStr = default: description:
    mkOpt types.str default description;

  mkOptBool = default: description:
    mkOpt types.bool default description;

  mkOptList = elementType: default: description:
    mkOpt (types.listOf elementType) default description;

  mkOptAttrs = default: description:
    mkOpt types.attrs default description;

  # Module filtering helpers
  enabledModules = modules:
    filterAttrs (name: value: value.enable or false) modules;

  disabledModules = modules:
    filterAttrs (name: value: !(value.enable or false)) modules;

  # Conditional helpers
  ifEnabled = module: config:
    if module.enable or false then config else {};

  ifDisabled = module: config:
    if !(module.enable or false) then config else {};

  # Mapping helpers for directory scanning
  mapModules = dir: fn:
    let
      files = attrNames (readDir dir);
      validFiles = filter (f: hasSuffix ".nix" f && f != "default.nix") files;
      names = map (f: removeSuffix ".nix" f) validFiles;
    in
    listToAttrs (map (name: {
      inherit name;
      value = fn (dir + "/${name}.nix");
    }) names);

  mapHosts = dir:
    mapAttrs (name: _: dir + "/${name}") (readDir dir);

  mapUsers = dir:
    mapAttrs (name: _: dir + "/${name}") (readDir dir);

  # Package helpers
  mkPkgSet = pkgs: packages:
    map (pkg: pkgs.${pkg}) packages;

  # Service helpers
  mkService = name: config:
    {
      "services.${name}" = config;
    };

  # Desktop environment helpers
  mkDesktop = name: packages: config:
    {
      environment.systemPackages = packages;
      services.xserver = config;
    };

  # User service helpers
  mkUserService = name: config:
    {
      "systemd.user.services.${name}" = config;
    };

  # Font helpers
  mkFontConfig = fonts:
    {
      fonts.packages = fonts;
      fonts.fontconfig.enable = true;
    };

  # Development environment helpers
  mkDevShell = pkgs: packages: shellHook:
    pkgs.mkShell {
      buildInputs = packages;
      shellHook = shellHook;
    };

  # Theme helpers
  mkTheme = name: colors: {
    name = name;
    colors = colors;
    gtk = {
      enable = true;
      theme = {
        name = name;
        package = colors.gtkTheme;
      };
    };
  };

  # Network helpers
  mkNetworkConfig = interfaces:
    {
      networking.interfaces = interfaces;
      networking.networkmanager.enable = true;
    };

  # Security helpers
  mkFirewallRules = { allowedTCPPorts ? [], allowedUDPPorts ? [], ... }:
    {
      networking.firewall = {
        enable = true;
        allowedTCPPorts = allowedTCPPorts;
        allowedUDPPorts = allowedUDPPorts;
      };
    };

  # Backup helpers
  mkBackupJob = name: paths: destination:
    {
      "services.restic.backups.${name}" = {
        paths = paths;
        repository = destination;
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };

  # Container helpers
  mkContainer = name: config:
    {
      "containers.${name}" = {
        autoStart = true;
        privateNetwork = false;
        config = config;
      };
    };

  # Auto-import helpers
  importAllNix = dir:
    let
      nixFiles = lib.filesystem.listFilesRecursive dir;
      validNixFiles = builtins.filter (f:
        lib.hasSuffix ".nix" (toString f) &&
        !(lib.hasSuffix "default.nix" (toString f))
      ) nixFiles;
    in
    map import validNixFiles;

  # Configuration merging helpers
  mergeConfigs = configs:
    lib.foldl' lib.recursiveUpdate {} configs;

  # System state helpers
  mkSystemdService = name: { description, serviceConfig, ... }@config:
    {
      "systemd.services.${name}" = {
        inherit description;
        serviceConfig = {
          Type = "simple";
          Restart = "always";
        } // serviceConfig;
      } // (removeAttrs config [ "description" "serviceConfig" ]);
    };

  # Home-manager service helpers
  mkHomeService = name: config:
    {
      "systemd.user.services.${name}" = config // {
        Unit.Description = config.description or "${name} service";
        Service.Type = config.type or "simple";
        Service.Restart = config.restart or "on-failure";
      };
    };
}
