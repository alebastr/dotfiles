set nocompatible

function! LoadIf(cond, ...)
    let l:opts = get(a:000, 0, {})
    return a:cond ? l:opts : extend(l:opts, {'on': [], 'for': [] })
endfunction

call plug#begin(has('win32') ? '~/vimfiles/bundle' : '~/.vim/bundle')
let has_async = has('timers') && ((has('job') && has('channel')) || has('nvim'))
let has_nvim_lsp = has('nvim')

" Workaround for vim/vim#3117
try | exec 'pythonx' 'pass' | catch | endtry

" Let's start from this
Plug 'tpope/vim-sensible'

" Look and feel
Plug 'vim-scripts/xterm16.vim'
Plug 'nanotech/jellybeans.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'vim-scripts/let-modeline.vim'
Plug 'jlanzarotta/bufexplorer', LoadIf(!executable('fzf'))

" Behavior/General
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'sjl/gundo.vim'
Plug 'tomtom/tcomment_vim' " gc{motion}, gc<count>c{motion}, gcc
Plug 'tpope/vim-surround'

if executable('fzf')
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
else
    Plug 'ctrlpvim/ctrlp.vim'
endif

" Behavior/Integration
Plug 'SirVer/ultisnips', LoadIf(has('python3'))
Plug 'honza/vim-snippets'
Plug 'mattn/emmet-vim'
Plug 'vim-syntastic/syntastic', LoadIf(!has_async)
Plug 'dense-analysis/ale', LoadIf(has_async)
Plug 'sbdchd/neoformat'
Plug 'jamessan/vim-gnupg'

" Version Control
"Plug 'http://repo.or.cz/r/vcscommand.git' " p4/hg/etc...
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Language Server
Plug 'neovim/nvim-lspconfig', LoadIf(has_nvim_lsp)
Plug 'p00f/clangd_extensions.nvim', LoadIf(has_nvim_lsp)
Plug 'ojroques/nvim-lspfuzzy', LoadIf(has_nvim_lsp)

" Completion
Plug 'hrsh7th/cmp-nvim-lsp', LoadIf(has_nvim_lsp)
Plug 'hrsh7th/cmp-buffer', LoadIf(has_nvim_lsp)
Plug 'hrsh7th/cmp-path', LoadIf(has_nvim_lsp)
Plug 'hrsh7th/cmp-cmdline', LoadIf(has_nvim_lsp)
Plug 'hrsh7th/nvim-cmp', LoadIf(has_nvim_lsp)
Plug 'quangnguyen30192/cmp-nvim-ultisnips', LoadIf(has_nvim_lsp)

" Languages
Plug 'nvim-treesitter/nvim-treesitter', LoadIf(has('nvim'), { 'do': ':TSUpdate' })
Plug 'PProvost/vim-ps1'
"Plug  'adelarsq/neofsharp.vim'
"Plug 'fsharp/vim-fsharp', {'for': 'fsharp'}
"Plug 'othree/yajs.vim'
"Plug 'othree/xml.vim'
Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
Plug 'rust-lang/rust.vim'
Plug 'habamax/vim-asciidoctor'

unlet has_async
unlet has_nvim_lsp
call plug#end()

set encoding=utf-8
set fileencodings=utf-8,cp1251,koi8-r,default
set showcmd         " display incomplete commands
set tabstop=4
set shiftwidth=4    " 4 characters for indenting
set expandtab
set number          " line numbers
set foldmethod=syntax
set foldlevel=8
set scrolljump=5
set scrolloff=5     " 5 lines bevore and after the current line when scrolling
set ignorecase      " ignore case
set smartcase       " but don't ignore it, when search string contains uppercase letters
set hidden          " allow switching buffers, which have unsaved changes
set signcolumn=yes  " Always show sign column
set showmatch       " showmatch: Show the matching bracket for the last ')'?
set novisualbell    " visual bell instead of beeping
set wildignore=*.bak,*.o,*.e,*~ " wildmenu: ignore these extensions
set completeopt=menu,menuone,noselect
set confirm
" airline already displays mode
set noshowmode
set nofixeol
set updatetime=300

