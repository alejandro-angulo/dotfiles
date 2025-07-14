{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.programs.opencode;
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
            type = "remote";
            url = "https://mcp.context7.com/mcp";
            enabled = true;
          };
        };
      };
    };
  };
}
