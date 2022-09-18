{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./alacritty.nix
    ./git.nix
    ./git.nix
    ./mako.nix
    ./rofi.nix
    ./sway/sway.nix
    ./tmux.nix
    ./vim/vim.nix
    ./zsh.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "alejandro";
  home.homeDirectory = "/home/alejandro";

  home.packages = with pkgs; [
    kitty
    signal-desktop
    nodejs # For vim's CoC plugin
    pamixer # For sway binding to control audio
    # TODO: Remove this? Need to add programs.light.enable in system config
    #light  # For sway binding to control backlight
    #swaynagmode
    python310
    gammastep
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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
