{
  den.aspects.carbon = {
    nixos = {
      imports = [ ../../systems/x86_64-linux/carbon ];

      home-manager.extraSpecialArgs.system = "x86_64-linux";
      aa.home.extraOptions.imports = [ (../../homes/x86_64-linux + "/alejandro@carbon") ];
    };
  };
}
