" === Snap ====================================================================

let g:snap_prefix  = exists('g:snap_prefix') ? g:snap_prefix : '0'
let g:snap_dir     = exists('g:snap_dir') ? g:snap_dir : snap#get_defaultdir()

" {"filetype": [snips]}
let s:snips = {}

function s:run_abbrv(type)
    " For '*', the dictionary key is 'autoload'
    let l:snapfile = a:type ==# '*' ? 'autoload' : a:type

    for snip in s:snips[l:snapfile]
        let l:abbr = 'inoreabbrev'              " Only insert mode, no remapping
        let l:expr = snip.expr ? '<expr>' : ''  " Check if it is a snipexpr
        let l:buff = '<buffer>'                 " All snips are local to buffer
        let l:siln = '<silent>'                 " Don't show abbr cmd being executed
        let l:name = g:snap_prefix . snip.name  " Join prefix and name
        let l:expn = snip.expansion             " The snip expansion

        let l:cmd = join([l:abbr, l:expr, l:buff, l:name, l:expn], ' ')

        execute l:cmd
    endfor
endfunction

function s:load_default()
    let fname = g:snap_dir . '/autoload.snap'

    if filereadable(fname)
        let s:snips.autoload = snap#load_file(fname)
        call s:run_abbrv('*')
    endif
endfunction

function s:load_snapfile()
    " Get the filetype of the current buffer
    let l:name = &filetype

    if !has_key(s:snips, l:name)
        let l:fname = g:snap_dir . '/' . l:name . '.snap'

        if filereadable(l:fname)
            let s:snips[l:name] = snap#load_file(l:fname)
            call s:run_abbrv(l:name)
        endif
    else
        call s:run_abbrv(l:name)
    endif
endfunction

call s:load_default()
autocmd FileType * call s:load_snapfile()

