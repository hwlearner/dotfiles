"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/share/nvim/plugged')

Plug 'junegunn/vim-easy-align'

" colorschemes
Plug 'arcticicestudio/nord-vim'
Plug 'mhinz/vim-startify'
Plug 'itchyny/lightline.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

" utilities
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth' " detect indent style (tabs vs. spaces)
Plug 'airblade/vim-gitgutter' " git diff displaying
Plug '/usr/bin/fzf'
Plug 'junegunn/fzf.vim'

" auto completion
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'

" language-specific plugins
Plug 'autozimu/LanguageClient-neovim', {
  \ 'rev': 'next',
  \ 'build': 'bash install.sh',
  \ }
Plug 'vhda/verilog_systemverilog.vim'
Plug 'lervag/vimtex'

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" disable startup message
set shortmess+=cI

" set a map leader for more key combos
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"

" swap ; and : in normal mode for ease of use
noremap : ;
noremap ; :

set history=1000 " change history to 1000
set textwidth=120

" Tab control
set expandtab " insert tabs rather than spaces for <Tab>
set tabstop=4 " the visible width of tabs
set softtabstop=4 " edit as if the tabs are 4 characters wide
set shiftwidth=4 " number of spaces to use for indent and unindent
set shiftround " round indent to a multiple of 'shiftwidth'
set completeopt+=longest

set clipboard+=unnamedplus

"let g:python3_host_prog = 'C:\Program Files (x86)\Microsoft Visual Studio\Shared\Anaconda3_64\python.exe'

set diffopt+=vertical

" highlight conflicts
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" code folding settings
set foldmethod=syntax " fold based on indent
set foldnestmax=10 " deepest fold is 10 levels
set nofoldenable " don't fold by default
set foldlevel=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => User Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set hidden " current buffer can be put into background
set noshowmode " don't show which mode disabled for PowerLine
set termguicolors

" Searching
set ignorecase " case insensitive searching
set smartcase " case-sensitive if expresson contains a capital letter

set magic " Set magic on, for regex

set showmatch " show matching braces
set mat=2 " how many tenths of a second to blink

" error bells
set noerrorbells
set visualbell
set t_vb=
set tm=500

" switch syntax highlighting on
syntax on

" turn on file type detection and enable filetype plugins and indentation
filetype plugin indent on

colorscheme nord

" Make the background transparent
highlight Normal guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE

set number " show line numbers
set relativenumber " show relative line numbers
set cursorline " highlight the line which cursor is on

set wrap "turn on line wrapping
set wrapmargin=8 " wrap lines when coming within n characters from side
set linebreak " set soft wrapping
set showbreak=… " show ellipsis at breaking

" toggle invisible characters
set invlist
set listchars=tab:▸\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
highlight SpecialKey ctermbg=NONE " make the highlighting of tabs less annoying
set showbreak=↪

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Startup Screen
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" startify options
let g:startify_custom_header = startify#fortune#boxed()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => StatusLine
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" lightline configuration
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'subseparator': { 'left': '', 'right': '' },
      \ 'active' : {
      \   'left':  [ [ 'mode', 'paste' ],
      \              [ 'readonly', 'fugitive', 'filename'] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'filetype', 'fileformat', 'fileencoding' ] ] },
      \ 'inactive' : {
      \   'left':  [ [ 'filename' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ] ] },
      \ 'tab' : {
      \   'active': [ 'tabnum', 'filename' ],
      \   'inactive': [ 'tabnum', 'filename' ] },
      \ 'tabline' : {
      \   'left':  [ [ 'tabs' ] ],
      \   'right': [ [  ] ] },
      \ 'mode_map' : {
      \   'n':      '覽',
      \   'i':      '寫',
      \   'R':      '換',
      \   'v':      '選',
      \   'V':      '橫',
      \   "\<C-v>": '縱',
      \   'c':      '令',
      \   's':      '選',
      \   'S':      '橫',
      \   "\<C-s>": '縱',
      \   't':      ' ' },
      \ 'component_function': {
      \   'filename':   'LightlineFilename',
      \   'filetype':   'LightlineFiletype',
      \   'fileformat': 'LightlineFileformat',
      \   'readonly':   'LightlineReadonly',
      \   'paste':      'LightlinePaste',
      \   'fugitive':   'LightlineFugitive' },
      \ }

" Component functions for lightline
function! LightlinePaste()
    return winwidth(0) > 70 ? (&paste ? ' ' : '') : ''
endfunction
function! LightlineFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? WebDevIconsGetFileTypeSymbol() : ' ') : ''
endfunction
function! LightlineFileformat()
    return winwidth(0) > 70 ? WebDevIconsGetFileFormatSymbol() : ''
