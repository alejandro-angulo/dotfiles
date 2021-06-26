set tabstop=4
set shiftwidth=4
set mouse=a
set updatetime=100
set expandtab
set number
set autoindent
set tags=tags;/
set laststatus=2
filetype plugin on
syntax on

" Run :PluginInstall to install plugins
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Eye Candy
Plugin 'chriskempson/base16-vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Git Integration
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'

" Fuzzy Finder
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" Comment Code
Plugin 'preservim/nerdcommenter'

" Navigate Code
Plugin 'preservim/nerdtree'

" Golang
Plugin 'fatih/vim-go'

" tmux Integration
Plugin 'christoomey/vim-tmux-navigator'

" tag management
Plugin 'ludovicchabant/vim-gutentags'

" linting
Plugin 'dense-analysis/ale'
call vundle#end()
filetype plugin indent on

" Toggle NERDTree
nmap <silent> <C-D> :NERDTreeToggle<CR>

" Toggle Tagbar
nnoremap <silent> <leader>b :TagbarToggle<CR>

" Turn of highlighting (until next search)
nnoremap <silent> <C-L> :noh<CR><C-L>

" Use tabs for makefile
autocmd Filetype make setlocal noexpandtab

" airline
let g:airline_theme='base16_vim'
let g:airline_powerline_fonts = 1

" Colorscheme
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
    source ~/.vimrc_background
endif

" Easier split navigation
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

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

" Project-specific config
silent! so .vimlocal
