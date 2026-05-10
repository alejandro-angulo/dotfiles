# Plan: Migrate This Flake To Den

## Goal

Adopt the `vic/den` framework as the dendritic layer for this repository. Den should become responsible for declaring hosts, users, homes, aspects, and eventually the standard flake outputs such as `nixosConfigurations` and `homeConfigurations`.

The migration should be incremental. The current flake outputs must keep working while Den is introduced, then Den should gradually take over configuration assembly.

## Why Den

Den is a maintained dendritic framework rather than just a hand-rolled pattern. It provides the concepts this repository would otherwise need to invent locally:

- `den.hosts` for NixOS and Darwin host declarations.
- `den.homes` for standalone Home Manager configurations.
- `den.aspects` for feature-oriented modules that can emit NixOS, Home Manager, packages, checks, and other classes.
- `den.schema` for host, user, and home metadata.
- `den.provides` batteries for common cross-platform behavior such as hostname, users, primary users, and shell setup.
- A built-in output pipeline that can produce `flake.nixosConfigurations`, `flake.darwinConfigurations`, and `flake.homeConfigurations`.

Using Den should reduce custom code in `flake.nix` and avoid designing custom top-level options for hosts, homes, and module resolution.

## Current State

- `flake.nix` declares inputs, overlays, package definitions, module discovery, NixOS configurations, Home Manager configurations, deploy nodes, and derived domains.
- `modules/nixos/**/default.nix` files are lower-level NixOS modules.
- `modules/home/**/default.nix` files are lower-level Home Manager modules.
- `systems/**/default.nix` files define host-specific NixOS configurations.
- `homes/**/default.nix` files define host/user-specific Home Manager configurations.
- `packages/**/default.nix` and `overlays/**/default.nix` are plain package and overlay expressions.
- The repo already uses `flake-parts`, which Den can work with.

## Target Shape

- `flake.nix` should eventually be a small entry point that declares inputs and evaluates Den modules.
- Feature files should be Den modules, usually declaring `den.aspects.<feature>`.
- Host files should declare `den.hosts.<system>.<host>` and a host aspect such as `den.aspects.<host>.nixos`.
- User/home files should declare users under hosts or standalone homes under `den.homes`.
- Shared behavior should move into reusable aspects and Den includes.
- Current output names must remain stable:
  - `.#nixosConfigurations.carbon`
  - `.#nixosConfigurations.framework`
  - `.#nixosConfigurations.git`
  - `.#nixosConfigurations.gospel`
  - `.#nixosConfigurations.node`
  - `.#nixosConfigurations.pi4`
  - `.#homeConfigurations."alejandro@carbon"`
  - `.#homeConfigurations."alejandro@framework"`
  - `.#homeConfigurations."alejandro@git"`
  - `.#homeConfigurations."alejandro@gospel"`
  - `.#homeConfigurations."alejandro@minimal"`
  - `.#homeConfigurations."alejandro@node"`
  - `.#homeConfigurations."alejandro@pi4"`

## Recommended Directory Strategy

Use a new Den module tree first, instead of immediately changing the type of the existing `modules/nixos` and `modules/home` files.

Recommended initial tree:

```text
den/
  default.nix or bootstrap.nix
  defaults.nix
  packages.nix
  overlays.nix
  homes/
  hosts/
  aspects/
  outputs/
```

This avoids ambiguity while migrating. Existing lower-level modules can remain where they are until they are converted or wrapped.

Once Den owns most of the repo, decide whether to rename `den/` to `modules/` to match Den documentation examples. That rename should be a final cleanup, not part of the first phase.

## Phase 1: Add Den Without Changing Existing Outputs

1. Add inputs:
   - `den.url = "github:vic/den"`
   - `import-tree.url = "github:vic/import-tree"`

2. Add a Den bootstrap module under the new Den tree.
   - Import Den's module.
   - Import Den's flake output compatibility module if needed for the current flake-parts setup.
   - Keep this isolated from the current `collectDefaultModules` mechanism.

3. Evaluate Den next to the current flake.
   - In the current `outputs` function, evaluate Den modules with `inputs.nixpkgs.lib.evalModules`.
   - Pass `specialArgs.inputs = inputs`, matching Den's migration guide.
   - Do not yet replace `nixosConfigurations` or `homeConfigurations`.

4. Add one trivial Den aspect to prove evaluation works.
   - Start with a harmless aspect that does not get included by any host.
   - Verify the Den config evaluates.

5. Run `nix flake check --impure`.

Success criteria for this phase:

- Existing flake outputs are unchanged.
- Den modules evaluate successfully.
- No host or home behavior has moved yet.

## Phase 2: Model Repository Defaults In Den

1. Move shared identity into Den defaults or schema.
   - Username: `alejandro`.
   - Home directory: `/home/alejandro`.
   - Existing lower-level namespace: `aa`.

2. Configure default user behavior.
   - Use Den's user/home schema to default users to Home Manager participation.
   - Consider Den batteries such as `define-user` and `primary-user` where they replace current user boilerplate cleanly.

