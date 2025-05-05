{
  lib,
  ...
}:
rec {
  getValues = keys: attrs: lib.attrsets.filterAttrs (name: value: builtins.elem name keys) attrs;

  getDomainNames =
    cfgs:
    lib.attrsets.mapAttrs (name: cfg: builtins.attrNames cfg.config.services.nginx.virtualHosts) cfgs;

  getDomainsPerHost = systemNames: nixosConfigs: getDomainNames (getValues systemNames nixosConfigs);
}
