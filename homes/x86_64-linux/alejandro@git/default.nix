{ ... }:
{
  aa = {
    installDefaults = false;

    tools = {
      eza.enable = true;
      zsh.enable = true;
    };
  };

  nix.gc = {
    automatic = true;
    options = "-d";
    frequency = "03:15";
  };
}
