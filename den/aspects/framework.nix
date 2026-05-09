{
  den.aspects.framework = {
    nixos = {
      imports = [ ../../systems/x86_64-linux/framework ];

      aa.home.extraOptions.imports = [ (../../homes/x86_64-linux + "/alejandro@framework") ];
    };
  };
}
