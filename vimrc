set nocompatible

function! LoadIf(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, {'on': [], 'for': [] })
endfunction

call plug#begin(has('windows') ? '~/vimfiles/bindle' : '~/.vim/bundle')

" Look and feel
Plug 'vim-scripts/xterm16.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'bling/vim-airline'
"Plug 'vim-scripts/let-modeline.vim'
"Plug 'scrooloose/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jlanzarotta/bufexplorer'

" Behavior/General
Plug 'easymotion/vim-easymotion'
Plug 'ervandew/supertab'
Plug 'jiangmiao/auto-pairs'
Plug 'kien/ctrlp.vim'
Plug 'sjl/gundo.vim'
Plug 'tomtom/tcomment_vim' " gc{motion}, gc<count>c{motion}, gcc
Plug 'tpope/vim-surround'

" Behavior/Integration
"Plug 'SirVer/ultisnips'
Plug 'mattn/emmet-vim'
Plug 'vim-syntastic/syntastic'

" Version Control
"Plug 'http://repo.or.cz/r/vcscommand.git'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Language Server
"Plug 'autozimu/LanguageClient-neovim', LoadIf(has('nvim'), {'do': ':UpdateRemotePlugins'})
"Plug 'Shougo/denite.nvim',   LoadIf(has('nvim'))
"Plug 'Shougo/deoplete.nvim', LoadIf(has('nvim'))
"Plug 'Shougo/echodoc.vim',   LoadIf(has('nvim'))

" Languages
"Plug 'othree/xml.vim'
"Plug 'Valloric/YouCompleteMe'
"Plug 'Rip-Rip/clang_complete'
"Plug 'fsharp/vim-fsharp'
"Plug 'HerringtonDarkholme/yats.vim'
"Plug 'mhartington/nvim-typescript'

call plug#end()

filetype plugin indent on
syntax enable

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
"set nobackup       " DON'T keep a backup file
set fileencodings=utf-8,cp1251,koi8-r,default
set history=50      " keep 50 lines of command line history
set ruler           " show the cursor position all the time
set showcmd         " display incomplete commands
set incsearch       " do incremental searching
set tabstop=4
set shiftwidth=4    " 4 characters for indenting
set number          " line numbers
set cindent
set autoindent
set foldmethod=syntax
set foldlevel=8
set scrolljump=5
set scrolloff=5     " 5 lines bevore and after the current line when scrolling
set ignorecase      " ignore case
set smartcase       " but don't ignore it, when search string contains uppercase letters
set hid             " allow switching buffers, which have unsaved changes
set showmatch       " showmatch: Show the matching bracket for the last ')'?
set novisualbell    " visual bell instead of beeping
set wildignore=*.bak,*.o,*.e,*~ " wildmenu: ignore these extensions
set wildmenu        " command-line completion in an enhanced mode
set completeopt=menu,longest,preview
set confirm
" always show status line (also:vim-airline)
set laststatus=2

if has('gui_running')
    set guifont=Liberation\ Mono\ 11
    set guioptions=agim
    set columns=100
    set lines=40
endif

"-------------------------------------------------------------------------------
"  highlight paired brackets
"-------------------------------------------------------------------------------
highlight MatchParen ctermbg=blue guibg=lightyellow

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
" Theme settings
"-------------------------------------------------------------------------------
set background=dark
set t_Co=256

let xterm16_colormap    = 'soft'
"let xterm16_brightness  = 'high'
let xterm16bg_Normal    = 'none'
colo xterm16

let g:solarized_termcolors=256
let g:solarized_termtrans=1
"colo solarized

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

" New file templates:
":autocmd BufNewFile  *.sh      0r ~/.vim/templates/template.sh
":autocmd BufNewFile  *.pl      0r ~/.vim/templates/template.pl

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
" Language Servers
"-------------------------------------------------------------------------------
let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ 'javascript': ['~/.npm-global/bin/javascript-typescript-langserver'],
    \ 'typescript': ['~/.npm-global/bin/javascript-typescript-langserver']
    \ }
" Automatically start language servers.
let g:LanguageClient_autoStart = 1
nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>

"-------------------------------------------------------------------------------
" YouCompleteMe
"-------------------------------------------------------------------------------
let g:ycm_auto_trigger = 0

"-------------------------------------------------------------------------------
" clang_complete
"-------------------------------------------------------------------------------
let g:clang_complete_copen = 0
let g:clang_periodic_quickfix = 0
let g:clang_snippets=1
let g:clang_snippets_engine = 'ultisnips'
let g:clang_use_library = 1
" for ->, .
let g:clang_complete_auto = 0

"-------------------------------------------------------------------------------
" deoplete
"-------------------------------------------------------------------------------
"let g:deoplete#enable_at_startup = 1

"-------------------------------------------------------------------------------
" netrw
"-------------------------------------------------------------------------------
let g:netrw_liststyle = 3 "tree
"let g:netrw_altv=&spr
let g:netrw_browse_split=0
let g:netrw_preview=1
let g:netrw_winsize=-25

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | Ex . | endif

"-------------------------------------------------------------------------------
" CtrlP
"-------------------------------------------------------------------------------
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['Makefile', '*.spec', 'package.json']

"-------------------------------------------------------------------------------
" Gundo
"-------------------------------------------------------------------------------
nnoremap <F5> :GundoToggle<CR>
let g:gundo_right = 1

"-------------------------------------------------------------------------------
" NERDTree
"-------------------------------------------------------------------------------
"let g:NERDTreeWinSize = 23
"let g:NERDTreeWinPos = "left"
"let g:NERDTreeAutoCenter = 0
"let g:NERDTreeHighlightCursorline = 0
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

"-------------------------------------------------------------------------------
" Buffer explorer
"-------------------------------------------------------------------------------
noremap gb   :BufExplorerHorizontalSplit<CR>

"-------------------------------------------------------------------------------
" Tab labels
" Code from http://konishchevdmitry.blogspot.com
"-------------------------------------------------------------------------------
if exists('+showtabline')
    function! MyTabLine()
        let tabline = ''
        for i in range(tabpagenr('$'))
            if i + 1 == tabpagenr()
                let tabline .= '%#TabLineSel#'
            else
                let tabline .= '%#TabLine#'
            endif
            let tabline .= '%' . (i + 1) . 'T'
            let tabline .= ' %{MyTabLabel(' . (i + 1) . ')} |'
        endfor
        let tabline .= '%#TabLineFill#%T'
        if tabpagenr('$') > 1
            let tabline .= '%=%#TabLine#%999XX'
        endif
        return tabline
    endfunction

    function! MyTabLabel(n)
        let label = ''
        let buflist = tabpagebuflist(a:n)
        let label = substitute(bufname(buflist[tabpagewinnr(a:n) - 1]), '.*/', '', '')

        if label == ''
            let label = '[No Name]'
        endif

        let label .= ' (' . a:n . ')'
        for i in range(len(buflist))
            if getbufvar(buflist[i], "&modified")
                let label = '[+] ' . label
                break
            endif
        endfor
        return label
    endfunction

    function! MyGuiTabLabel()
        return '%{MyTabLabel(' . tabpagenr() . ')}'
    endfunction

    set tabline=%!MyTabLine()
    set guitablabel=%!MyGuiTabLabel()
endif
