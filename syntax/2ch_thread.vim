" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 22-Jan-2002.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

runtime! syntax/2ch.vim

syntax match 2chThreadSeparator display "^--------$"
syntax match 2chThreadNumber display "^\d\+"
syntax match 2chThreadFrom display "From:.*\(  Date:\)\@="
syntax match 2chThreadDate display "Date:.*\(  Mail:\)\@="
syntax match 2chThreadMail display "Mail:.*"
syntax match 2chThreadRef display ">>\d\+\(-\d\+\)\?"
" URLPAT
syntax match 2chThreadUrl display "\(h\?ttp\|ftp\)://[-!#%&+,./0-9:;=?@A-Za-z_~]\+"
syntax match 2chThreadComment display "^  \(#\|Åî\).*"
syntax match 2chThreadQuote display "^  [>ÅÑ][^>ÅÑ].*"hs=s+2

hi def link 2chThreadSeparator		Statement
hi def link 2chThreadNumber		Type
hi def link 2chThreadFrom		Constant
hi def link 2chThreadDate		Special
hi def link 2chThreadMail		Identifier
hi def link 2chThreadRef		2chUnderlined
hi def link 2chThreadUrl		2chUnderlined
hi def link 2chThreadComment		Comment
hi def link 2chThreadQuote		PreProc
