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

      # git integration
      gitgutter
      fugitive
      rhubarb

      # coc plugins
      coc-json
      coc-yaml
      coc-pyright
      coc-spell-checker
      coc-rust-analyzer

      # Eye candy
      nvim-web-devicons
      # base16-vim
      nvim-base16

      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup {
          options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = ''},
            section_separators = { left = '', right = ''},
            disabled_filetypes = {
            statusline = {},
            winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = true,
            globalstatus = false,
            refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
            }
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'filename'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
          },
          tabline = {},
          winbar = {},
          inactive_winbar = {},
          extensions = {}
          }
        '';
      }

      # tmux integration
      tmux-navigator
      tmuxline-vim

      vim-obsession
      vim-nix

      # Telescope (fuzzy finding)
      telescope-nvim # Config for this in `extraConfig` since it depends on <leader> and I override that. (Generated config places plugin config above contents of extraConfig
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

      # Copied the below from coc's README
      pluginConfig =
        ''
          " Some servers have issues with backup files, see #649.
          set nobackup
          set nowritebackup

          " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
          " delays and poor user experience.
          set updatetime=300

          " Always show the signcolumn, otherwise it would shift the text each time
          " diagnostics appear/become resolved.
          set signcolumn=yes

          " Use tab for trigger completion with characters ahead and navigate.
          " NOTE: There's always complete item selected by default, you may want to enable
          " no select by `"suggest.noselect": true` in your configuration file.
          " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
          " other plugin before putting this into your config.
          inoremap <silent><expr> <TAB>
          	  \ coc#pum#visible() ? coc#pum#next(1) :
          	  \ CheckBackspace() ? "\<Tab>" :
          	  \ coc#refresh()
          inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

          " Make <CR> to accept selected completion item or notify coc.nvim to format
          " <C-g>u breaks current undo, please make your own choice.
          inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
          							  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

          function! CheckBackspace() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~# '\s'
          endfunction

          " Use <c-space> to trigger completion.
          if has('nvim')
            inoremap <silent><expr> <c-space> coc#refresh()
          else
            inoremap <silent><expr> <c-@> coc#refresh()
          endif

          " Use `[g` and `]g` to navigate diagnostics
          " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
          nmap <silent> [g <Plug>(coc-diagnostic-prev)
          nmap <silent> ]g <Plug>(coc-diagnostic-next)

          " GoTo code navigation.
          nmap <silent> gd <Plug>(coc-definition)
          nmap <silent> gy <Plug>(coc-type-definition)
          nmap <silent> gi <Plug>(coc-implementation)
          nmap <silent> gr <Plug>(coc-references)

          " Use K to show documentation in preview window.
          nnoremap <silent> K :call ShowDocumentation()<CR>

          function! ShowDocumentation()
            if CocAction('hasProvider', 'hover')
          	call CocActionAsync('doHover')
            else
          	call feedkeys('K', 'in')
            endif
          endfunction

          " Highlight the symbol and its references when holding the cursor.
          autocmd CursorHold * silent call CocActionAsync('highlight')

          " Symbol renaming.
          nmap <leader>rn <Plug>(coc-rename)

          " Formatting selected code.
          xmap <leader>f  <Plug>(coc-format-selected)
          nmap <leader>f  <Plug>(coc-format-selected)

          augroup mygroup
            autocmd!
            " Setup formatexpr specified filetype(s).
            autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
            " Update signature help on jump placeholder.
            autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
          augroup end

          " Applying codeAction to the selected region.
          " Example: `<leader>aap` for current paragraph
          xmap <leader>a  <Plug>(coc-codeaction-selected)
          nmap <leader>a  <Plug>(coc-codeaction-selected)

          " Remap keys for applying codeAction to the current buffer.
          nmap <leader>ac  <Plug>(coc-codeaction)
          " Apply AutoFix to problem on the current line.
          nmap <leader>qf  <Plug>(coc-fix-current)

          " Run the Code Lens action on the current line.
          nmap <leader>cl  <Plug>(coc-codelens-action)

          " Map function and class text objects
          " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
          xmap if <Plug>(coc-funcobj-i)
          omap if <Plug>(coc-funcobj-i)
          xmap af <Plug>(coc-funcobj-a)
          omap af <Plug>(coc-funcobj-a)
          xmap ic <Plug>(coc-classobj-i)
          omap ic <Plug>(coc-classobj-i)
          xmap ac <Plug>(coc-classobj-a)
          omap ac <Plug>(coc-classobj-a)

          " Remap <C-f> and <C-b> for scroll float windows/popups.
          if has('nvim-0.4.0') || has('patch-8.2.0750')
            nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
            nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
            inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
            inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
            vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
            vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
          endif

          " Use CTRL-S for selections ranges.
          " Requires 'textDocument/selectionRange' support of language server.
          nmap <silent> <C-s> <Plug>(coc-range-select)
          xmap <silent> <C-s> <Plug>(coc-range-select)

          " Add `:Format` command to format current buffer.
          command! -nargs=0 Format :call CocActionAsync('format')

          " Add `:Fold` command to fold current buffer.
          command! -nargs=? Fold :call     CocAction('fold', <f-args>)

          " Add `:OR` command for organize imports of the current buffer.
          command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

          " Add (Neo)Vim's native statusline support.
          " NOTE: Please see `:h coc-status` for integrations with external plugins that
          " provide custom statusline: lightline.vim, vim-airline.
                set statusline^=%{coc#status()}%{get(b:,'coc_current_function',''
        + "''"
        + ''          )}

          " Mappings for CoCList
          " Show all diagnostics.
          nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
          " Manage extensions.
          nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
          " Show commands.
          nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
          " Find symbol of current document.
          nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
          " Search workspace symbols.
          nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
          " Do default action for next item.
          nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
          " Do default action for previous item.
          nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
          " Resume latest coc list.
          nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

        ''
        # The below is custom and did not come from coc's README
        + ''
          " GoTo code navigation.
          nmap <silent> gd <Plug>(coc-definition)
          nmap <silent> gs :call CocAction('jumpDefinition', 'split')<CR>
          nmap <silent> gv :call CocAction('jumpDefinition', 'vsplit')<CR>
          nmap <silent> gn :call CocAction('jumpDefinition', 'tabe')<CR>
          nmap <silent> gy <Plug>(coc-type-definition)
          nmap <silent> gi <Plug>(coc-implementation)
          nmap <silent> gr <Plug>(coc-references)
        '';
    };

    extraConfig = ''
      set tabstop=4
      set shiftwidth=4
      set mouse=a
      set expandtab
      set number
      set autoindent
      syntax on
      let mapleader = "`"

      " Eye Candy (selects theme and sets up transparency)
      colorscheme base16-darktooth
      hi Normal guibg=none ctermbg=none
      hi NormalNC guibg=NONE
      hi LineNr guibg=none ctermbg=none
      hi Folded guibg=none ctermbg=none
      hi NonText guibg=none ctermbg=none
      hi SpecialKey guibg=none ctermbg=none
      hi VertSplit guibg=none ctermbg=none
      hi SignColumn guibg=none ctermbg=none
      hi EndOfBuffer guibg=none ctermbg=none

      " Toggle line highlighting based on focus
      autocmd BufEnter * setlocal cursorline
      autocmd BufLeave * setlocal nocursorline

      " Toggle relative line numbers
      nmap <leader>num :set invrelativenumber<CR>

      " Bindings for telescope-nvim
      nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
      nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
      nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
      nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

      " coc
      nnoremap <Leader>cmd :CocCommand<CR>
      nnoremap <Leader>cfg :CocConfig<CR>
      nnoremap <Leader>def :call CocAction('jumpDefinition')<CR>
      nnoremap <Leader>fmt :call CocActionAsync('format')<CR>
      vmap <leader>a <Plug>(coc-codeaction-selected)
      nmap <leader>a <Plug>(coc-codeaction-selected)

      " rhubarb
      noremap <Leader>bro :GBrowse<CR>

      " Tab completion
      set wildmode=longest,list,full
      set wildmenu
    '';
  };
}
