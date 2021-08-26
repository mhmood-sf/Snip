function! snip#get_defaultdir() abort
    let l:expanded = expand('$MYVIMRC')
    let l:modified = fnamemodify(l:expanded, ':p:h') . '/snip'
    return l:modified
endfunction

" === HELPERS

" Checks if end of file has been reached
function! s:check_eof(state)
    return a:state.pos >= len(a:state.src)
endfunction

" Returns the current item in source (either a character or a token)
" If the end of file has been reached, returns a null character
function! s:current(state)
    if s:check_eof(a:state)
        return nr2char(0) " nul character
    else
        return a:state.src[a:state.pos]
    endif
endfunction

" Increments current position of state
function! s:advance(state)
    let a:state.pos = a:state.pos + 1
endfunction

" === SCANNER

" Scans a curly brace delimited block
function! s:scanBlock(state)
    " Initialize token
    let l:token = #{type: 'BLOCK', lexeme: ''}
    " Keep track of depth curly braces depth,
    " since they may be nested.
    let l:depth = 1

    " Consume characters until depth is
    " 0, i.e we exit the outermost pair
    while l:depth != 0
        " If we reach eof, it means there is
        " a missing closing brace.
        if s:check_eof(a:state)
            echoerr 'Snip: Unexpected end of file. Missing }'
            return
        else
            " For every opening brace, increase depth by one
            if s:current(a:state) ==# '{'
                let l:depth = l:depth + 1
            " For every closing brace, decrease depth
            elseif s:current(a:state) ==# '}'
                let l:depth = l:depth - 1
            endif
            " Only add the current character to the token
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

    " Add token to state
    call add(a:state.tokens, l:token)
endfunction

" Scans an identifier or a keyword
function! s:scanIdentifier(state)
    " Initialize token
    let l:token = #{type: '', lexeme: ''}

    " Keep scanning until reaching a
    " space character
    while s:current(a:state) !~ '\s'
        " If we reach eof, finish scanning,
        " but dont end the function/throw error
        " because a file consisting of just an
        " identifier should still be tokenize-able.
        if s:check_eof(a:state)
            break
        else
            " Add characters to token lexeme
            let l:token.lexeme = l:token.lexeme . s:current(a:state)
            call s:advance(a:state)
        endif
    endwhile

    " Check for keywords
    if l:token.lexeme ==# 'snip'
        let l:token.type = 'KWSNIP'
    elseif l:token.lexeme ==# 'snipexpr'
        let l:token.type = 'KWSNIPEXPR'
    else
        let l:token.type = 'IDENT'
    endif

    call add(a:state.tokens, l:token)
endfunction

" Tokenize source file
function! s:tokenize(state)
    " Base case, finish after reaching eof
    if s:check_eof(a:state)
        return
    else
        let l:c = s:current(a:state)

        " If current character is an opening brace,
        " start scanning for a block
        if l:c ==# '{'
            call s:advance(a:state)
            call s:scanBlock(a:state)
        " Comments
        elseif l:c == '#'
            call s:advance(a:state)
            " Keep consuming until end of comment or eof
            while s:current(a:state) != '#' && !s:check_eof(a:state)
                call s:advance(a:state)
            endwhile

            call s:advance(a:state)
        " Ignore whitespace
        elseif l:c =~ '\s'
            call s:advance(a:state)
        else
            call s:scanIdentifier(a:state)
        endif

        " Recurse
        call s:tokenize(a:state)
    endif
endfunction

" === PARSER

" Looks for a KWSNIP token, otherwise errors
function! s:expectSnip(state)
    " Check keyword first - 0 means no expr, 1 means expr
    if s:current(a:state).type ==# 'KWSNIP'
        return 0
    elseif s:current(a:state).type ==# 'KWSNIPEXPR'
        return 1
    else
        echoerr 'Snip: Expected keyword snip or snipexpr'
        " Set position to length so that check_eof
        " returns true and parsing does not continue
        let a:state.pos = len(a:state.src)
        return 0
    endif
endfunction

" Looks for an identifier token, otherwise errors
function! s:expectIdent(state)
    " Check eof and token type first
    if s:check_eof(a:state) || s:current(a:state).type !=# 'IDENT'
        echoerr 'Snip: Expected identifier after keyword.'
        " Set source position to length to ensure
        " parsing does not continue
        let a:state.pos = len(a:state.src)
        return ''
    else
        " Return identifier lexeme
        return s:current(a:state).lexeme
    endif
endfunction

" Looks for a block token, otherwise errors
function! s:expectBlock(state)
    " Check eof and token type first
    if s:check_eof(a:state) || s:current(a:state).type !=# 'BLOCK'
        echoerr 'Snip: Expected block after identifier.'
        " Set source position to length to ensure
        " parsing does not continue
        let a:state.pos = len(a:state.src)
        return ''
    else
        " Return block lexeme
        return s:current(a:state).lexeme
    endif
endfunction

" Parses tokens for snip file
function! s:parse(state)
    " Base case, finish when all tokens consumed
    if s:check_eof(a:state)
        return
    else
        " Follow snip file syntax, first snip/snipexpr keyword:
        let l:expr = s:expectSnip(a:state)
        call s:advance(a:state)

        " Then an identifier:
        let l:name = s:expectIdent(a:state)
        call s:advance(a:state)

        " Then a block:
        let l:expn = s:expectBlock(a:state)
        call s:advance(a:state)

        " If expectIdent and expectBlock error, they return
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

" === Main

" Initialize state and call parse function
function! s:parse_tokens(tokens)
    let l:state = #{snips: [], src: a:tokens, pos: 0}
    call s:parse(l:state)
    return l:state.snips
endfunction

" Initialize state and call tokenize function
function! s:parse_raw(raw)
    let l:chars = split(a:raw, '\zs')
    let l:state = #{tokens: [], src: l:chars, pos: 0}
    call s:tokenize(l:state)
    return l:state.tokens
endfunction

" Parses and loads snips from a snip file
function! snip#load_file(path)
    let l:raw = join(readfile(a:path), '')
    let l:tokens = s:parse_raw(l:raw)
    let l:snips_list = s:parse_tokens(l:tokens)

    return l:snips_list
endfunction

