" === Snap ====================================================================

let g:snap_prefix  = exists('g:snap_prefix') ? g:snap_prefix : '0'
let g:snap_dir     = exists('g:snap_dir') ? g:snap_dir : snap#get_defaultdir()

" {"filetype": [snips]}
let s:snips = {}

function! s:add_to_completionlist(name, file)
    call complete_add(#{word: a:name, menu: a:file . '.snap'})
endfunction

function! s:run_abbrv(type, local)
    " For '*', the dictionary key is '_default'
    let l:snapfile = a:type ==# '*' ? '_default' : a:type

    for snip in s:snips[l:snapfile]
        let l:abbr = 'inoreabbrev'              " Only insert mode, no remapping
        let l:expr = snip.expr ? '<expr>' : ''  " Check if it is a snipexpr
        let l:buff = a:local ? '<buffer>' : ''  " Make snips local to buffer
        let l:siln = '<silent>'                 " Don't show abbr cmd being executed
        let l:name = g:snap_prefix . snip.name  " Join prefix and name
        let l:expn = snip.expansion             " The snip expansion

        let l:cmd = join([l:abbr, l:expr, l:buff, l:siln, l:name, l:expn], ' ')

        execute l:cmd

        " call s:add_to_completionlist(l:name, l:snapfile)
    endfor
endfunction

function! s:load_default()
    let fname = g:snap_dir . '/_default.snap'

    if filereadable(fname)
        let s:snips['_default'] = snap#load_file(fname)
        call s:run_abbrv('*', 0)
    endif
endfunction

function! s:load_snapfile()
    " Get the filetype of the current buffer
    let l:name = &filetype

    if !has_key(s:snips, l:name)
        let l:fname = g:snap_dir . '/' . l:name . '.snap'

        if filereadable(l:fname)
            let s:snips[l:name] = snap#load_file(l:fname)
            call s:run_abbrv(l:name, 1)
        endif
    else
        call s:run_abbrv(l:name, 1)
    endif
endfunction

call s:load_default()
autocmd FileType * call s:load_snapfile()

