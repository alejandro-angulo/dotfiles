{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./alacritty.nix
    ./git.nix
    ./git.nix
    ./gpg.nix
    ./mako.nix
    ./rofi.nix
    ./sway/sway.nix
    ./tmux.nix
    #./vim/vim.nix
    ./neovim.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    kitty
    signal-desktop
    nodejs # For vim's CoC plugin
    pamixer # For sway binding to control audio
    # TODO: Remove this? Need to add programs.light.enable in system config
    #light  # For sway binding to control backlight
    #swaynagmode
    python310
    gammastep # Requires `services.geoclue2.enable` set in system config
    super-slicer

    firefox

    kanshi
    #pkgs.busybox

    playerctl
  ];

  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    #latitude = 34.0;
    #longitude = -118.4;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
