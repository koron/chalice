" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 19-Nov-2001.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

runtime! syntax/2ch.vim

syntax match 2chBoardCategory display "^\S.*"
syntax match 2chBoardBoard display "^ \S*"hs=s+1

hi def link 2chBoardCategory		Title
hi def link 2chBoardBoard		2chUnderlined
