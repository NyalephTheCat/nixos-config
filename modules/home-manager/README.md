# Home Manager Modules

This directory contains user-level Home Manager modules that configure individual user environments.

## Structure

- **programs/** - Program configurations (git, shell, terminal, development)
- **packages/** - User packages (split by category: communication, development, media, utilities)
- **features/** - Optional user features (gaming-tools, content-creation)

## Usage

Import modules in your user configuration:

```nix
imports = [
  ../../modules/home-manager/programs
  ../../modules/home-manager/features
  ./packages.nix  # User-specific packages
];
```

## Module Organization

Each category has a `default.nix` that aggregates related modules. This allows you to import entire categories at once.

## User Feature Flags

Optional features are controlled by flags defined in `users/<username>/home.nix`:

```nix
features.user = {
  gaming-tools = true;
  content-creation = false;
  streaming = false;
  development = true;
};
```

See `FEATURES.md` for complete reference.