3. Model shared NixOS behavior as Den default NixOS config or a common aspect.
   - Current `nixpkgs.config.allowUnfree = true`.
   - Current `nixpkgs.config.android_sdk.accept_license = true`.
   - Current default overlays.
   - Current Home Manager integration behavior.

4. Keep current `aa` NixOS/Home Manager module namespace intact.
   - Den is the assembly layer.
   - Existing `aa.*` options should continue to work inside NixOS and Home Manager modules.

Success criteria for this phase:

- Den has enough defaults to instantiate a host or home later without duplicating the current flake helper logic.
- The current flake outputs are still produced by existing code.

## Phase 3: Convert Simple Features To Aspects

Start with features that are small, isolated, and easy to verify.

Suggested first Home Manager aspects:

- `modules/home/tools/direnv/default.nix`
- `modules/home/tools/eza/default.nix`
- `modules/home/programs/fzf/default.nix`
- `modules/home/programs/zoxide/default.nix`

Suggested first NixOS aspects:

- `modules/nixos/services/openssh/default.nix`
- `modules/nixos/services/tailscale/default.nix`
- `modules/nixos/system/fonts/default.nix`

Migration approach:

1. For each feature, create a Den aspect such as `den.aspects.zsh.homeManager` or `den.aspects.openssh.nixos`.
2. Initially, the aspect can import the existing lower-level module instead of rewriting it.
3. Once stable, decide whether to inline the lower-level module into the aspect.
4. Preserve all current `aa.<feature>.enable` options unless there is a concrete reason to replace them.

Example shape:

```nix
{ den, ... }:
{
  den.aspects.zsh.homeManager = {
    imports = [ ../../modules/home/tools/zsh ];
  };
}
```

Success criteria for this phase:

- Several features are represented as Den aspects.
- Existing lower-level modules can still be consumed unchanged.
- No broad host migration is required yet.

## Phase 4: Convert One Standalone Home

Start with a low-risk Home Manager configuration, preferably `alejandro@minimal` if it has the fewest host-specific assumptions.

1. Declare a Den home:
   - `den.homes.x86_64-linux."alejandro@minimal" = { ... };`
   - Set `userName = "alejandro"` if needed.
   - Ensure output placement remains `homeConfigurations."alejandro@minimal"`.

2. Create or reuse an aspect for the minimal home.
   - Import the existing `homes/x86_64-linux/alejandro@minimal` module first.
   - Include shared Home Manager aspects as needed.

3. Configure Home Manager instantiation to match the current behavior.
   - Same nixpkgs config.
   - Same overlays.
   - Same `extraSpecialArgs` where still required.
   - Same `home.username` and `home.homeDirectory`.

4. Compare evaluation behavior with the existing output.

5. Once the Den-produced output is correct, switch only that `homeConfigurations` entry to Den.

Success criteria for this phase:

- `.#homeConfigurations."alejandro@minimal"` is produced by Den.
- Other homes remain produced by the current code.
- The output name does not change.

## Phase 5: Convert One NixOS Host

Choose one lower-risk host. Good candidates are `git`, `gospel`, or `pi4`, depending on which has the simplest current dependencies and easiest build feedback.

1. Declare the host in Den:

```nix
{ den, ... }:
{
  den.hosts.x86_64-linux.git.users.alejandro = { };
}
```

2. Add a host aspect:

```nix
{ den, ... }:
{
  den.aspects.git.nixos = {
    imports = [ ../../systems/x86_64-linux/git ];
  };
}
```

3. Include Home Manager behavior for the user.
   - Prefer Den's home/user flow if it can reproduce the current embedded Home Manager setup.
   - Otherwise keep the current `home-manager` NixOS module integration during the transition.

4. Preserve host-specific imports.
   - Hardware files can remain normal lower-level imports.
   - Generated files such as `hardware-configuration.nix` do not need to become Den modules.

5. Build and compare:
   - `nix build .#nixosConfigurations.git.config.system.build.toplevel`

6. Once correct, switch only that host's `nixosConfigurations` entry to Den.

Success criteria for this phase:

- One NixOS host is produced by Den.
- Embedded Home Manager behavior still works.
- Other hosts remain on the existing assembly code.

## Phase 6: Convert Remaining Homes And Hosts

1. Convert remaining standalone Home Manager outputs:
   - `alejandro@carbon`
   - `alejandro@framework`
   - `alejandro@git`
   - `alejandro@gospel`
   - `alejandro@node`
   - `alejandro@pi4`

2. Convert remaining NixOS hosts:
   - `carbon`
   - `framework`
   - `git`
   - `gospel`
   - `node`
   - `pi4`

3. Split host configs into reusable includes where useful.
   - Workstation behavior should become an aspect.
   - Desktop behavior should become an aspect.
   - Server service bundles should become aspects.
   - Host-only settings should stay on the host aspect.

4. Move feature-oriented logic out of host files over time.
   - A host aspect should mostly include features and set host-specific values.
   - Cross-host behavior should live in reusable aspects.

Success criteria for this phase:

- Den produces all `nixosConfigurations` and `homeConfigurations`.
- Current output names remain stable.
- Existing modules have either been converted to aspects or are intentionally retained as lower-level implementation modules.

