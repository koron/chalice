" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 23-Nov-2001.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

" Chaliceの起動確認
if !ChaliceIsRunning()
  finish
endif

" 共通設定の読み込み
runtime! ftplugin/2ch.vim

setlocal nonumber

nnoremap <silent> <buffer> l		zo
nnoremap <silent> <buffer> h		zc

"nunmap <buffer> i
"nunmap <buffer> I
"nunmap <buffer> a
"nunmap <buffer> A
nunmap <buffer> ~

"
" folding設定
"

" スクリプトIDを取得
map <SID>xx <SID>xx
let s:sid = substitute(maparg('<SID>xx'), 'xx$', '', '')
unmap <SID>xx

function! s:FoldText()
  let entry = v:foldend - v:foldstart
  return substitute(getline(v:foldstart), '^■', '□', ''). ' (' . entry . ') '
endfunction

execute 'setlocal foldtext=' . s:sid .'FoldText()'
setlocal foldmethod=expr
setlocal foldexpr=getline(v:lnum)=~'^■'?'>1':'='
