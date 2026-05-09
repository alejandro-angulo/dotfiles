{
  description = "My Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    den.url = "github:vic/den";

    import-tree.url = "github:vic/import-tree";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixvim.url = "git+https://git.alejandr0angul0.dev/alejandro-angulo/nixvim-config?ref=main";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    zsh-syntax-highlighting.url = "github:zsh-users/zsh-syntax-highlighting/master";
    zsh-syntax-highlighting.flake = false;

    powerlevel10k.url = "github:romkatv/powerlevel10k/master";
    powerlevel10k.flake = false;

    catppuccin-nix-palette.url = "git+https://git.alejandr0angul0.dev/alejandro-angulo/catppuccin-nix-palette?ref=main";
  };

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./den) ];
      specialArgs.inputs = inputs;
    }).config.flake;
}
