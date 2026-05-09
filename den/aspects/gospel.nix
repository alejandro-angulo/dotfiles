{
  den.aspects.gospel = {
    nixos = {
      imports = [ ../../systems/x86_64-linux/gospel ];

      home-manager.extraSpecialArgs.system = "x86_64-linux";
      aa.home.extraOptions.imports = [ (../../homes/x86_64-linux + "/alejandro@gospel") ];
    };
  };
}
