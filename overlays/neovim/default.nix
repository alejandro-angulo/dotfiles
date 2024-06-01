{nixvim, ...}: (final: prev: {
  neovim = nixvim.packages.${prev.system}.default;
})
