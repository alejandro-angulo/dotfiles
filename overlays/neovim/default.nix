{ nixvim, ... }:
(final: prev: {
  neovim = nixvim.packages.${prev.stdenv.hostPlatform.system}.default;
})
