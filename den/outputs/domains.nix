# Generates domains output from Den host configurations
# Extracts nginx virtualHosts from hosts with extractDomains = true
{
  config,
  lib,
  ...
}:
let
  # Collect all hosts with extractDomains metadata across all platforms
  hostsWithDomains = lib.concatMapAttrs (
    platform: hosts: lib.filterAttrs (name: hostCfg: hostCfg.extractDomains or false) hosts
  ) config.den.hosts;

  # Get list of host names that have domain extraction enabled
  hostNames = lib.attrNames hostsWithDomains;

  # Filter nixosConfigurations to only include hosts with extractDomains
  relevantConfigs = lib.filterAttrs (
    name: _: lib.elem name hostNames
  ) config.flake.nixosConfigurations;

  # Extract domain names from nginx virtualHosts
  getDomainNames =
    cfgs: lib.mapAttrs (name: cfg: builtins.attrNames cfg.config.services.nginx.virtualHosts) cfgs;
in
{
  flake.domains = getDomainNames relevantConfigs;
}