endfunction
function! LightlineReadonly()
    return &readonly ? '' : ''
endfunction
function! LightlineFugitive()
    if exists('*fugitive#head')
        let branch = fugitive#head()
        return branch !=# '' ? ' '.branch : ''
    endif
    return ''
endfunction
function! LightlineFilename()
    let filename = expand('%:t') !=# '' ? expand('%:t') : '無名'
    let modified = &modified ? ' •' : ''
    return filename . modified
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General mappings/shortcuts for functionality
" Additional, plugin-specific mappings are located under
" the plugins section

" Enter command mode
nnoremap <Leader><Leader> :

" Reload vim configuration
nnoremap <Leader>feR :source %<CR>

" Quick split
nnoremap <Leader>ws :split<CR>

" Quick vertical split
nnoremap <Leader>wv :vsplit<CR>

" Quick switching windows
nnoremap <Leader>wh :wincmd h<CR>
nnoremap <Leader>wj :wincmd j<CR>
nnoremap <Leader>wk :wincmd k<CR>
nnoremap <Leader>wl :wincmd l<CR>

" Quick closing windows
nnoremap <Leader>wd :wincmd q<CR>

" Quick spawn a terminal
nnoremap <Leader>at :terminal<CR>

" Quick save
nnoremap <Leader>fs :w<CR>

" Quick quit
nnoremap <Leader>qq :q<CR>

" Quick search git project files
nnoremap <Leader>ff :e 
nnoremap <Leader>pf :GFiles<CR>

" Quick search all files in the working directory
nnoremap <Leader>fL :Files ~<CR>

" Quick select buffers
nnoremap <Leader>bb :Buffers<CR>

" Quick look up help
nnoremap <Leader>h<Space> :help 

" Quick select snippets
nnoremap <Leader>is :Snippets<CR>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap <leader>xa <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap <leader>xa <Plug>(EasyAlign)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" goyo settings
let g:goyo_width = 160
let g:goyo_height = '90%'
let g:goyo_linenr = 1

" autocmd! User GoyoEnter Limelight
" autocmd! User GoyoLeave Limelight!

" language client settings
let g:LanguageClient_serverCommands = {
    \ 'python': ['/home/han/.local/bin/pyls'],
    \ }

" ncm2 settings
" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANTE: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
" Use <C-j> and <C-k> to select the popup menu:
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

" vimtex settings
augroup my_cm_setup
  autocmd!
  autocmd BufEnter * call ncm2#enable_for_buffer()
  autocmd Filetype tex call ncm2#register_source({
          \ 'name' : 'vimtex-cmds',
          \ 'priority': 8, 
          \ 'complete_length': -1,
          \ 'scope': ['tex'],
          \ 'matcher': {'name': 'prefix', 'key': 'word'},
          \ 'word_pattern': '\w+',
          \ 'complete_pattern': g:vimtex#re#ncm2#cmds,
          \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
          \ })
  autocmd Filetype tex call ncm2#register_source({
          \ 'name' : 'vimtex-labels',
          \ 'priority': 8, 
          \ 'complete_length': -1,
          \ 'scope': ['tex'],
          \ 'matcher': {'name': 'combine',
          \             'matchers': [
          \               {'name': 'substr', 'key': 'word'},
          \               {'name': 'substr', 'key': 'menu'},
          \             ]},
          \ 'word_pattern': '\w+',
          \ 'complete_pattern': g:vimtex#re#ncm2#labels,
          \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
          \ })
  autocmd Filetype tex call ncm2#register_source({
          \ 'name' : 'vimtex-files',
          \ 'priority': 8, 
          \ 'complete_length': -1,
          \ 'scope': ['tex'],
          \ 'matcher': {'name': 'combine',
          \             'matchers': [
          \               {'name': 'abbrfuzzy', 'key': 'word'},
          \               {'name': 'abbrfuzzy', 'key': 'abbr'},
          \             ]},
          \ 'word_pattern': '\w+',
          \ 'complete_pattern': g:vimtex#re#ncm2#files,
          \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
          \ })
  autocmd Filetype tex call ncm2#register_source({
          \ 'name' : 'bibtex',
          \ 'priority': 8, 
          \ 'complete_length': -1,
          \ 'scope': ['tex'],
          \ 'matcher': {'name': 'combine',
          \             'matchers': [
          \               {'name': 'prefix', 'key': 'word'},
          \               {'name': 'abbrfuzzy', 'key': 'abbr'},
          \               {'name': 'abbrfuzzy', 'key': 'menu'},
          \             ]},
          \ 'word_pattern': '\w+',
          \ 'complete_pattern': g:vimtex#re#ncm2#bibtex,
          \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
          \ })
augroup END
