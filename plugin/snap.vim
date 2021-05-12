" === Snip ====================================================================

" === Options
" idk, sometimes things break because of the file path separator
let g:snap_pathsep = exists('g:snap_pathsep') ? g:snap_pathsep : '/'
" prefix must be a keyword (see :h iskeyword)
let g:snap_prefix  = exists('g:snap_prefix') ? g:snap_prefix : '0'
let g:snap_dir     = exists('g:snap_dir') ? g:snap_dir : snap#get_defaultdir()
" load snips lazily (when the filetype is opened) or eagerly (on startup)
let g:snap_lazy    = exists('g:snap_lazy') ? g:snap_lazy : 1

" =============================================================================

" {filetype: [snips]}
let s:snips = {}

" type - the filetype, or '*' for all filetypes.
" au   - use autocmd FileType <type> or not
"        If au is 1, snips will be registered whenever the filetype is opened
"        this is used in eager loading - snap files are parsed, and their
"        snips are stored, but only registered when the filetype event occurs.
"        If au is 0, they will be directly reigstered into the current
"        buffer. This is used for lazy loading, since the lazy load command is
"        only executed when the filetype is opened, so there's no need for
"        autocmd
" buf  - whether to set abbreviations local to buffer or not
function s:abbrv(type, au, buf)
    " for the '*' type, the dictionary key is 'autoload' so we need to check
    " that first.
    let l:snapfile = a:type ==# '*' ? 'autoload' : a:type

    " loop over each snip for that filetype
    for snip in s:snips[l:snapfile]
        " set autocmd appropriately
        let l:auto = a:au ? 'autocmd FileType ' . a:type . ' ' : ''
        let l:abbr = 'inoreabbrev'
        " check if expr is set
        let l:expr = snip.expr ? ' <expr> ' : ' '
        " all snips are local to the buffer, and silent
        let l:buff = (a:buf ? '<buffer>' : '') . '<silent>'
        " add prefix to the snip name
        let l:name = g:snap_prefix . snip.name
        let l:expn = snip.expansion

        execute l:auto . l:abbr . l:expr . l:buff . ' ' . l:name . ' ' . l:expn
    endfor
endfunction

" the 'autoload.snap' file contains snips that will always be
" automatically loaded on startup. this is for common cross-filetype snips
function s:load_default()
    let fname = snap#fixpath(g:snap_dir . '/autoload.snap')
    " check if autoload.snap exists first
    if filereadable(fname)
        let s:snips.autoload = snap#load_file(fname)
        " we register commands directly, without using autocmds, and available
        " in every buffer (instead of just the local one)
        call s:abbrv('*', 0, 0)
    endif
endfunction

" go through the snap directory and load all files one by one
function s:eager_load()
    for f in readdir(g:snap_dir, {n -> n =~ '.snap$'})
        " absolute path to snap file
        let l:fname = snap#fixpath(g:snap_dir . '/' . f)
        " just the filename, extension removed
        let l:name = fnamemodify(fname, ':t:r')

        " skip autoload, already loaded
        if l:name ==# 'autoload'
            continue
        else
            " load snap file and register the snips
            let s:snips[l:name] = snap#load_file(l:fname)
            " here, we use autocmd because these snips are being eagerly
            " loaded. autocmd will detect when the `l:name` filetype is
            " opened, and then register the snips local to that buffer.
            " this way, snips for a filetype will only be available inside a
            " buffer of that filetype
            call s:abbrv(l:name, 1, 1)
        endif
    endfor
endfunction

" this function is only called when a filetype is detected
function s:lazy_load()
    " get the filetype of the current buffer
    let l:name = &filetype
    " if the filetype hasn't been loaded, do so
    if !has_key(s:snips, l:name)
        " absolute path to snap file
        let l:fname = snap#fixpath(g:snap_dir . '/' . l:name . '.snap' )
        " check if snap file actually exists
        if filereadable(l:fname)
            " load snap file and register the snips
            let s:snips[l:name] = snap#load_file(l:fname)
            " here, we dont use autocmd because lazy load is already only run
            " when the filetype event occurs, so instead of adding autocmds to
            " register the snips, we will directly register them without using
            " autocmds
            call s:abbrv(l:name, 0, 1)
        endif
    else
        " if the filetype has already been loaded, simply run the abbreviation
        " commands again to register the snips for the current buffer
        call s:abbrv(l:name, 0, 1)
    endif
endfunction

" ===

call s:load_default()

if g:snap_lazy
    autocmd FileType * call s:lazy_load()
else
    call s:eager_load()
endif

