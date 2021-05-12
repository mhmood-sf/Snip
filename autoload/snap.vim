" === Snap ====================================================================

" change separator in file path to g:snap_pathsep
function! snap#fixpath(str)
    if g:snap_pathsep == '\'
        return substitute(a:str, '/', g:snap_pathsep, 'g')
    else
        return substitute(a:str, '\', g:snap_pathsep, 'g')
    endif
endfunction

function snap#get_defaultdir() abort
    let l:expanded = expand('$MYVIMRC')
    let l:modified = fnamemodify(l:expanded, ':p:h') . '/snap'
    return snap#fixpath(l:modified)
endfunction

" === HELPERS

" checks if end of file has been reached
function s:check_eof(state)
    return a:state.pos >= len(a:state.src)
endfunction

" returns the current item in source (either a character or a token)
" if the end of file has been reached, returns a null character
function s:current(state)
    if s:check_eof(a:state)
        return nr2char(0) " nul character
    else
        return a:state.src[a:state.pos]
    endif
endfunction

" increments current position of state
function s:advance(state)
    let a:state.pos = a:state.pos + 1
endfunction

" === SCANNER

" scans a curly brace delimited block
function s:scanBlock(state)
    " initialize token
    let l:token = #{type: 'BLOCK', lexeme: ''}
    " keep track of depth curly braces depth,
    " since they may be nested.
    " when this function is called, it is at 1
    let l:depth = 1

    " keep consuming characters until depth is
    " 0, i.e we exit the outermost pair
    while l:depth != 0
        " if we reach eof, it means there is
        " a missing closing brace.
        if s:check_eof(a:state)
            echoerr 'Snap: Unexpected end of file. Missing }'
            return
        else
            " for every opening brace, increase depth by one
            if s:current(a:state) ==# '{'
                let l:depth = l:depth + 1
            " for every closing brace, decrease depth
            elseif s:current(a:state) ==# '}'
                let l:depth = l:depth - 1
            endif
            " only add the current character to the token
            " if depth is not 0, because when depth
            " becomes zero the current character is
            " the closing brace, which we don't need to
            " consume
            if l:depth != 0
                let l:token.lexeme = l:token.lexeme . s:current(a:state)
            endif

            call s:advance(a:state)
        endif
    endwhile

    " add token to state
    call add(a:state.tokens, l:token)
endfunction

" scans an identifier or a keyword
function s:scanIdentifier(state)
    " initialize token
    let l:token = #{type: '', lexeme: ''}

    " keep scanning until reaching a
    " space character
    while s:current(a:state) !~ '\s'
        " if we reach eof, finish scanning,
        " but dont end the function/throw error
        " because a file consisting of just an
        " identifier should still be tokenize-able.
        if s:check_eof(a:state)
            break
        else
            " add characters to token lexeme
            let l:token.lexeme = l:token.lexeme . s:current(a:state)
            call s:advance(a:state)
        endif
    endwhile

    " check for keywords
    if l:token.lexeme ==# 'snip'
        let l:token.type = 'KWSNIP'
    elseif l:token.lexeme ==# 'snipexpr'
        let l:token.type = 'KWSNIPEXPR'
    else
        let l:token.type = 'IDENT'
    endif

    call add(a:state.tokens, l:token)
endfunction

" tokenize source file
function s:tokenize(state)
    " base case, finish after reaching eof
    if s:check_eof(a:state)
        return
    else
        let l:c = s:current(a:state)

        " if current character is an opening brace,
        " start scanning for a block
        if l:c ==# '{'
            call s:advance(a:state)
            call s:scanBlock(a:state)
        " comments
        elseif l:c == '#'
            call s:advance(a:state)
            " keep consuming until end of comment or eof
            while s:current(a:state) != '#' && !s:check_eof(a:state)
                call s:advance(a:state)
            endwhile

            call s:advance(a:state)
        " ignore whitespace
        elseif l:c =~ '\s'
            call s:advance(a:state)
        else
            call s:scanIdentifier(a:state)
        endif

        " recurse
        call s:tokenize(a:state)
    endif
endfunction

" === PARSER

" looks for a KWSNIP token, otherwise errors
function s:expectSnip(state)
    " check keyword first - 0 means no expr, 1 means expr
    if s:current(a:state).type ==# 'KWSNIP'
        return 0
    elseif s:current(a:state).type ==# 'KWSNIPEXPR'
        return 1
    else
        echoerr 'Snap: Expected keyword snip or snipexpr'
        " set position to length so that check_eof
        " returns true and parsing does not continue
        let a:state.pos = len(a:state.src)
        return 0
    endif
endfunction

" looks for an identifier token, otherwise errors
function s:expectIdent(state)
    " check eof and token type first
    if s:check_eof(a:state) || s:current(a:state).type !=# 'IDENT'
        echoerr 'Snap: Expected identifier after keyword.'
        " set source position to length to ensure
        " parsing does not continue
        let a:state.pos = len(a:state.src)
        return ''
    else
        " return identifier lexeme
        return s:current(a:state).lexeme
    endif
endfunction

" looks for a block token, otherwise errors
function s:expectBlock(state)
    " check eof and token type first
    if s:check_eof(a:state) || s:current(a:state).type !=# 'BLOCK'
        echoerr 'Snap: Expected block after identifier.'
        " set source position to length to ensure
        " parsing does not continue
        let a:state.pos = len(a:state.src)
        return ''
    else
        " return block lexeme
        return s:current(a:state).lexeme
    endif
endfunction

" parses tokens for snap file
function s:parse(state)
    " base case, finish when all tokens consumed
    if s:check_eof(a:state)
        return
    else
        " follow snap file syntax, first snip/snipexpr keyword:
        let l:expr = s:expectSnip(a:state)
        call s:advance(a:state)

        " then an identifier:
        let l:name = s:expectIdent(a:state)
        call s:advance(a:state)

        " then a block:
        let l:expn = s:expectBlock(a:state)
        call s:advance(a:state)

        " if expectIdent and expectBlock error, they return
        " empty strings. if this is the case,
        " stop parsing
        if l:name == '' || l:expn == ''
            return
        endif

        let l:snip = #{name: l:name, expr: l:expr, expansion: l:expn}
        call add(a:state.snips, l:snip)
        call s:parse(a:state)
    endif
endfunction

" ===

" initialize state and call parse function
function s:parse_tokens(tokens)
    let l:state = #{snips: [], src: a:tokens, pos: 0}
    call s:parse(l:state)
    return l:state.snips
endfunction

" initialize state and call tokenize function
function s:parse_raw(raw)
    let l:chars = split(a:raw, '\zs')
    let l:state = #{tokens: [], src: l:chars, pos: 0}
    call s:tokenize(l:state)
    return l:state.tokens
endfunction

" parses and loads snips from a snap file
function snap#load_file(path)
    let l:raw = join(readfile(a:path), '')
    let l:tokens = s:parse_raw(l:raw)
    let l:snips_list = s:parse_tokens(l:tokens)

    return l:snips_list
endfunction

