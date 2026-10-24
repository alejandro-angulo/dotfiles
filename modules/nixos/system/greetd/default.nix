{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    mkEnableOption
    mkIf
    mkOption
    optionals
    types
    ;

  cfg = config.aa.system.greetd;

  # Sessions registered through `services.displayManager.sessionPackages`
  # (e.g. `programs.hyprland.enable`) end up in a store path rather than
  # /usr/share, and the greetd service does not inherit a useful
  # XDG_DATA_DIRS, so the greeter is pointed at them explicitly.
  sessionDirs = config.services.displayManager.sessionData.desktops;

  # tuigreet runs power commands as the `greeter` user, which is not
  # authorized to call systemctl directly. Wrapper scripts keep quoting
  # simple and the polkit rule below grants the greeter access.
  # NOTE: tuigreet 0.11 (the 2026 rewrite) dropped `--power-suspend` and
  # `--power-hibernate`; passing unknown options makes the greeter exit
  # before starting, which crash-loops greetd into start-limit-hit.
  powerActions = {
    shutdown = "poweroff";
    reboot = "reboot";
  };

  powerScripts = builtins.mapAttrs (
    name: action:
    pkgs.writeShellScriptBin "greetd-${name}" "exec ${config.systemd.package}/bin/systemctl ${action}"
  ) powerActions;

  greeter = pkgs.writeShellScriptBin "tuigreet-greeter" (
    concatStringsSep " " (
      [
        "exec ${lib.getExe pkgs.tuigreet}"
        "--time"
        "--greeting ${escapeShellArg cfg.greeting}"
        # Matrix rain by default; tuigreet's background menu (F4) can switch
        # it at runtime.
        "--background matrix"
        "--sessions ${sessionDirs}/share/wayland-sessions"
        "--xsessions ${sessionDirs}/share/xsessions"
      ]
      ++ optionals cfg.powerControls [
        "--power-shutdown ${powerScripts.shutdown}/bin/greetd-shutdown"
        "--power-reboot ${powerScripts.reboot}/bin/greetd-reboot"
      ]
    )
  );

in
{
  options.aa.system.greetd = {
    enable = mkEnableOption "greetd with the tuigreet greeter";
    greeting = mkOption {
      type = types.str;
      default = "Welcome to ${config.networking.hostName}";
      description = "Greeting message shown by the greeter.";
    };
    powerControls = mkOption {
      type = types.bool;
      default = true;
      description = "Expose shutdown/reboot actions in the greeter (F12).";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = "${greeter}/bin/tuigreet-greeter";
    };

    security.polkit.enable = true;

    security.polkit.extraConfig = mkIf cfg.powerControls ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "greeter") {
          if (action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.reboot") {
            return polkit.Result.YES;
          }
        }
      });
    '';
  };
}
