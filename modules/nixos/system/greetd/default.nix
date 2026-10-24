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
  powerActions = {
    shutdown = "poweroff";
    reboot = "reboot";
    suspend = "suspend";
    hibernate = "hibernate";
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
        "--theme ${escapeShellArg cfg.theme}"
        "--sessions ${sessionDirs}/share/wayland-sessions"
        "--xsessions ${sessionDirs}/share/xsessions"
      ]
      ++ optionals cfg.powerControls [
        "--power-shutdown ${powerScripts.shutdown}/bin/greetd-shutdown"
        "--power-reboot ${powerScripts.reboot}/bin/greetd-reboot"
        "--power-suspend ${powerScripts.suspend}/bin/greetd-suspend"
        "--power-hibernate ${powerScripts.hibernate}/bin/greetd-hibernate"
      ]
    )
  );

  # Catppuccin Mocha
  defaultTheme = concatStringsSep ";" [
    "border=#cba6f7"
    "text=#cdd6f4"
    "time=#89dceb"
    "container=#1e1e2e"
    "title=#b4befe"
    "greet=#f9e2af"
    "prompt=#a6e3a1"
    "input=#cdd6f4"
    "action=#89b4fa"
    "button=#f38ba8"
  ];
in
{
  options.aa.system.greetd = {
    enable = mkEnableOption "greetd with the tuigreet greeter";
    greeting = mkOption {
      type = types.str;
      default = "Welcome to ${config.networking.hostName}";
      description = "Greeting message shown by the greeter.";
    };
    theme = mkOption {
      type = types.str;
      default = defaultTheme;
      description = "tuigreet theme specification (see tuigreet(1)).";
    };
    powerControls = mkOption {
      type = types.bool;
      default = true;
      description = "Expose shutdown/reboot/suspend/hibernate actions in the greeter (F12).";
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
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.suspend" ||
              action.id == "org.freedesktop.login1.hibernate") {
            return polkit.Result.YES;
          }
        }
      });
    '';
  };
}
