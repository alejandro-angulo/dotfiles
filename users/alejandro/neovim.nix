{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [fzf fd];

  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    extraPython3Packages = ps: with ps; [black isort flake8 ipdb];
    #extraPackages = with pkgs; [];
    plugins = with pkgs.vimPlugins; [
      # tree-sitter (code parser)
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))

      # Eye candy
      nvim-web-devicons
      base16-vim

      # Telescope (fuzzy finding)
      {
        plugin = telescope-nvim;
        config = ''
          nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
          nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
          nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
          nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
        '';
      }
      {
        plugin = telescope-file-browser-nvim;
        type = "lua";
        config = ''
          vim.api.nvim_set_keymap(
            "n",
            "<space>fb",
            ":Telescope file_browser<CR>",
            { noremap = true }
          )
          require("telescope").load_extension("file_browser")
        '';
      }
      {
        plugin = telescope-coc-nvim;
        type = "lua";
        config = ''
          require("telescope").setup({
            extensions = {
              coc = {
                prefer_locations = true;
              }
            }
          })
          require("telescope").load_extension("coc")

          vim.api.nvim_set_keymap(
            "n",
            "<leader>coc",
            ":Telescope coc<CR>",
            { noremap = true }
          )
        '';
      }

      # tmux integration
      tmux-navigator
    ];

    coc = {
      enable = true;
      settings = ''
        {
          coc.preferences.formatOnSaveFiletypes": [
            "*"
          ],
          python.formatting.provider": "black"
        }
      '';
    };

    extraConfig = ''
      let mapleader = "'"

      " Colorscheme
      if !exists('g:colors_name') || g:colors_name != 'base16-darktooth'
        set background=dark
        let base16colorspace=256
        colorscheme base16-darktooth
        hi Normal ctermbg=NONE guibg=NONE
      endif
    '';
  };
}
