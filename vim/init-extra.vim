" Configuration specific for Vim

function! s:cmd(...)
    if has('win32')
        return ['cmd', '/C'] + a:000
    else
        return a:000
    endif
endfunction

let g:LanguageClient_serverCommands = {
    \ 'c': s:cmd('clangd', '--background-index', '--compile-commands-dir=build'),
    \ 'cpp': s:cmd('clangd', '--background-index', '--compile-commands-dir=build'),
    \ 'python': s:cmd('pyls'),
    \ 'rust': s:cmd('rust-analyzer'),
    \ 'javascript': s:cmd('typescript-language-server', '--stdio'),
    \ 'typescript': s:cmd('typescript-language-server', '--stdio'),
    \ 'typescript.tsx': s:cmd('typescript-language-server', '--stdio')
    \ }

let g:LanguageClient_rootMarkers = {
    \ 'javascript.jsx': ['package.json'],
    \ 'typescript': ['tsconfig.json', 'package.json'],
    \ 'typescript.tsx': ['tsconfig.json', 'package.json'],
    \ 'python': ['pyproject.toml', 'setup.cfg', 'setup.py', 'tox.ini']
    \ }

" Automatically start language servers.
let g:LanguageClient_autoStart = 1

nmap <F4> <Plug>(lcn-menu)
nmap <silent> K <Plug>(lcn-hover)
nmap <silent> gd <Plug>(lcn-definition)
nmap <silent> <F2> <Plug>(lcn-rename)