"-------------------------------------------------------------------------------
" Load configuration files specific for Vim or Neovim
"-------------------------------------------------------------------------------
let s:dotfiles = fnamemodify(resolve(expand('<script>:p')), ':h')
let s:extraconf = has('nvim') ? 'init-extra.lua' : 'init-extra.vim'
exec 'source' s:dotfiles .. '/vim/' .. s:extraconf

"-------------------------------------------------------------------------------
" Look and Theme settings
"-------------------------------------------------------------------------------
let s:theme='jellybeans'
set background=dark
"let xterm16_brightness='high'
let xterm16_colormap='soft'
let xterm16bg_Normal='none'
let g:solarized_termcolors=256
"let g:solarized_termtrans=1

" Transparent background for Jellybeans
let g:jellybeans_overrides = {
\   'background': { 'ctermbg': 'none', '256ctermbg': 'none' }
\}

if has('nvim') && has('termguicolors') && $COLORTERM ==# 'truecolor'
    set termguicolors
    let g:jellybeans_overrides['background']['guibg'] = 'none'
endif

" check if we are not running in powershell or cmd text mode
if !has('win32') || has('gui_running')
    set t_Co=256
    exec 'colo' s:theme
endif

function! InitGVim()
    set guioptions=agim
    set columns=120
    set lines=40
    if has('gui_win32')
        set encoding=utf-8
        set renderoptions=type:directx
        set guifont=Fira_Code:h11
    elseif has('nvim')
        " GuiFont! Liberation Mono:h11
        GuiFont! Fira Code:h11
        " Show text tabline and popups in nvim-qt
        GuiTabline 0
        GuiPopupmenu 0
    else
        set guifont=Liberation\ Mono\ 11
    endif
    exec 'colo' s:theme
endfunction

" Workaround for https://github.com/equalsraf/neovim-qt/issues/94
" this requires adding 'doautocmd GUIEnter' into ginit.vim
if has('gui_running')
    call InitGVim()
else
    autocmd GUIEnter * call InitGVim()
endif
"-------------------------------------------------------------------------------
" Keybindings
"-------------------------------------------------------------------------------
" imap {<CR> {<CR>}<Esc>O

" comma always followed by a space
inoremap  ,  ,<Space>

" " autocomplete parenthesis, (brackets) and braces
" inoremap  (  ()<Left>
" inoremap  [  []<Left>
" inoremap  {  {}<Left>
" vnoremap  (  s()<Esc>P<Right>%
" vnoremap  [  s[]<Esc>P<Right>%
" vnoremap  {  s{}<Esc>P<Right>%
" vnoremap  )  s(  )<Esc><Left>P<Right><Right>%
" vnoremap  ]  s[  ]<Esc><Left>P<Right><Right>%
" vnoremap  }  s{  }<Esc><Left>P<Right><Right>%
" " autocomplete quotes (visual and select mode)
" xnoremap  '  s''<Esc>P<Right>
" xnoremap  "  s""<Esc>P<Right>
" xnoremap  `  s``<Esc>P<Right>

"-------------------------------------------------------------------------------
" The current directory is the directory of the file in the current window.
"-------------------------------------------------------------------------------
"if has("autocmd")
"  autocmd BufEnter * :lchdir %:p:h
"endif

"-------------------------------------------------------------------------------
" SPELLCHECK CONFIGURATION
"-------------------------------------------------------------------------------
if version >= 700
  set spelllang=ru,en
  set nospell
endif

"===============================================================================
" CONFIGURATIONS FOR SPECIFIC FILE TYPES
"===============================================================================
"
let g:GPGDefaultRecipients=["4F071603387A382A"]

" vim -b : edit binary using xxd-format!
augroup Binary
au!
    au BufReadPre   *.bin,*.swf,*.abc let &bin=1
    au BufReadPost  *.bin,*.swf,*.abc if &bin | %!xxd
    au BufReadPost  *.bin,*.swf,*.abc set ft=xxd | endif
    au BufWritePre  *.bin,*.swf,*.abc if &bin | %!xxd -r
    au BufWritePre  *.bin,*.swf,*.abc endif
    au BufWritePost *.bin,*.swf,*.abc if &bin | %!xxd
    au BufWritePost *.bin,*.swf,*.abc set nomod | endif
