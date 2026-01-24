# Services Modules

This directory contains system service configurations.

## Purpose

Services modules provide common system service configurations that can be shared across all hosts.

## Structure

- `common.nix` - Common services used across all hosts
- `default.nix` - Aggregates all service modules

## Adding New Services

1. Create a new module file in this directory
2. Import it in `default.nix`
3. Use `lib.mkDefault` for options that should be overridable
4. Document the service in this README

## Service Configuration

Services should:
- Use `lib.mkDefault` for overridable options
- Include sensible defaults
- Be documented with comments
- Support feature flags when appropriate

## Examples

```nix
{ config, pkgs, lib, ... }:

{
  services.myService = {
    enable = lib.mkDefault true;
    settings = {
      option = lib.mkDefault "value";
    };
  };
}
```

