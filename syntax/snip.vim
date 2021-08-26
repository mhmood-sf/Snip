" Vim syntax file
" Language: Snip file
" Maintainer: quintik

if exists("b:current_syntax")
    finish
endif

let b:current_syntax = 'snip'

syntax case match

syn keyword snipKeywords snip snipexpr
syn keyword snipEsc Esc contained

syn region snipComment start='#' end='#'

syn region snipBlock   start=/{/     end=/}/        contains=ALLBUT,snipKeywords
syn region snipCharKey start=/</     end=/>/        contains=snipEsc contained
syn region snipNMode   start=/<Esc>/ end=/[iaoIAO]/ contains=snipCharKey

hi def link snipEsc       Number
hi def link snipNMode     Number
hi def link snipBlock     String
hi def link snipComment   Comment
hi def link snipCharKey   Comment
hi def link snipKeywords  Keyword

