" Vim syntax file
" Language: Snap file
" Maintainer: quintik

if exists("b:current_syntax")
    finish
endif

syntax case match

syn keyword snapKeywords snip snipexpr
syn keyword snapEsc Esc contained

syn region snapComment start='#' end='#'

syn region snapBlock   start=/{/     end=/}/        contains=ALLBUT,snapKeywords
syn region snapCharKey start=/</     end=/>/        contains=snapEsc contained
syn region snapNMode   start=/<Esc>/ end=/[iaoIAO]/ contains=snapCharKey

let b:current_syntax = 'snap'

hi def link snapEsc       Number
hi def link snapNMode     Number
hi def link snapBlock     String
hi def link snapComment   Comment
hi def link snapCharKey   Comment
hi def link snapKeywords  Keyword

