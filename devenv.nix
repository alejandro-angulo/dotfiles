{ pkgs, ... }:
{
  packages = [
    pkgs.nixfmt-rfc-style
    pkgs.nixd
    pkgs.deploy-rs
    pkgs.git
  ];

  git-hooks.hooks = {
    # Basic file hygiene
    trim-trailing-whitespace.enable = true;
    end-of-file-fixer.enable = true;
    check-yaml.enable = true;
    check-added-large-files = {
      enable = true;
      excludes = [ ".*\\.png$" ];
    };
    nixfmt-rfc-style.enable = true;
  };
}