augroup END

" Fix auto-added EOL in PHP files.
autocmd BufNewFile *.inc setlocal filetype=php
autocmd BufReadPre *.inc setlocal filetype=php
autocmd FileType php setlocal noeol binary fileformat=dos

" lisp/scheme syntax hilighting
let g:lisp_rainbow = 1

"===============================================================================
" VARIOUS PLUGIN CONFIGURATIONS
"===============================================================================

"-------------------------------------------------------------------------------
" Language servers and plugins
"-------------------------------------------------------------------------------
let g:ale_disable_lsp = 1
let g:ale_pattern_options_enabled = 1
let g:ale_pattern_options = {
    \ '\.\(c\|cpp\|h\|hpp\)$': {'ale_enabled': 0},
    \ '\.rs$': {'ale_enabled': 0}
    \ }

let g:ale_linter_aliases = {
    \ 'asciidoctor': ['asciidoc'],
    \ }

"-------------------------------------------------------------------------------
" Neoformat
"-------------------------------------------------------------------------------
let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_typescript = ['prettier']
nnoremap <silent> <A-S-F> :Neoformat<CR>

"-------------------------------------------------------------------------------
" EditorConfig
"-------------------------------------------------------------------------------

let g:EditorConfig_exclude_patterns = ['fugitive://.*']

"-------------------------------------------------------------------------------
" netrw
"-------------------------------------------------------------------------------
let g:netrw_liststyle = 3 "tree
"let g:netrw_altv=&spr
let g:netrw_browse_split=0
let g:netrw_preview=1
let g:netrw_winsize=-25

autocmd StdinReadPre * let s:std_in=1
" Disabled as it bugs nvim-qt
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | Ex . | endif

"-------------------------------------------------------------------------------
" Airline 
"-------------------------------------------------------------------------------
let g:airline_symbols_ascii = 1
let g:airline#extensions#branch#vcs_priority = ['git']
let g:airline#extensions#branch#vcs_checks = []
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number

"-------------------------------------------------------------------------------
" CtrlP
"-------------------------------------------------------------------------------
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['Makefile', '*.spec']
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ }
let g:ctrlp_user_command = {
  \ 'types': {
      \ 1: ['.git', 'cd %s && git ls-files . -co --exclude-standard'],
      \ 2: ['.hg',  'hg --cwd %s locate -I .'],
      \ }
  \ }
" if executable('rg')
"     let g:ctrlp_user_command = 'rg --files %s'
"     let g:ctrlp_use_caching = 0
"     let g:ctrlp_use_buffer = 'et'
" endif
"-------------------------------------------------------------------------------
" FZF
"-------------------------------------------------------------------------------
if executable('fzf') && executable('rg')
    set grepprg=rg\ --vimgrep

    let $FZF_DEFAULT_COMMAND='rg --files --follow . '

    command! -bang -nargs=* Find
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case --fixed-strings --hidden -L -- '.shellescape(<q-args>),
      \   1,
      \   <bang>0)

    command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0)

    nnoremap <c-p> :Files<CR>
    nmap <leader><tab> <plug>(fzf-maps-n)
    xmap <leader><tab> <plug>(fzf-maps-x)
    omap <leader><tab> <plug>(fzf-maps-o)
endif
"-------------------------------------------------------------------------------
" Gundo
"-------------------------------------------------------------------------------
nnoremap <F5> :GundoToggle<CR>
let g:gundo_right = 1

" https://bitbucket.org/sjl/gundo.vim/issues/42
if has('python3')
    let g:gundo_prefer_python3 = 1
endif
"-------------------------------------------------------------------------------
" Buffer explorer
"-------------------------------------------------------------------------------
if executable('fzf')
    noremap gb  :Buffers<CR>
else
    noremap gb  :BufExplorerHorizontalSplit<CR>
endif
