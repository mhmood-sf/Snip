" Plugin:      https://github.com/quintik/snip.vim
" Description: Manage vim abbreviations
" Maintainer:  quintik <https://github.com/quintik>

if exists("g:loaded_snip") || &cp
    finish
endif
let g:loaded_snip = "0.1.0"

let g:snip_prefix  = exists("g:snip_prefix") ? g:snip_prefix : "0"
let g:snip_dir     = exists("g:snip_dir") ? g:snip_dir : snip#get_defaultdir()

" {"filetype": [snips]}
let s:snips = {}

function! Eat(...)
    let pat = a:0 ? a:1 : '\s'
    let chr = nr2char(getchar(0))
    return (chr =~ pat) ? '' : chr
endfunction

function! s:run_abbrv(type, local)
    " For "*", the dictionary key is "_default"
    let l:snipfile = a:type ==# "*" ? "_default" : a:type

    for snip in s:snips[l:snipfile]
        let l:abbr = "inoreabbrev"              " Only insert mode, no remapping
        let l:expr = snip.expr ? "<expr>" : ""  " Check if it is a snipexpr
        let l:buff = a:local ? "<buffer>" : ""  " Make snips local to buffer
        let l:siln = "<silent>"                 " Don't show abbr cmd being executed
        let l:name = g:snip_prefix . snip.name  " Join prefix and name
        let l:expn = snip.expansion             " The snip expansion

        let l:cmd = join([l:abbr, l:expr, l:buff, l:siln, l:name, l:expn], " ")

        execute l:cmd

    endfor
endfunction

function! s:load_default()
    let fname = g:snip_dir . "/_default.snip"

    if filereadable(fname)
        let s:snips["_default"] = snip#load_file(fname)
        call s:run_abbrv("*", 0)
    endif
endfunction

function! s:load_snipfile()
    " Get the filetype of the current buffer
    let l:name = &filetype

    if !has_key(s:snips, l:name)
        let l:fname = g:snip_dir . "/" . l:name . ".snip"

        if filereadable(l:fname)
            let s:snips[l:name] = snip#load_file(l:fname)
            call s:run_abbrv(l:name, 1)
        endif
    else
        call s:run_abbrv(l:name, 1)
    endif
endfunction

call s:load_default()
autocmd FileType * call s:load_snipfile()

