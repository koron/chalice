" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 24-Nov-2001.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

" Chaliceの起動確認
if !ChaliceIsRunning()
  finish
endif

" 共通設定の読み込み
runtime! ftplugin/2ch.vim

setlocal bufhidden=hide
setlocal expandtab
setlocal tabstop=4 shiftwidth=4 softtabstop=4
setlocal nowrap

" 書込みコマンド
nnoremap <buffer> <C-CR>		:ChaliceDoWrite<CR>

nunmap <buffer> <C-A>
nunmap <buffer> <BS>
nunmap <buffer> <C-H>
nunmap <buffer> u
nunmap <buffer> m
nunmap <buffer> U
nunmap <buffer> M
nunmap <buffer> <Space>
nunmap <buffer> <S-Space>
