{
  den.aspects.git = {
    nixos = {
      imports = [ ../../systems/x86_64-linux/git ];

      home-manager.extraSpecialArgs.system = "x86_64-linux";
      aa.home.extraOptions.imports = [ (../../homes/x86_64-linux + "/alejandro@git") ];
    };
  };
}
