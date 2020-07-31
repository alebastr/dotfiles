set nocompatible

function! LoadIf(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, {'on': [], 'for': [] })
endfunction

call plug#begin(has('win32') ? '~/vimfiles/bundle' : '~/.vim/bundle')
let has_async = has('timers') && ((has('job') && has('channel')) || has('nvim'))

" Workaround for vim/vim#3117
try | exec 'pythonx' 'pass' | catch | endtry
" Check that (n)vim is capablle of running neovim remote plugins
" and load shims if necessary
let has_nvim_rpc=has('nvim') || (version >= 800 && has('python3'))
Plug 'roxma/nvim-yarp', LoadIf(has_nvim_rpc && !has('nvim'))
Plug 'roxma/vim-hug-neovim-rpc', LoadIf(has_nvim_rpc && !has('nvim'))

" Look and feel
Plug 'vim-scripts/xterm16.vim'
"Plug 'altercation/vim-colors-solarized'
"Plug 'lifepillar/vim-solarized8'
Plug 'nanotech/jellybeans.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'vim-scripts/let-modeline.vim'
"Plug 'scrooloose/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jlanzarotta/bufexplorer'

" Behavior/General
Plug 'easymotion/vim-easymotion'
Plug 'ervandew/supertab'
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
Plug 'w0rp/ale', LoadIf(has_async)
Plug 'sbdchd/neoformat'

" Required to run tsuquyomi with vim7/neovim
"Plug 'Shougo/vimproc.vim'

" Version Control
"Plug 'http://repo.or.cz/r/vcscommand.git'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Language Server
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': (has('win32') ? 'powershell.exe -ExecutionPolicy Bypass -File install.ps1'
            \ : 'bash install.sh')
    \ }

" Completion
" tag: 5.2 is the last compatible with python3-msgpack < 1.0.0
Plug 'Shougo/deoplete.nvim', LoadIf(has_nvim_rpc, has('nvim') ? { 'do': ':UpdateRemotePlugins', 'tag': '5.2' } : {})
"Plug 'Shougo/denite.nvim',   LoadIf(has_nvim_rpc, has('nvim') ? { 'do': ':UpdateRemotePlugins' } : {})
"Plug 'Valloric/YouCompleteMe'

" Languages
Plug 'HerringtonDarkholme/yats.vim'
Plug 'PProvost/vim-ps1'
"Plug 'Quramy/tsuquyomi'
"Plug 'Rip-Rip/clang_complete'
"Plug 'fsharp/vim-fsharp', {'for': 'fsharp'}
"Plug 'mhartington/nvim-typescript'
"Plug 'othree/xml.vim'
Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
Plug 'rust-lang/rust.vim'
Plug '~/sources/meson/data/syntax-highlighting/vim'

unlet has_async
unlet has_nvim_rpc
call plug#end()

filetype plugin indent on
syntax enable

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
"set nobackup       " DON'T keep a backup file
set encoding=utf-8
set fileencodings=utf-8,cp1251,koi8-r,default
set history=50      " keep 50 lines of command line history
set ruler           " show the cursor position all the time
set showcmd         " display incomplete commands
set incsearch       " do incremental searching
set tabstop=4
set shiftwidth=4    " 4 characters for indenting
set expandtab
set number          " line numbers
set cindent
set autoindent
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
set wildmenu        " command-line completion in an enhanced mode
set completeopt=menu,longest,preview
set confirm
" always show status line (also:vim-airline)
set laststatus=2
" airline already displays mode
set noshowmode

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
" Language servers and plugins
"-------------------------------------------------------------------------------
function! s:cmd(...)
    if has('win32')
        return ['cmd', '/C'] + a:000
    else
        return a:000
    endif
endfunction

let rust_langserver='rls'
if executable('rust-analyzer')
    let rust_langserver='rust-analyzer'
endif

let g:LanguageClient_serverCommands = {
    \ 'c': s:cmd('clangd', '--background-index', '--compile-commands-dir=build'),
    \ 'cpp': s:cmd('clangd', '--background-index', '--compile-commands-dir=build'),
    \ 'rust': s:cmd(rust_langserver),
    \ 'javascript': s:cmd('javascript-typescript-stdio'),
    \ 'typescript': s:cmd('javascript-typescript-stdio'),
    \ 'typescript.tsx': s:cmd('javascript-typescript-stdio')
    \ }

let g:LanguageClient_rootMarkers = {
    \ 'javascript.jsx': ['package.json'],
    \ 'typescript': ['tsconfig.json', 'package.json'],
    \ 'typescript.tsx': ['tsconfig.json', 'package.json']
    \ }

" Automatically start language servers.
let g:LanguageClient_autoStart = 1

nnoremap <F4> :call LanguageClient_contextMenu()<CR>
nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>

"-------------------------------------------------------------------------------
" Neoformat
"-------------------------------------------------------------------------------
let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_typescript = ['prettier']
nnoremap <silent> <A-S-F> :Neoformat<CR>

"-------------------------------------------------------------------------------
" YouCompleteMe
"-------------------------------------------------------------------------------
let g:ycm_auto_trigger = 0

" YCM and UltiSnips compatibility
let g:UltiSnipsExpandTrigger = "<nop>"
let g:ulti_expand_or_jump_res = 0
function ExpandSnippetOrCarriageReturn()
    let snippet = UltiSnips#ExpandSnippetOrJump()
    if g:ulti_expand_or_jump_res > 0
        return snippet
    else
        return "\<CR>"
    endif
endfunction
inoremap <expr> <CR> pumvisible() ? "<C-R>=ExpandSnippetOrCarriageReturn()<CR>" : "\<CR>"

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
let g:deoplete#enable_at_startup = 1
let g:python3_host_prog = '/usr/bin/python3'

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
let g:airline#extensions#branch#vcs_priority = ['git']
let g:airline#extensions#branch#vcs_checks = []

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

    let $FZF_DEFAULT_COMMAND='rg --files --follow . 2> nul'

    command! -bang -nargs=* Find
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case --fixed-strings --hidden -L '.shellescape(<q-args>),
      \   1,
      \   <bang>0)

    command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
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
