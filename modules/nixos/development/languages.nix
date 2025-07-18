{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development.languages;
in
{
  options.modules.development.languages = {
    enable = mkEnableOption "programming languages support";
    
    nix = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Nix development tools";
      };
    };
    
    rust = {
      enable = mkEnableOption "Rust development environment";
      channel = mkOption {
        type = types.enum [ "stable" "beta" "nightly" ];
        default = "stable";
        description = "Rust channel to use";
      };
    };
    
    go = {
      enable = mkEnableOption "Go development environment";
      package = mkOption {
        type = types.package;
        default = pkgs.go;
        description = "Go package to use";
      };
    };
    
    python = {
      enable = mkEnableOption "Python development environment";
      package = mkOption {
        type = types.package;
        default = pkgs.python3;
        description = "Python package to use";
      };
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Extra Python packages to install globally";
      };
    };
    
    javascript = {
      enable = mkEnableOption "JavaScript/TypeScript development environment";
      nodejs = mkOption {
        type = types.package;
        default = pkgs.nodejs_20;
        description = "Node.js package to use";
      };
    };
    
    java = {
      enable = mkEnableOption "Java development environment";
      jdk = mkOption {
        type = types.package;
        default = pkgs.jdk17;
        description = "JDK package to use";
      };
    };
    
    c = {
      enable = mkEnableOption "C/C++ development environment";
      compiler = mkOption {
        type = types.enum [ "gcc" "clang" ];
        default = "gcc";
        description = "Default C/C++ compiler";
      };
    };
    
    haskell = {
      enable = mkEnableOption "Haskell development environment";
    };
    
    elixir = {
      enable = mkEnableOption "Elixir development environment";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; 
      # Nix
      (optionals cfg.nix.enable [
        nil # Nix LSP
        nixpkgs-fmt
        nixfmt-classic
        nix-tree
        nix-diff
        nix-prefetch-git
        nix-output-monitor
        nvd # Nix version diff
        statix # Nix linter
        deadnix # Find dead Nix code
        alejandra # Nix formatter
      ]) ++
      
      # Rust
      (optionals cfg.rust.enable [
        rustc
        cargo
        rustfmt
        rust-analyzer
        cargo-edit
        cargo-watch
        cargo-outdated
        cargo-audit
        cargo-nextest
        sccache
      ]) ++
      
      # Go
      (optionals cfg.go.enable [
        cfg.go.package
        gopls
        delve
        go-tools
        golangci-lint
        gomodifytags
        gotests
        impl
        godef
      ]) ++
      
      # Python
      (optionals cfg.python.enable ([
        (cfg.python.package.withPackages (ps: with ps; [
          pip
          setuptools
          wheel
          virtualenv
          pytest
          black
          isort
          flake8
          mypy
          ipython
          jupyter
          pandas
          numpy
          requests
        ] ++ cfg.python.extraPackages))
        poetry
        pipenv
        pyright
        ruff
      ])) ++
      
      # JavaScript/TypeScript
      (optionals cfg.javascript.enable [
        cfg.javascript.nodejs
        nodePackages.npm
        nodePackages.yarn
        nodePackages.pnpm
        nodePackages.typescript
        nodePackages.typescript-language-server
        nodePackages.eslint
        nodePackages.prettier
        deno
        bun
      ]) ++
      
      # Java
      (optionals cfg.java.enable [
        cfg.java.jdk
        maven
        gradle
        jdt-language-server
      ]) ++
      
      # C/C++
      (optionals cfg.c.enable ([
        cmake
        ninja
        meson
        pkg-config
        bear # Build EAR for compilation databases
        ccls
        cppcheck
        include-what-you-use
      ] ++ (if cfg.c.compiler == "gcc" then [
        gcc
        gdb
      ] else [
        clang
        clang-tools
        lldb
        llvmPackages.openmp
      ]))) ++
      
      # Haskell
      (optionals cfg.haskell.enable [
        ghc
        stack
        cabal-install
        haskell-language-server
        hlint
        hoogle
        ormolu
      ]) ++
      
      # Elixir
      (optionals cfg.elixir.enable [
        elixir
        elixir-ls
        erlang
        rebar3
      ]);
    
    # Language-specific environment variables
    environment.variables = mkMerge [
      (mkIf cfg.rust.enable {
        RUST_BACKTRACE = "1";
      })
      (mkIf cfg.go.enable {
        GOPATH = "$HOME/go";
        GOBIN = "$HOME/go/bin";
      })
    ];
    
    # Language-specific PATH additions
    environment.extraInit = mkMerge [
      (mkIf cfg.go.enable ''
        export PATH="$GOBIN:$PATH"
      '')
      (mkIf cfg.rust.enable ''
        export PATH="$HOME/.cargo/bin:$PATH"
      '')
    ];
  };
}