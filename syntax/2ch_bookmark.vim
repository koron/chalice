" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 13-Apr-2002.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

runtime! syntax/2ch.vim

execute 'syntax match 2chBookmarkCategory display "^\s*' . Chalice_foldmark(0) . '.*"'
" URLPAT
syntax match 2chBookmarkUrl display "\(https\?\|ftp\)://[-!#%&+,./0-9:;=?@A-Za-z_~]\+"
hi def link 2chBookmarkCategory		Title
hi def link 2chBookmarkUrl		2chUnderlined
