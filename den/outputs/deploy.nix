# Generates deploy.nodes output from Den host configurations
# Uses deploy metadata stored in den.hosts freeform attributes
{
  inputs,
  config,
  lib,
  ...
}:
let
  # Build deploy node for a single host
  mkDeployNode =
    platform: hostName: hostCfg:
    let
      deployCfg = hostCfg.deploy;
      nixosCfg = config.flake.nixosConfigurations.${hostName};

      # For aarch64-linux, we need the deploy-rs overlay workaround
      deployLib =
        if platform == "aarch64-linux" then
          let
            pkgs = import inputs.nixpkgs { system = platform; };
            deployPkgs = import inputs.nixpkgs {
              system = platform;
              overlays = [
                inputs.deploy-rs.overlays.default
                (self: super: {
                  deploy-rs = {
                    inherit (pkgs) deploy-rs;
                    lib = inputs.deploy-rs.lib;
                  };
                })
              ];
            };
          in
          deployPkgs.deploy-rs.lib.${platform}
        else
          inputs.deploy-rs.lib.${platform};
    in
    {
      hostname = deployCfg.hostname;
      profiles.system = {
        user = deployCfg.user;
        sshUser = deployCfg.sshUser;
        path = deployLib.activate.nixos nixosCfg;
      }
      // lib.optionalAttrs (deployCfg.sshOpts != [ ]) { sshOpts = deployCfg.sshOpts; }
      // lib.optionalAttrs deployCfg.remoteBuild { remoteBuild = true; };
    };

  # Collect all deploy nodes from all platforms
  allDeployNodes = lib.concatMapAttrs (
    platform: hosts:
    lib.mapAttrs' (
      hostName: hostCfg: lib.nameValuePair hostName (mkDeployNode platform hostName hostCfg)
    ) (lib.filterAttrs (name: hostCfg: hostCfg.deploy.enable or false) hosts)
  ) config.den.hosts;
in
{
  flake.deploy.nodes = allDeployNodes;
}
