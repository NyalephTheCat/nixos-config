# Rust development: toolchain, build deps, optional profiles (Bevy, SQL), and env.
# Use toolchain = "nix" for a fixed Nix-managed toolchain, or "rustup" to manage
# toolchains yourself; we still set CC/linker and PKG_CONFIG_PATH so both work.
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.applications.rust;
  hostPlatform = pkgs.stdenv.hostPlatform.config;
  cc = "${pkgs.stdenv.cc}/bin/cc";
  cxx = "${pkgs.stdenv.cc}/bin/c++";
  rustFlagsLinker = "-C linker=${cc}";
  userRustFlags = cfg.environmentVariables.RUSTFLAGS or "";
  rustFlags = if userRustFlags == "" then rustFlagsLinker else "${userRustFlags} ${rustFlagsLinker}";

  # PKG_CONFIG_PATH for openssl, udev, alsa when build deps or Bevy are enabled
  pkgConfigPath = concatStringsSep ":" (unique (filter (x: x != "") [
    (optionalString cfg.buildDependencies.enable "${pkgs.openssl.dev}/lib/pkgconfig")
    (optionalString (cfg.buildDependencies.enable || cfg.profiles.bevy) "${pkgs.udev.dev}/lib/pkgconfig")
    (optionalString (cfg.buildDependencies.enable || cfg.profiles.bevy) "${pkgs.alsa-lib.dev}/lib/pkgconfig")
  ]));

  nixToolchainPackages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
  ];

  buildDepsPackages = optionals cfg.buildDependencies.enable cfg.buildDependencies.packages;

  bevyPackages = optionals cfg.profiles.bevy (with pkgs; [
    alsa-lib
    xorg.libX11
    xorg.libxcb
    libxkbcommon
    wayland
    udev
    vulkan-loader
    vulkan-tools
  ]);

  sqlPackages = optionals cfg.profiles.sql (with pkgs; [
    sqlite-interactive
    postgresql
    postgresql.lib
    mysql80
  ]);

  allPackages = (if cfg.toolchain == "rustup" then [ pkgs.rustup ] else nixToolchainPackages)
    ++ buildDepsPackages
    ++ bevyPackages
    ++ sqlPackages
    ++ cfg.extraPackages;

  rustEnv = pkgs.buildEnv {
    name = "rust-env";
    paths = allPackages;
    ignoreCollisions = cfg.toolchain == "rustup";
  };
in
{
  options.applications.rust = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Rust development (toolchain, build deps, env).";
    };

    toolchain = mkOption {
      type = types.enum [ "nix" "rustup" ];
      default = "rustup";
      description = ''
        Toolchain source: "nix" (rustc, cargo, rust-analyzer, rustfmt, clippy from nixpkgs)
        or "rustup" (only rustup; manage toolchains with rustup default/install).
      '';
    };

    buildDependencies = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Install C/build deps and set CC, PKG_CONFIG_PATH, OPENSSL_*, RUSTFLAGS so crates with C deps build.";
          };
          packages = mkOption {
            type = types.listOf types.package;
            default = with pkgs; [
              gcc
              gnumake
              pkg-config
              openssl
              openssl.dev
              udev
              udev.dev
              alsa-lib.dev
              lld
            ];
            defaultText = literalExpression "[ gcc gnumake pkg-config openssl openssl.dev udev udev.dev alsa-lib.dev lld ]";
            description = "Packages for building Rust crates with C dependencies.";
          };
        };
      };
      default = { enable = true; packages = with pkgs; [ gcc gnumake pkg-config openssl openssl.dev udev udev.dev alsa-lib.dev lld ]; };
      description = "Build dependencies and environment (CC, PKG_CONFIG_PATH, etc.).";
    };

    profiles = mkOption {
      type = types.submodule {
        options = {
          bevy = mkOption {
            type = types.bool;
            default = true;
            description = "Add runtime libs for Bevy (ALSA, X11/Wayland, Vulkan, udev).";
          };
          sql = mkOption {
            type = types.bool;
            default = true;
            description = "Add SQL tools and libs (SQLite, PostgreSQL, MySQL).";
          };
        };
      };
      default = { bevy = true; sql = true; };
      description = "Optional profiles (bevy, sql) that add predefined packages.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        cargo-watch
        cargo-edit
        cargo-expand
        cargo-nextest
        cargo-audit
        cargo-outdated
        cargo-deny
        trunk
      ];
      defaultText = literalExpression "[ cargo-watch cargo-edit cargo-expand cargo-nextest cargo-audit cargo-outdated cargo-deny trunk ]";
      description = "Extra packages (cargo-*, trunk, etc.).";
    };

    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables; RUSTFLAGS is merged with the linker flag.";
      example = { CARGO_TARGET_DIR = "target"; };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ rustEnv ];
    home.sessionPath = [ "$HOME/.cargo/bin" ];

    home.sessionVariables = mkMerge [
      cfg.environmentVariables
      (mkIf cfg.buildDependencies.enable {
        CC = cc;
        CXX = cxx;
        RUSTFLAGS = rustFlags;
        PKG_CONFIG_PATH = pkgConfigPath;
        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      })
    ];

    # So IDEs and GUI apps see the same env
    home.file.".config/environment.d/rust.conf" = mkIf cfg.buildDependencies.enable {
      text = ''
        PKG_CONFIG_PATH=${pkgConfigPath}
        OPENSSL_DIR=${pkgs.openssl.dev}
        OPENSSL_LIB_DIR=${pkgs.openssl.out}/lib
        CC=${cc}
        CXX=${cxx}
        RUSTFLAGS=${rustFlags}
      '';
    };

    # Cargo linker: works even when env isn't loaded (e.g. Cursor)
    home.file.".cargo/config.toml" = mkIf cfg.buildDependencies.enable {
      text = ''
        # Managed by Nix (applications.rust)
        [target.${hostPlatform}]
        linker = "${cc}"
      '';
    };
  };
}
