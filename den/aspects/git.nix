{
  den.aspects.git = {
    nixos = {
      imports = [ ../../systems/x86_64-linux/git ];

      aa.home.extraOptions.imports = [ (../../homes/x86_64-linux + "/alejandro@git") ];
    };
  };
}
