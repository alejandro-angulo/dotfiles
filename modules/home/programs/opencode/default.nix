{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.programs.opencode;

  context7 = pkgs.writeShellApplication {
    name = "context7-mcp";
    runtimeInputs = [ pkgs.nodejs_24 ];
    text = ''
      npx -y @upstash/context7-mcp
    '';
  };
in
{
  options.${namespace}.programs.opencode = {
    enable = lib.mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      settings = {
        theme = "catppuccin";
        mcp = {
          context7 = {
            type = "local";
            command = [
              "${context7}/bin/context7-mcp"
            ];
            enabled = true;
          };
        };
      };
    };
  };
}
