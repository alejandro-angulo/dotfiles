{
  den.aspects.framework = {
    nixos = {
      imports = [ ../../systems/x86_64-linux/framework ];

      home-manager.extraSpecialArgs.system = "x86_64-linux";
      aa.home.extraOptions.imports = [ (../../homes/x86_64-linux + "/alejandro@framework") ];
    };
  };
}
