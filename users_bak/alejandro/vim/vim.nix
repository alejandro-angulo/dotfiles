{
  config,
  pkgs,
  ...
}: {
  # home.packages = [ pkgs.vim ];
  home.packages = [pkgs.fzf];

  programs.vim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      base16-vim
      vim-airline
      vim-airline-themes
      vim-devicons
      tmuxline-vim

      gitgutter
      fugitive
      rhubarb

      fzf-vim

      nerdcommenter
      nerdtree

      tmux-navigator

      vimspector

      ale
      coc-nvim
      # TODO: Add coc plugins

      vim-obsession
    ];

    extraConfig = ''
      set tabstop=4
      set shiftwidth=4
      set mouse=a
      set ttymouse=sgr
      set mousemodel=popup_setpos
      set updatetime=100
      set expandtab
      set number
      set autoindent
      set laststatus=2
      set encoding=utf-8
      syntax on

      let mapleader = "'"

      " ALE (need to happen before ALE loaded)
      let g:ale_display_lsp = 1

      filetype plugin indent on

      " Use tabs for makefile
      autocmd Filetype make setlocal noexpandtab

      " Toggle line highlighting based on focus
      autocmd BufEnter * setlocal cursorline
      autocmd BufLeave * setlocal nocursorline

      " airline
      let g:airline_theme='base16_vim'
      let g:airline_powerline_fonts = 1

      " Colorscheme
      if !exists('g:colors_name') || g:colors_name != 'base16-darktooth'
        set background=dark
        let base16colorspace=256
        colorscheme base16-darktooth
        hi Normal ctermbg=NONE guibg=NONE
      endif

      " Toggle relative line numbers
      nmap <leader>num :set invrelativenumber<CR>

      " Tab completion
      set wildmode=longest,list,full
      set wildmenu

      " Move splits
      function! MarkWindowSwap()
        let g:markedWinNum = winnr()
       endfunction

       function! DoWindowSwap()
        " Mark destination
        let curnum = winnr()
        let curBut = bufnr( "%" )
        " Switch to source and shuffle dest->source
        let markedBuf = bufnr( "%" )
        " Hide and open so that we aren't prompted and keep history
        exe 'hide buf' curBuf
        " Switch to dest and shuffle source->dest
        exe curnum . "wincmd w"
        " Hide and open so that we aren't prompted and keep history
        exe 'hide buf' markedBuf
      endfunction

      nmap <silent> <leader>mv :call MarkWindowSwap()<CR>
      nmap <silent> <leader>pw :call DoWindowSwap()<CR>

      " NERDTree
      nnoremap <leader>n :NERDTreeFocus<CR>
      nnoremap <C-n> :NERDTree<CR>
      nnoremap <C-t> :NERDTreeToggle<CR>
      nnoremap <C-f> :NERDTreeFind<CR>

      let g:NERDTreeQuitOnOpen = 1
      let g:NERDTreeShowHidden = 1

      " vimspector
      let g:vimspector_enable_mappings = 'HUMAN'
      let g:vimspector_enable_gadgets = ['debugpy', 'CodeLLDB']
      let g:vimspector_base_dir = expand('$HOME/.vim/bundle/vimspector')

      nmap <Leader>di <Plug>VimspectorBalloonEval
      xmap <Leader>di <Plug>VimspectorBalloonEval

      " fzf
      nnoremap <C-P> :GFiles<CR>
      nnoremap <C-G> :Rg<CR>

      " coc.nvim
      inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

      " use <tab> for trigger completion and navigate to the next complete item
      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
      endfunction

      inoremap <silent><expr> <Tab>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<Tab>" :
            \ coc#refresh()

      " uses tab and shift-tab to navigate completion list
      inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
      inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

      nnoremap <Leader>cmd :CocCommand<CR>
      nnoremap <Leader>cfg :CocConfig<CR>
      nnoremap <Leader>def :call CocAction('jumpDefinition')<CR>
      nnoremap <Leader>fmt :call CocActionAsync('format')<CR>
      noremap <Leader>bro :GBrowse<CR>

      " GoTo code navigation.
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gs :call CocAction('jumpDefinition', 'split')<CR>
      nmap <silent> gv :call CocAction('jumpDefinition', 'vsplit')<CR>
      nmap <silent> gn :call CocAction('jumpDefinition', 'tabe')<CR>
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)

      " Project-specific config
      silent! so .vimlocal
    '';
  };
}
