" vim:set ts=8 sts=2 sw=2 tw=0:
"
" - 2ch viewer 'Chalice' /
"
" Last Change: 24-Apr-2002.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

" Chaliceの起動確認
if !ChaliceIsRunning()
  finish
endif

" 共通設定の読み込み
runtime! ftplugin/2ch.vim

setlocal foldcolumn=0
setlocal number
setlocal tabstop=32
let b:title = ''
let b:title_raw = ''
let b:host = ''
let b:board = ''

"
" キーマッピング
"
nnoremap <silent> <buffer> <S-Tab>	:ChaliceGoBoardList<CR>
nnoremap <silent> <buffer> <C-Tab>	:ChaliceGoThread<CR>

nnoremap <silent> <buffer> <CR>		:ChaliceOpenThread<CR>
nnoremap <silent> <buffer> <S-CR>	:ChaliceOpenThread external<CR>
nnoremap <silent> <buffer> -<CR>	:ChaliceOpenThread external<CR>
nnoremap <silent> <buffer> <C-CR>	:ChaliceOpenThread firstline<CR>
nnoremap <silent> <buffer> <C-C><CR>	:ChaliceOpenThread firstline<CR>
nnoremap <silent> <buffer> R		:ChaliceReloadThreadList<CR>
nnoremap <silent> <buffer> d		:ChaliceDeleteThreadDat<CR>
nnoremap <silent> <buffer> ~		:ChaliceBookmarkAdd threadlist<CR>

"nnoremap <silent> <buffer> i		:ChaliceWrite new<CR>
"nnoremap <silent> <buffer> I		:ChaliceWrite new,sage<CR>
"nnoremap <silent> <buffer> a		:ChaliceWrite new,anony<CR>
"nnoremap <silent> <buffer> A		:ChaliceWrite new,anony,sage<CR>

nnoremap <silent> <buffer> <2-LeftMouse>	:ChaliceOpenThread<CR>

nnoremap <buffer> <C-f>			<C-f>0
nnoremap <buffer> <C-b>			<C-b>0

setlocal foldmethod=manual

" 番号付きの外部ブラウザを起動する
function! s:KickNumberedExternalBrowser(exnum)
  let save_exbrowser = g:chalice_exbrowser
  if exists('g:chalice_exbrowser_' . a:exnum)
    let g:chalice_exbrowser = g:chalice_exbrowser_{a:exnum}
  endif
  ChaliceOpenThread external
  let g:chalice_exbrowser = save_exbrowser
endfunction

" 番号付きの外部ブラウザを起動するキーマップを登録する
let i = 0
while i < 10
  if exists('g:chalice_exbrowser_' . i)
    execute "nnoremap <silent> <buffer> ".i."<S-CR> :call <SID>KickNumberedExternalBrowser(" . i . ")\<CR>"
    execute "nnoremap <silent> <buffer> ".i."-<CR> :call <SID>KickNumberedExternalBrowser(" . i . ")\<CR>"
  endif
  let i = i + 1
endwhile
