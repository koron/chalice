" vim:set ts=8 sts=2 sw=2 tw=0:
"
" datutil.vim
"
" Last Change: 06-Jul-2002.
" Written By:  MURAOKA Taro <koron@tka.att.ne.jp>

scriptencoding cp932
if exists('plugin_datutil_disable')
  finish
endif
let s:debug = 1

"------------------------------------------------------------------------------
" INTERFACES:
"   :call Dat2Text()

"------------------------------------------------------------------------------
" IMPEMENTATION POINT:

function! s:GetMx_bbs2ch()
  " 2chスレッド、フォーマットパターン

  " 書き込み時情報の切り分け
  "   スレのdatのフォーマットは、直前に行頭に行(記事)番号を付けているので:
  "	番号<>名前<>メール<>時間<>本文<>スレ名
  "   となる。スレ名は先頭のみ
  let m1 = '\(.\{-}\)<>' " \{-}は最短マッチ
  let mx = '^\(\d\+\)<>'.m1.m1.m1.'\s*\(.\{-\}\)\s*<>\s*\(.*\)$'
  return mx
endfunction

function! s:GetMx_bbsmodoki()
  let m1 = '\([^,]*\),'
  let mx = '^\(\d\+\)<>' . m1.m1.m1.m1 . '\s*\(.*\)$'
  return mx
endfunction

function! s:FormatArticle(linestr, ...)
  let flags = a:0 > 0 ? a:0 : ''
  if a:linestr =~ s:mx_article
    let retval = substitute(a:linestr, s:mx_article, '\r--------\r\1  From:\2  Date:\4  Mail:\3\r  \5', '')
  else
    let retval = substitute(a:linestr, '\(\d\+\)<>\(.*\)', '\r--------\r\1  !!BROKEN!!\r  \2', '')
  endif
  let retval = substitute(retval, ' \?<br> \?', '\r  ', 'g')
  let retval = substitute(retval, '<\/\?a[^>]*>', '', 'g')
  let retval = substitute(retval, '\s*<\/\?b>', '', 'g')
  let retval = substitute(retval, '\c<\/\?font[^>]*>', '', 'g')
  if AL_hasflag(flags, 'modoki')
    let retval = substitute(retval, '＠｀', ',', 'g')
  endif
  return retval
endfunction

function! s:Dat2Text_loop(linestr)
  if s:dat2text_verbose && s:dat2text_count % 100 == 0
    echohl WarningMsg
    echo s:dat2text_count .'/'. b:datutil_last_article_num
    echohl None
  endif
  let retval = s:FormatArticle(a:linestr, exists('b:datutil_format') ? b:datutil_format : '')
  let s:dat2text_count = s:dat2text_count + 1
  return escape(retval, '\\')
endfunction

function! DatLine2Text(artnum, datline, ...)
  let inval = a:artnum.'<>'.a:datline
  let flags = a:0 > 0 ? a:1 : ''
  let format = '2ch'
  if AL_hasflag(flags, '2ch') || inval =~ s:GetMx_bbs2ch()
    let s:mx_article = s:GetMx_bbs2ch()
  elseif AL_hasflag(flags, 'modoki') || inval =~ s:GetMx_bbsmodoki()
    let s:mx_article = s:GetMx_bbsmodoki()
    let format = 'modoki'
  else
    let s:mx_article = s:GetMx_bbs2ch()
  endif
  let retval = s:FormatArticle(inval, format)
  return AL_decode_entityreference(retval)
endfunction

function! Dat2Text(...)
  let flags = a:0 > 0 ? a:1 : ''
  let s:dat2text_count = 1
  let s:dat2text_verbose = AL_hasflag(flags, 'verbose') ? 1 : 0
  " スレッドフォーマットパターンを決定
  let firstline = '0<>' . getline(1)
  if firstline =~ s:GetMx_bbs2ch()
    let s:mx_article = s:GetMx_bbs2ch()
    let b:datutil_format = '2ch'
  elseif firstline =~ s:GetMx_bbsmodoki()
    let s:mx_article = s:GetMx_bbsmodoki()
    let b:datutil_format = 'modoki'
  else
    let s:mx_article = s:GetMx_bbs2ch()
    let b:datutil_format = 'default'
  endif

  " 後で表示位置を調整するため
  let curline = line('.')
  " 必要ならばバッファサイズを取得する
  let not_filesize = 0
  if !exists('b:datutil_datsize')
    let not_filesize = 1
    let b:datutil_datsize = line2byte(line('$') + 1)
  endif
  " これらはdatutil側で常に設定する
  let b:datutil_last_article_num = line('$')
  let b:datutil_title = AL_decode_entityreference(substitute(firstline, s:mx_article, '\6', ''))

  " 整形と実体参照の解決
  %s/^.*$/\=s:Dat2Text_loop(s:dat2text_count."<>".submatch(0))/
  call AL_decode_entityreference_with_range('%')
  call AL_del_lastsearch()
  unlet s:dat2text_count
  unlet s:dat2text_verbose

  " ヘッダーを作成
  call setline(1, 'Title: '. b:datutil_title)
  let size_kb = (b:datutil_datsize / 1024) . 'KB'
  let line = 1
  call append(line, 'Size: ' . size_kb . (not_filesize ? ' (NOT FILESIZE)' : ''))
  let line = line + 1
  if exists('b:host') && exists('b:board')
    call append(line, 'Board: http://' .b:host.b:board)
    let line = line + 1
  endif
  call append(line, '') " HTMLやMAILヘッダー風にしておく
  let line = line + 1

  " 必要ならばカーソル位置を整形前にあった記事へ移動
  if AL_hasflag(flags, 'keepline')
    call search('^'.curline.' ', 'w')
  endif
  redraw!

  return b:datutil_title
endfunction

if s:debug
  function! Test_Dat2Text(...)
    let flags = a:0 > 0 ? a:1 : ''
    setlocal buftype=nofile nowrap
    call Dat2Text(flags)
  endfunction
endif
