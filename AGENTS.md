# Agent Guidelines for NixOS Dotfiles

## Development Environment
- **Enter shell**: `nix develop --no-pure-eval` or automatic via direnv
- **Run pre-commit hooks**: `devenv test` (also runs automatically on git commit)
- **Start services**: `devenv up` (if any processes are defined)

## Build/Test Commands
- **Build system**: `nix build .#nixosConfigurations.<hostname>` (e.g., `nix build .#nixosConfigurations.carbon`)
- **Build home config**: `nix build .#homeConfigurations."alejandro@<hostname>"`
- **Test configuration**: `nix flake check` (validates all configurations)
- **Format code**: `nixfmt .` (Nix formatter, available in devenv shell)
- **Deploy**: `nix run github:serokell/deploy-rs -- .#<hostname>` (e.g., `.#gospel`)

## Code Style Guidelines
- **Formatter**: Use nixfmt-rfc-style for Nix code formatting (managed by devenv pre-commit hooks)
- **Pre-commit**: Hooks run automatically on commit via devenv (trailing whitespace, YAML validation, etc.)
- **Imports**: Group function parameters in curly braces, use `...` for extensibility
- **Naming**: Use camelCase for variables, kebab-case for hostnames/services
- **Module structure**: Follow `{ config, lib, pkgs, namespace, ... }:` pattern
- **Options**: Use `lib.mkEnableOption` and `lib.mkOption` with proper types and descriptions
- **Conditionals**: Use `lib.mkIf` for conditional configuration, `lib.mkMerge` for combining configs
- **Namespace**: Use `aa` namespace for custom modules (defined in flake.nix)
- **Comments**: Add descriptive comments for complex logic, especially in system configurations
- **Error handling**: Leverage Nix's built-in evaluation errors, use `lib.assertMsg` for custom assertions

## Repository Structure
- `flake.nix`: Main entry point using Snowfall lib with devenv integration
- `devenv.nix`: Development environment configuration with pre-commit hooks
- `systems/`: NixOS system configurations
- `homes/`: Home Manager configurations  
- `modules/`: Reusable modules (nixos/ and home/)
- `packages/`: Custom package definitions
- `.envrc`: Direnv configuration for automatic shell activation