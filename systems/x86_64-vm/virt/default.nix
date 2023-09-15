{
  pkgs,
  lib,
  ...
}:
with lib; {
  virtualisation.qemu.options = ["-vga qxl"];

  # For sway to work with home manager
  security.polkit.enable = true;

  # Without this, sway fails to start in the VM
  # programs.sway.extraSessionCommands = ''
  #   WLR_NO_HARDWARE_CURSORS=1
  # '';

  aa = {
    nix.enable = true;

    suites.desktop.enable = true;
    tools.git.enable = true;
    tools.zsh.enable = true;
    tools.eza.enable = true;
    apps.neovim.enable = true;
    apps.tmux.enable = true;
  };

  users.users.virt = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    hashedPassword = "$6$nOlwKVf1u0Wt//zU$43xhafbe2CAWTjOemAUm1J1Dpw7to0ZTbGhFk7CkVTRB3E80a1lhhQ175VnkcJ/X1HI6lsyV8fNMc3GF7JTAP0";
  };

  environment = {
    systemPackages = with pkgs; [
      wayland-utils
    ];
    variables = {"WLR_RENDERER_ALLOW_SOFTWARE" = "1";};
  };
}
