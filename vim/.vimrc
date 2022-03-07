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
"let g:ale_completion_enabled = 1
"let g:ale_completion_autoimport = 1
"let g:ale_set_ballons = 1

" Run :PluginInstall to install plugins
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Eye Candy
Plugin 'fnune/base16-vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ryanoasis/vim-devicons'
Plugin 'edkolev/tmuxline.vim'

" Git Integration
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'

" Fuzzy Finder
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" Comment Code
Plugin 'preservim/nerdcommenter'

" Navigate Code
Plugin 'preservim/nerdtree'

" tmux Integration
Plugin 'christoomey/vim-tmux-navigator'

" debugging
Plugin 'puremourning/vimspector'

" linting/fixing
"Plugin 'dense-analysis/ale'
Plugin 'neoclide/coc.nvim'

" extra syntax highlighting
"Plugin 'cespare/vim-toml'
Plugin 'hashivim/vim-terraform'
call vundle#end()
filetype plugin indent on

" Turn off highlighting (until next search)
nnoremap <silent> <C-L> :noh<CR><C-L>

" Use tabs for makefile
autocmd Filetype make setlocal noexpandtab

" airline
let g:airline_theme='base16_vim'
let g:airline_powerline_fonts = 1
let g:airline_base16_monotone = 1
"let g:airline#extensions#ale#enabled = 1

" Colorscheme
if filereadable(expand("~/.vimrc_background"))
  set background=dark
  let base16colorspace=256
  source ~/.vimrc_background
  hi Normal ctermbg=NONE guibg=NONE
endif

" Easier split navigation
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

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

" ALE
"nnoremap <Leader>fix :ALEFix<CR>
"nnoremap <Leader>def :ALEGoToDefinition<CR>
"nnoremap <Leader>ref :ALEFindReferences<CR>

"let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace']}
"let g:ale_fix_on_save = 1
"set omnifunc=ale#completion#OmniFunc
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
nmap <silent> gd :call CocAction('jumpDefinition', 'vsplit')<CR>
nmap <silent> gt :call CocAction('jumpDefinition', 'tabe')<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Project-specific config
silent! so .vimlocal
