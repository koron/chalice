" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 06-May-2002.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

runtime! syntax/2ch.vim

syntax match 2chThreadTitleLabel display "^Title:.*$"
syntax match 2chThreadHeaderSize transparent "^Size:.*$" contains=2chThreadSizeLabel,2chThreadSizeNumber,2chThreadSizeWarnNotfile
syntax match 2chThreadSizeLabel display "Size:" contained containedin=2chThreadHeaderSize
syntax match 2chThreadSizeNumber display "\d\+KB" contained containedin=2chThreadHeaderSize
syntax match 2chThreadSizeWarnNotfile display "(NOT FILESIZE)" contained containedin=2chThreadHeaderSize
syntax match 2chThreadSeparator display "^--------$"
syntax match 2chThreadArticleHeader transparent "^\d.*" contains=2chThreadNumber,2chThreadFrom,2chThreadDate,2chThreadMail
syntax match 2chThreadNumber display "^\d\+" contained containedin=2chThreadArticleHeader
syntax match 2chThreadFrom display "From:.*\(  Date:\)\@=" contained containedin=2chThreadArticleHeader
syntax match 2chThreadDate display "Date:.*\(  Mail:\)\@=" contained containedin=2chThreadArticleHeader
syntax match 2chThreadMail display "Mail:.*" contained containedin=2chThreadArticleHeader
syntax match 2chThreadRef display ">>\d\+\(-\d\+\)\?"
" URLPAT
syntax match 2chThreadUrl display "\(h\?ttps\?\|ftp\)://[-!#%&+,./0-9:;=?@A-Za-z_~]\+"
syntax match 2chThreadUrlWWW display "www[-!#%&+,./0-9:;=?@A-Za-z_~]\+"
syntax match 2chThreadComment display "^  \(#\|��\).*"
syntax match 2chThreadQuote1 display "^  [>��]\([>��][>��]\)*[^0-9>��].*"hs=s+2
syntax match 2chThreadQuote2 display "^  [>��][>��]\([>��][>��]\)*[^0-9>��].*"hs=s+2

hi def link 2chThreadTitleLabel		Title
hi def link 2chThreadSizeLabel		Type
hi def link 2chThreadSizeNumber		Constant
hi def link 2chThreadSizeWarnNotfile	Comment
hi def link 2chThreadSeparator		Statement
hi def link 2chThreadNumber		Type
hi def link 2chThreadFrom		Constant
hi def link 2chThreadDate		Special
hi def link 2chThreadMail		Identifier
hi def link 2chThreadRef		2chUnderlined
hi def link 2chThreadUrl		2chUnderlined
hi def link 2chThreadUrlWWW		2chUnderlined
hi def link 2chThreadComment		Comment
hi def link 2chThreadQuote1		PreProc
hi def link 2chThreadQuote2		Identifier
