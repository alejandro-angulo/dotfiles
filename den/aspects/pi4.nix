{
  den.aspects.pi4 = {
    nixos = {
      imports = [ ../../systems/aarch64-linux/pi4 ];

      home-manager.extraSpecialArgs.system = "aarch64-linux";
      aa.home.extraOptions.imports = [ (../../homes/aarch64-linux + "/alejandro@pi4") ];
    };
  };
}
