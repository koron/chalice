" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 28-Nov-2001.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

runtime! syntax/2ch.vim

syntax match 2chWriteTitle "^Title:\s*.*"
syntax match 2chWriteFrom "^From:\s*.*"
syntax match 2chWriteMail "^Mail:\s*.*"
syntax match 2chWriteSeparator "^--------"
syntax match 2chWriteRef display ">>\d\+\(-\d\+\)\?"
syntax match 2chWriteUrl display "\(h\?ttp\|ftp\)://[-#%&+,./0-9:;=?A-Za-z_~]\+"
syntax match 2chWriteComment display "^[#Åî].*"
syntax match 2chWriteQuote display "^[>ÅÑ][^>ÅÑ].*"

hi def link 2chWriteTitle		Title
hi def link 2chWriteFrom		Constant
hi def link 2chWriteMail		Identifier
hi def link 2chWriteSeparator		NonText
hi def link 2chWriteRef			2chUnderlined
hi def link 2chWriteUrl			2chUnderlined
hi def link 2chWriteComment		Comment
hi def link 2chWriteQuote		PreProc
