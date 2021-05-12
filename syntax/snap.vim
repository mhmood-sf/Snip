" Vim syntax file
" Language: Snap file
" Maintainer: quintik

if exists("b:current_syntax")
    finish
endif

syntax case match

syn keyword snipsKeywords snip snipexpr
syn keyword snipsEsc Esc contained

syn region snipsComment start='#' end='#'

syn region snipsBlock start=/{/ end=/}/ contains=ALLBUT,snipsKeywords
syn region snipsCharKey start=/</ end=/>/ contains=snipsEsc,snipsAll contained
syn region snipsNMode start=/<Esc>/ end=/[ia]/ contains=snipsCharKey

let b:current_syntax = 'snap'

hi def link snipsEsc       Number
hi def link snipsNMode     Number
hi def link snipsBlock     String
hi def link snipsComment   Comment
hi def link snipsCharKey   Comment
hi def link snipsKeywords  SpecialChar

