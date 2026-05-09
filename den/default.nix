{
  imports = [
    ./den.nix
    ./defaults.nix
    ./outputs

    # Feature aspects
    ./aspects/direnv.nix
    ./aspects/eza.nix
    ./aspects/fzf.nix
    ./aspects/openssh.nix
    ./aspects/zoxide.nix
    ./aspects/tailscale.nix
    ./aspects/fonts.nix
    ./aspects/phase1-smoke.nix

    # Host aspects and configs
    ./hosts/carbon.nix
    ./aspects/carbon.nix
    ./aspects/carbon-home.nix
    ./homes/carbon.nix

    ./hosts/framework.nix
    ./aspects/framework.nix
    ./aspects/framework-home.nix
    ./homes/framework.nix

    ./hosts/git.nix
    ./aspects/git.nix
    ./aspects/git-home.nix
    ./homes/git.nix

    ./hosts/gospel.nix
    ./aspects/gospel.nix
    ./aspects/gospel-home.nix
    ./homes/gospel.nix

    ./hosts/node.nix
    ./aspects/node.nix
    ./aspects/node-home.nix
    ./homes/node.nix

    ./hosts/pi4.nix
    ./aspects/pi4.nix
    ./aspects/pi4-home.nix
    ./homes/pi4.nix

    # Standalone homes
    ./aspects/minimal-home.nix
    ./homes/minimal.nix
  ];
}