## Phase 7: Packages, Overlays, Dev Shells, And Other Flake Outputs

Den can emit flake outputs beyond hosts and homes, but these should move after core configurations are stable.

1. Move package exposure.
   - Preserve current packages:
     - `catppuccin-swaync`
     - `catppuccin-waybar`
     - `teslamate-grafana-dashboards`
   - Keep package source files under `packages/**/default.nix` unless there is a clear benefit to moving them.

2. Move overlays.
   - Preserve `flake.overlays.default`.
   - Preserve individual overlay names:
     - `neovim`
     - `signal-desktop`
     - `package/catppuccin-swaync`
     - `package/catppuccin-waybar`
     - `package/teslamate-grafana-dashboards`

3. Move dev shell generation.
   - Preserve `devShells.default` using `inputs.devenv.lib.mkShell` and `./devenv.nix`.

4. Keep helper functions if they are still useful.
   - `lib/helpers/default.nix` can remain a plain imported helper library.
   - Only move helpers into Den if they need Den context.

Success criteria for this phase:

- Package, overlay, and dev shell outputs remain stable.
- `flake.nix` no longer directly defines these outputs.

## Phase 8: Deploy Nodes And Domains

1. Move deploy metadata near host declarations.
   - `node`, `gospel`, `git`, and `pi4` deploy settings should live with their host modules or host aspects.

2. Preserve deploy-rs behavior.
   - Keep current `sshUser`, `user`, `sshOpts`, and activation paths.
   - Preserve `pi4.remoteBuild = true`.
   - Preserve the aarch64 deploy-rs overlay workaround if still needed.

3. Generate `flake.deploy.nodes` from Den or from a small Den-adjacent output module.

4. Move domain extraction.
   - Preserve current domain hosts: `gospel`, `node`, and `pi4`.
   - Keep `helpers.getDomainsPerHost` unless Den context makes a better implementation obvious.

Success criteria for this phase:

- `deploy.nodes` output remains compatible.
- `domains` output remains compatible.
- Deploy-specific host metadata is no longer centralized in `flake.nix`.

## Phase 9: Shrink `flake.nix`

Once Den owns all major outputs, reduce `flake.nix`.

Target end state:

```nix
{
  description = "My Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";
    # remaining inputs...
  };

  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./den) ];
      specialArgs.inputs = inputs;
    }).config.flake;
}
```

If keeping flake-parts is preferable, use the Den plus flake-parts form from Den's documentation instead of this Den-only output shape.

Remove transitional code:

- `collectDefaultModules`
- `localNixosModules`
- `localHomeModules`
- `commonNixosModules`
- `commonHomeModules`
- `mkNixosConfiguration`
- `mkHomeConfiguration`
- Manual `nixosConfigurations` maps
- Manual `homeConfigurations` maps
- Manual deploy node assembly, if moved
- Manual package and overlay assembly, if moved

Success criteria for this phase:

- `flake.nix` is only inputs plus Den evaluation.
- New features are added by editing Den modules, not `flake.nix`.

## Verification Plan

NOTE: Before running these checks make sure new files are being tracked by git
with `git add`

Run checks after each phase:

```sh
nix flake check --impure
```

Run representative NixOS builds:

```sh
nix build .#nixosConfigurations.carbon.config.system.build.toplevel
nix build .#nixosConfigurations.git.config.system.build.toplevel
nix build .#nixosConfigurations.pi4.config.system.build.toplevel
```

Run representative Home Manager builds:

```sh
nix build .#homeConfigurations."alejandro@carbon".activationPackage
nix build .#homeConfigurations."alejandro@minimal".activationPackage
```

Run deploy output evaluation before deploying:

```sh
nix eval .#deploy.nodes --apply builtins.attrNames
```

## Key Design Decisions

1. Keep `flake-parts` or move to Den-only outputs.
   - Recommended: keep `flake-parts` during migration, then decide after Den owns all outputs.

2. Use `den/` or `modules/` as the Den module tree.
   - Recommended: start with `den/` to avoid changing the meaning of existing `modules/nixos` and `modules/home` files.

3. Import existing lower-level modules or rewrite them as aspects.
   - Recommended: import first, rewrite gradually.

4. Use Den batteries for user and Home Manager integration or preserve current custom user/home modules.
   - Recommended: start by preserving current behavior, then replace custom glue with Den batteries when the equivalent behavior is clear.

5. Represent standalone homes separately or only through host users.
   - Recommended: keep standalone `homeConfigurations` because this repo already exposes them and users may rely on those outputs.

## Final Success Criteria

- Den is the source of truth for hosts, homes, users, and reusable aspects.
- Existing flake output names remain stable.
- `flake.nix` no longer coordinates individual hosts, homes, modules, packages, overlays, deploy nodes, or domains directly.
- `nix flake check` succeeds.
- Representative NixOS and Home Manager builds succeed.
- New host or feature additions do not require editing `flake.nix`.

## References

- https://den.oeiuwq.com/guides/migrate/
- Use contex7 for docs

## Pitfalls

- If you see an error about devenv not being able to determine the current directory, you likely need to specify `--impure`.
