" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 19-Nov-2001.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

runtime! syntax/2ch.vim

syntax match 2chBookmarkCategory display "^\S.*"
syntax match 2chBookmarkUrl display "\(http\|ftp\)://[-#%&+,./0-9:;=?A-Za-z_~]\+"
hi def link 2chBookmarkCategory		Title
hi def link 2chBookmarkUrl		2chUnderlined
