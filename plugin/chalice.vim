" vim:set ts=8 sts=2 sw=2 tw=0 nowrap:
"
" chalice.vim - 2ch viewer 'Chalice' /
"
" Last Change: 25-Nov-2001.
" Written By:  Muraoka Taro <koron@tka.att.ne.jp>

scriptencoding cp932

" 使い方
"   chaliceディレクトリを'runtimepath'に通してからVimを起動して:Chaliceを実行
"     :set runtimepath+=$HOME/chalice
"     :Chalice

" プラグインの無効化フラグ
if exists('plugin_chalice_disable')
  finish
endif

" グローバル関数
"   ChaliceIsRunning()
"   ChaliceDebug()

"------------------------------------------------------------------------------
" ユーザが設定可能なグローバル変数

" ユーザ名/匿名書き時の名前設定
if !exists('g:chalice_username')
  let g:chalice_username = '名無しさん@Vim%Chalice'
endif
if !exists('g:chalice_anonyname')
  let g:chalice_anonyname = ''
endif

" メールアドレス
if !exists('g:chalice_usermail')
  let g:chalice_usermail = ''
endif

" ブックマークデータファイル
if !exists('g:chalice_bookmark')
  let g:chalice_bookmark = ''
endif

" ジャンプ履歴の最大サイズ
if !exists('g:chalice_jumpmax')
  let g:chalice_jumpmax = 100
endif

" リロードタイム
"   g:chalice_reloadinterval_boardlist	板一覧のリロードタイム(1週間)
"   g:chalice_reloadinterval_threadlist	板のリロードタイム(1時間)
"   g:chalice_reloadinterval_thread	スレのリロードタイム(5分間/未使用)
if !exists('g:chalice_reloadinterval_boardlist')
  let g:chalice_reloadinterval_boardlist = 604800
endif
if !exists('g:chalice_reloadinterval_threadlist')
  let g:chalice_reloadinterval_threadlist = 3600
endif
"   g:chalice_reloadinterval_thread	スレのリロードタイム(5分間/未使用)
if !exists('g:chalice_reloadinterval_thread')
  let g:chalice_reloadinterval_thread = 300
endif

" マルチユーザ設定
if !exists('g:chalice_multiuser')
  let g:chalice_multiuser = has('unix') ? 1 : 0
endif

" 外部ブラウザの指定(非Windows環境)
if !exists('g:chalice_exbrowser')
  let g:chalice_exbrowser = ''
endif

" ユーザファイルの位置設定
if !exists('g:chalice_basedir')
  if g:chalice_multiuser
    if has('win32') || has('mac')
      let g:chalice_basedir = $HOME . '/vimfiles/chalice'
    else
      let g:chalice_basedir = $HOME . '/.vim/chalice'
    endif
  else
    let g:chalice_basedir = substitute(expand('<sfile>:p:h'), '[/\\]plugin$', '', '')
  endif
endif

" PROXYとか書き加えると良いかも
if !exists('g:chalice_curl_options')
  let g:chalice_curl_options= ''
endif

" gzip圧縮使用フラグ
if !exists('g:chalice_gzip')
  let g:chalice_gzip = 1
endif

" 0以上に設定するとデバッグ用にメッセージが多めに入ってる
if !exists('g:chalice_verbose')
  let g:chalice_verbose = 0
endif

"------------------------------------------------------------------------------
" 定数値
"   将来はグローバルオプション化できそうなの。もしくはユーザが書き換えても良
"   さそうなの。

let s:prefix_board = '  スレ一覧 '
let s:prefix_thread = '  スレッド '
let s:prefix_write = '  書込スレ '
let s:label_vimtitle = 'Chalice ～2ちゃんねる閲覧プラグイン～'
let s:label_boardlist = '板一覧'
let s:label_boardcategory_mark = '■'
let s:label_newthread = '[新スレ]'
let s:label_bookmark = '  スレの栞'
" メッセージ
let s:msg_confirm_appendwrite_yn = 'バッファの内容が書き込み可能です. 書き込みますか?(yes/no): '
let s:msg_confirm_appendwrite_ync = '本当に書き込みますか?(yes/no/cancel): '
let s:msg_confirm_replacebookmark = 'ガイシュツURLです. 置き換えますか?(yes/no/cancel): '
let s:msg_prompt_pressenter = '続けるには Enter を押してください.'
let s:msg_warn_oldthreadlist = 'スレ一覧が古い可能性があります. R で更新します.'
let s:msg_warn_bookmark = '栞は閉じる時に自動的に保存されます.'
let s:msg_warn_bmkcancel = '栞への登録はキャンセルされました.'
let s:msg_wait_threadformat = '貴様ら!! スレッド整形中のため、しばらくお待ちください...'
let s:msg_wait_download = 'ダウンロード中...'
let s:msg_error_nocurl = 'Chaliceには正しくインストールされたcURLが必要です.'
let s:msg_error_noconv = 'Chaliceを非CP932環境で利用するには qkc もしくは nkf が必要です.'
let s:msg_error_cantjump = 'カーソルの行にアンカーはありません. 鬱氏'
let s:msg_error_appendnothread = 'ゴルァ!! スレッドがないYO!!'
let s:msg_error_creatnoboard = '板を指定しないと糞スレすらも建ちません'
let s:msg_error_writebufhead = '書き込みバッファのヘッダが不正です.'
let s:msg_error_writebufbody = '書き込みメッセージが空です.'
let s:msg_error_writeabort = '書き込みを中止しました.'
let s:msg_error_writecancel = '書き込みをキャンセルします.'
let s:msg_error_writetitle = '新スレにはタイトルが必要です.'
let s:msg_error_addnothread = 'まだスレを開いていないので登録出来ません.'
let s:msg_error_addnothreadlist = 'スレ一覧から栞へ登録出来ません.'
let s:msg_error_nocachedir = 'キャッシュディレクトリを作成出来ません.'
let s:msg_chalice_quit = 'Chalice ～～～～～～～～終了～～～～～～～～'
let s:msg_chalice_start = 'Chalice キボンヌ'
" 1行ヘルプ
let s:msg_help_boardlist = '(板一覧)  <CR>:板決定  j/k:板選択  h/l:カテゴリ閉/開  R:更新'
let s:msg_help_threadlist = '(スレ一覧)  <CR>:スレ決定 j/k:スレ選択  R:更新'
let s:msg_help_thread = '(スレッド)  i:書込  I:sage書込  a:匿名書込  A:匿名sage  r:更新'
let s:msg_help_bookmark = '(スレの栞)  <CR>:URL決定  h/l:閉/開 <C-A>:閉じる  [編集可能]'
let s:msg_help_write = '(書き込み)  <C-CR>:書き込み実行  <C-W>c:閉じる  [編集可能]'

"------------------------------------------------------------------------------
" 定数値
"   内部でのみ使用するもの

" デバッグフラグ (DEBUG FLAG)
let s:debug = 0

" 2ch依存データ
let s:encoding = 'cp932'
" 2chのメニュー取得用初期データ
let s:menu_host = 'www.2ch.net'
let s:menu_remotepath = 'newbbsmenu.html'
let s:menu_localpath = 'bbsmenu'
" ウィンドウ識別子
let s:buftitle_boardlist  = 'Chalice_2ちゃんねる_板一覧'
let s:buftitle_threadlist = 'Chalice_2ちゃんねる_スレ一覧'
let s:buftitle_thread	  = 'Chalice_2ちゃんねる_スレッド'
let s:buftitle_write	  = 'Chalice_2ちゃんねる_書き込み'
" 書き込み時の文字コード問題を避けるため定文字列
let s:urlencoded_write = '%8F%91%82%AB%8D%9E%82%DE' " 書き込み
let s:urlencoded_newwrite = '%90V%8BK%83X%83%8C%83b%83h%8D%EC%90%AC' " 新スレ

" スクリプトIDを取得
map <SID>xx <SID>xx
let s:sid = substitute(maparg('<SID>xx'), 'xx$', '', '')
unmap <SID>xx

" 起動フラグ
let s:opend = 0

" 外部コマンド実行ファイル名
let s:cmd_curl = ''
let s:cmd_conv = ''
let s:cmd_gzip = ''

" コマンドの設定
command! Chalice			call <SID>ChaliceOpen()

" オートコマンドの設定
augroup Chalice
autocmd!
execute "autocmd BufHidden " . s:buftitle_write . " call <SID>DoWriteBuffer('closing')"
execute "autocmd BufEnter " . s:buftitle_boardlist . " redraw!|call s:EchoH('WarningMsg',s:msg_help_boardlist)|normal! 0"
execute "autocmd BufEnter " . s:buftitle_threadlist . " redraw!|call s:EchoH('WarningMsg',s:opened_bookmark?s:msg_help_bookmark : s:msg_help_threadlist)"
execute "autocmd BufEnter " . s:buftitle_thread . " redraw!|call s:EchoH('WarningMsg',s:msg_help_thread)"
execute "autocmd BufEnter " . s:buftitle_write . " let &undolevels=s:undolevels|call s:EchoH('WarningMsg', s:msg_help_write)"
execute "autocmd BufLeave " . s:buftitle_write . " set undolevels=0"
execute "autocmd BufDelete " . s:buftitle_threadlist . " if s:opened_bookmark|call s:CloseBookmark()|endif"
augroup END

"
" URLをChaliceで開く
"
function! s:HandleURL(url, flag)
  " 通常のURLだった場合、無条件で外部ブラウザに渡している。URLの形をみて2ch
  " ならば内部で開く。
  if a:url !~ '\(http\|ftp\)://[-#%&+,./0-9:;=?A-Za-z_~]\+'
    return 0
  endif
  if a:flag =~ '\c\<external\>' || !s:Parse2chURL(a:url)
    " 強制的に外部ブラウザを使用するように指定されたかURLが、2chではない時
    call s:OpenURL(a:url)
  else
    " URLが2chと判断される時
    "	s:parse2ch_host, s:parse2ch_board, s:parse2ch_datはUpdateThread()内
    "	で設定される暗黙的な戻り値。
    call s:UpdateThread('', s:parse2ch_host, s:parse2ch_board, s:parse2ch_dat . '.dat', 'continue')
    if a:flag !~ '\c\<noaddhist\>'
      call s:AddHistoryJump(b:host, b:board, b:dat, line('.'))
    endif
  endif
  return 1
endfunction

"
" URLを外部ブラウザに開かせる
"   TODO: '&'を含むURLを正しく開けるようにする。
"
function! s:OpenURL(url)
  let retval = 0
  if a:url == ''
    return retval
  endif
  let url = a:url
  if has('win32')
    " Windows環境での外部ブラウザ起動
    if !has('win95')
      " NT系ではこっちの方がうまく行くことが多い
      silent execute '!start /min cmd /c start ' . url
    else
      silent! execute "!start rundll32 url.dll,FileProtocolHandler " . a:url
    endif
    let retval = 1
  elseif g:chalice_exbrowser != ''
    " 非Windows環境での外部ブラウザ起動
    let excmd = substitute(g:chalice_exbrowser, '%URL%', a:url, 'g')
    call s:DoExternalCommand(excmd)
    let retval = 1
  endif

  redraw!
  if retval
    let msg =  "Open " . a:url . " with your browser"
  else
    let msg = "Chalice:OpenURL is not implemented:" . a:url
  endif
  call s:EchoH('WarningMsg', msg)
  return retval
endfunction

"
" 書き込み内のリンクを処理
"
function! s:HandleJump(flag)
  call s:GoBuf_Thread()
  let context = getline('.')
  let mx1 = '>>\(\(\d\+\)\(-\d\+\)\?\)'
  let mx2 = '\(\(h\?ttp\|ftp\)://[-#%&+,./0-9:;=?A-Za-z_~]\+\)'
  if context =~ mx1
    " スレの記事番号だった場合
    let num = substitute(matchstr(context, mx1), mx1, '\2', '')
    if a:flag =~ '\c\<internal\>'
      let lold = line('.')
      let lnum = search('^' . num . '  ', 'bw')
      if lnum
	" 参照元をヒストリに入れる
	"call s:AddHistoryJump(b:host, b:board, b:dat, lold)
	" 参照先をヒストリに入れる
	call s:AddHistoryJump(b:host, b:board, b:dat, lnum)
	silent normal! zt
      endif
    elseif a:flag =~ '\c\<external\>'
      if b:host != '' && b:board != '' && b:dat != ''
	let num = substitute(matchstr(context, mx1), mx1, '\1', '')
	call s:OpenURL('http://' . b:host . '/test/read.cgi' . b:board . '/' . substitute(b:dat, '\.dat$', '', '') . '/' . num . 'n')
      endif
    endif
  elseif context =~ mx2
    let url = substitute(matchstr(context, mx2), '^ttp', 'http', '')
    return s:HandleURL(url, a:flag)
  else
    call s:EchoH('ErrorMsg', s:msg_error_cantjump)
  endif
endfunction

"
" スレッドの更新を行なう
"
function! s:UpdateThread(title, host, board, dat, flag)
  call s:GoBuf_Thread()
  if a:title != ''
    " スレのタイトルをバッファ名に設定
    let b:title = s:prefix_thread . a:title
    let b:title_raw = a:title
  endif
  if a:host != ''
    let b:host = a:host
  endif
  if a:board != ''
    let b:board = a:board
  endif
  if a:dat != ''
    let b:dat =  a:dat
  endif
  if b:host == '' || b:board == '' || b:dat == ''
    " TODO: 何かエラー処理が欲しい
    return
  endif

  " パスを生成してスレッドの内容をダウンロード
  let local = 'dat_' . b:host . substitute(b:board, '/', '_', 'g') . '_' . substitute(b:dat, '\.dat$', '', '')
  let remote = b:board . '/dat/' . b:dat
  if !filereadable(s:dir_cache . local) || a:flag !~ '\c\<noforce\>'
    call s:HttpDownload(b:host, remote, local, a:flag)
  endif

  " スレッドをバッファにロードして整形
  call s:ClearBuffer()
  silent! execute "read " . s:dir_cache . local
  normal! gg"_dd

  " 待ってね☆メッセージ
  call s:EchoH('WarningMsg', s:msg_wait_threadformat)

  " a:titleが設定されていない時、1の書き込みからスレ名を判断する
  if a:title == ''
    let title = substitute(getline('.'), '^.\+<>\(.\+\)$', '\1', '')
    if title != ''
      " スレのタイトルをバッファ名に設定
      let b:title = s:prefix_thread . title
      let b:title_raw = title
    endif
  endif

  " 各書き込みに番号を振る
  let i = 1
  let endline = line('$')
  while i <= endline
    call setline(i, i . '<>' . getline(i))
    let i = i + 1
  endwhile

  " 書き込み時情報の切り分け
  "   スレのdatのフォーマットは、直前に行頭に行(記事)番号を付けているので:
  "	番号<>名前<>メール<>時間<>本文<>スレ名
  "   となる。スレ名は先頭のみ
  if 1
    " 速いがスタックエラーで落ちる可能性がある。諸刃の剣。
    " それでも落ちることは少なくなったはずだが…
    let m1 = '\(\%([^<]\|<[^<>]\)*\)<>' " (<>を含まない文字列)<> にマッチ
    let m2 = '\(.*\)<>'
    let mx = '^\(\d\+\)<>' .m1.m1.m1.m2. '\(.*\)$'
  else
    " 遅いがスタックエラーでは落ちない
    let mx = '^\(\d\+\)<>\(.*\)<>\(.*\)<>\(.*\)<>\(.*\)<>\(.*\)$'
  endif
  let out = '\r--------\r\1  From:\2  Date:\4  Mail:\3\r  \5'
  silent! execute '%s/\s*<>\s*/<>/g'
  silent! execute '%s/' . mx . '/' . out
  " 本文の改行処理
  silent! execute '%s/\s*<br>\s*/\r  /g'

  " <A>タグ消し
  silent! execute '%s/<\/\?a[^>]*>//g'
  " 個人キャップの<b>タグ消し
  silent! execute '%s/\s*<\/\?b>//g'
  " 特殊文字潰し
  silent! execute '%s/&amp;/\&/g'
  silent! execute '%s/&gt;/>/g'
  silent! execute '%s/&lt;/</g'
  silent! execute '%s/&quot;/"/g'
  silent! execute '%s/&nbsp;/ /g'

  normal! gg"_ddGzb
  redraw!
  call s:EchoH('WarningMsg', s:msg_help_thread)
endfunction

"
" 板内容を更新する
"
function! s:UpdateBoard(title, host, board, force)
  call s:CloseBookmark()
  " スレッドリストに移動して 1.板タイトル 2.ホスト 3.板IDを設定する
  call s:GoBuf_ThreadList()
  if a:title != ''
    let b:title = s:prefix_board . a:title
    let b:title_raw = a:title
  else
    let b:title = s:prefix_board . b:title_raw
  else
  endif
  if a:host != ''
    let b:host = a:host
  endif
  if a:board != ''
    let b:board = a:board
  endif
  if b:host == '' || b:board == ''
    " TODO: 何かエラー処理が欲しい
    return
  endif

  " パスを生成してスレ一覧をダウンロード
  let local = "subject_" . b:host . substitute(b:board, '/', '_', 'g')
  let remote = b:board . '/subject.txt'
  let updated = 0
  if a:force || !filereadable(s:dir_cache . local) || localtime() - getftime(s:dir_cache . local) > g:chalice_reloadinterval_threadlist
    call s:HttpDownload(b:host, remote, local, '')
    let updated = 1
  endif

  " スレ一覧をバッファにロードして整形
  call s:ClearBuffer()
  silent! execute "read " . s:dir_cache . local

  " スレデータ(.dat)ではない行を削除
  silent! execute '%g!/^\d\+\.dat/delete _'
  " .dat名を隠蔽
  silent! execute '%s/^\(\d\+\.dat\)<>\(.*\)$/ \2\t\t\t\t\1'
  " 特殊文字潰し
  silent! execute '%s/&amp;/\&/g'
  silent! execute '%s/&gt;/>/g'
  silent! execute '%s/&lt;/</g'

  silent! normal! gg0

  if !updated
    redraw!
    call s:EchoH('WarningMsg', s:msg_warn_oldthreadlist)
  endif
endfunction

"------------------------------------------------------------------------------
" 暫定的に固まった関数群 
" FIXED FUNCTIONS

function! s:ClearBuffer()
  "normal! gg"_dG0
  silent! execute '%delete _'
endfunction

"
" ディレクトリ作成のラッパー
"
function! s:MakeDir(dir)
  let fq = s:GetFileQuote()

  let dir = fq . substitute(a:dir, '[/\\]$', '', '') . fq
  if has('win32') && &shell !~ 'sh'
    call s:DoExternalCommand('mkdir ' . substitute(dir, '/', '\\', 'g'))
  else
    call s:DoExternalCommand('mkdir -p ' . dir)
  endif
endfunction

"
" ハイライトを指定したメッセージ表示
"
function! s:EchoH(hlname, msgstr)
  execute "echohl " . a:hlname
  echo a:msgstr
  echohl None
endfunction

"
" Chalice終了
"
function! s:ChaliceClose(flag)
  if !s:opend
    return
  endif
  silent! call s:CommandUnregister()
  " ブックマークが開かれていた場合閉じることで保存する
  if s:opened_bookmark
    call s:CloseBookmark()
  endif
  if a:flag =~ '\<all\>'
    execute "qall!"
  endif
  let s:opend = 0

  " 変更したグローバルオプションの復帰
  let &charconvert = s:charconvert
  let &foldcolumn = s:foldcolumn
  let &ignorecase = s:ignorecase
  let &lazyredraw = s:lazyredraw
  let &wrapscan = s:wrapscan
  let &winwidth = s:winwidth
  let &winheight = s:winheight
  let &statusline = s:statusline
  let &titlestring = s:titlestring
  let &undolevels = s:undolevels

  silent! execute "bw " . s:buftitle_write
  silent! new
  silent! only!
  silent! redraw

  " 終了メッセージ
  call s:EchoH('WarningMsg', s:msg_chalice_quit)
endfunction

function! s:CharConvert()
  if v:charconvert_from == 'cp932' && v:charconvert_to == 'euc-jp' && s:cmd_conv != ''
    call s:DoExternalCommand(s:cmd_conv .'<'. v:fname_in .'>'. v:fname_out)
    return 0
  else
    return 1
  endif
endfunction

function! ChaliceDebug()
  echo "s:cmd_curl=".s:cmd_curl
  echo "s:cmd_conv=".s:cmd_conv
  echo "s:cmd_gzip=".s:cmd_gzip
  echo "s:dir_cache=".s:dir_cache
  echo "g:chalice_bookmark=".g:chalice_bookmark
endfunction

"
" 動作環境をチェック
"
function! s:CheckEnvironment()
  " 独自のpathを取得・設定
  if has('win32')
    let path = substitute(substitute($PATH, '\\', '/', 'g'), ';', ',', 'g')
  else
    let path = substitute($PATH, ':', ',', 'g')
  endif
  
  " cURLのパスを取得
  let curl_exe = 'curl' . (has('win32') ? '.exe' : '')
  if globpath(path, curl_exe) != ''
    " cURLはPATH内にあるので普通に実行可能
    let s:cmd_curl = 'curl'
  else
    let s:cmd_curl = globpath($VIM, curl_exe)
    if s:cmd_curl == ''
      call s:EchoH('ErrorMsg', s:msg_error_nocurl)
      return 0
    elseif s:cmd_curl =~ ' '
      let fq = s:GetFileQuote()
      let s:cmd_curl = fq . s:cmd_curl . fq
    endif
  endif

  " 非CP932環境ではコンバータを取得する必要がある。
  if &encoding != 'cp932'
    if globpath(path, 'qkc') != ''
      let s:cmd_conv = 'qkc -e -u'
    else
      if globpath(path, 'nkf') != ''
	let s:cmd_conv = 'nkf -e'
      else
	" qkc/nkfが見つからない
	call s:EchoH('ErrorMsg', s:msg_error_noconv)
	return 0
      endif
    endif
  else
    let s:cmd_conv = ''
  endif

  " gzipを探す
  let gzip_exe = 'gzip' . (has('win32') ? '.exe' : '')
  if globpath(path, gzip_exe) != ''
    let s:cmd_gzip = 'gzip'
  endif

  " ディレクトリ情報構築
  let s:dir_cache = g:chalice_basedir . '/cache/'
  if g:chalice_bookmark == ''
    let g:chalice_bookmark = g:chalice_basedir . '/chalice.bmk'
  endif

  " キャッシュディレクトリの保証
  if !isdirectory(s:dir_cache)
    call s:MakeDir(s:dir_cache)
    if !isdirectory(s:dir_cache)
      redraw!
      call s:EchoH('ErrorMsg', s:msg_error_nocachedir)
      return 0
    endif
  endif

  return 1
endfunction

"
" Chalice開始
"
function! s:ChaliceOpen()
  if s:opend
    return
  endif

  " 動作環境のチェック
  if !s:CheckEnvironment()
    return
  endif

  " 変更するグローバルオプションの保存
  let s:opend = 1
  let s:charconvert = &charconvert
  let s:foldcolumn = &foldcolumn
  let s:ignorecase = &ignorecase
  let s:lazyredraw = &lazyredraw
  let s:wrapscan = &wrapscan
  let s:winwidth = &winwidth
  let s:winheight = &winheight
  let s:statusline = &statusline
  let s:titlestring = &titlestring
  let s:undolevels = &undolevels

  " グローバルオプションを変更
  if s:cmd_conv != ''
    let &charconvert = s:sid . 'CharConvert()'
  endif
  set foldcolumn=0
  set ignorecase
  set lazyredraw
  set wrapscan
  set winheight=8
  set winwidth=15
  let &statusline = '%{' . s:sid . 'GetBufferTitle()}%=%l/%L'
  let &titlestring = s:label_vimtitle
  set undolevels=0

  call s:CommandRegister()
  call s:OpenAllChaliceBuffers()
  call s:UpdateBoardList(0)
  silent! redraw

  " 開始メッセージ表示
  call s:EchoH('WarningMsg', s:msg_chalice_start)
endfunction

"
" 外部コマンドを実行
"   verboseレベルに応じた方法で実行する。
"
function! s:DoExternalCommand(cmd)
  let extcmd = a:cmd
  if has('win32') && &shell =~ '\c\<cmd\>'
    let extcmd = '"' . extcmd . '"'
  endif
  if g:chalice_verbose < 1
    return system(extcmd)
  elseif g:chalice_verbose < 2
    silent! execute ':!' . extcmd
  else
    execute ':!' . extcmd
  endif
endfunction

"
" 文字列の先頭と末尾の空白を削除する
"
function! s:TrimSpace(str)
  return substitute(a:str, '^\s\+\|\s\+$', '', '')
endfunction

"
" 現在のカーソル行のスレッドを開く
"
function! s:OpenThread(...)
  let flag = (a:0 > 0) ? a:1 : 'internal'
  let curline = getline('.')
  let mx1 = '^ \(.\+\) (\d\+)\s\+\(\d\+\.dat\)'
  let mx2 = '\(http://[-#%&+,./0-9:;=?A-Za-z_~]\+\)'

  if curline =~ mx1
    let host = b:host
    let board = b:board
    let title = substitute(curline, mx1, '\1', '')
    let dat = substitute(curline, mx1, '\2', '')
    let url = 'http://' . host . '/test/read.cgi' . board . '/'. substitute(dat, '\.dat$', '', '') . '/l50'
  elseif curline =~ mx2
    let url = matchstr(curline, mx2)
  else
    normal! za
    return
  endif

  call s:HandleURL(url, flag . ',noaddhist')
  if flag =~ '\c\<firstline\>'
    normal! gg
  endif
  call s:AddHistoryJump(b:host, b:board, b:dat, line('.'))
endfunction

"
" 現在のカーソル行の板を開く
"
function! s:OpenBoard(...)
  let board = getline('.')
  let mx = '^ \(\S\+\)\s\+http://\([^/]\+\)\(/\S*\).*$'
  if board !~ mx
    " foldの開閉をトグル
    normal! za
    return
  endif

  let title = substitute(board, mx, '\1', '')
  let host = substitute(board, mx, '\2', '')
  let board = substitute(substitute(board, mx, '\3', ''), '/$', '', '')

  " デバッグ表示用
  if 0
    let mes = ''
    let mes = mes . "title=" . title . " host=" . host . " board=" . board
    execute "normal! i" . mes "\<CR>"
  else
    if a:0 > 0 && a:1 =~ '\<external\>'
      return s:OpenURL('http://' . host . board . '/')
    endif
    call s:UpdateBoard(title, host, board, 0)
  endif
endfunction

"
" 与えられたURLを2chかどうか判断しる!!
"
function! s:Parse2chURL(url)
  let mx = '^http://\([^/]\+\)/test/read.cgi\(/[^/]\+\)/\(\d\+\).*'
  if a:url !~ mx
    return 0
  endif
  let s:parse2ch_host = substitute(a:url, mx, '\1', '')
  let s:parse2ch_board = substitute(a:url, mx, '\2', '')
  let s:parse2ch_dat = substitute(a:url, mx, '\3', '')
  return 1
endfunction

"
" 任意のバッファタイトルをstatuslineで表示するためのラッパー
"
function! s:GetBufferTitle()
  if !exists('b:title')
    return bufname('%')
  else
    return b:title
  endif
endfunction

" s:OpenAllChaliceBuffers
"   Chalice用のバッファを一通り全て開いてしまう
function! s:OpenAllChaliceBuffers()
  " スレッド用バッファを開く
  silent! execute "edit! " . s:buftitle_thread
  setlocal filetype=2ch_thread
  let b:title = s:prefix_thread

  " 板一覧用バッファを開く
  silent! execute "15vnew! " . s:buftitle_boardlist
  setlocal filetype=2ch_boardlist
  let b:title = s:label_boardlist

  " スレッド一覧用バッファ(==板)を開く
  call s:GoBuf_Thread()
  silent! execute "10new! " . s:buftitle_threadlist
  setlocal filetype=2ch_threadlist
  let b:title = s:prefix_board
endfunction

"
" HTTPダウンロードの関数:
"   将来はwgetに依存しないようにしたい。
"
function! s:HttpDownload(host, remotepath, localpath, flag)
  redraw!
  call s:EchoH('WarningMsg', s:msg_wait_download)

  let local = s:dir_cache . a:localpath
  let url = 'http://' . a:host . '/' . substitute(a:remotepath, '^/', '', '')
  let continued = 0
  let compressed = 0

  " 起動オプションの構築→cURLの実行
  let fq = s:GetFileQuote()
  let opts = g:chalice_curl_options

  " 継続ロードのオプション設定
  if a:flag =~ '\<continue\>'
    let size = getfsize(local)
    if size > 0
      let continued = 1
      let opts = ' ' . opts . '-C ' . size
    endif
  endif

  " 圧縮ロードのオプション設定
  if !continued && g:chalice_gzip && s:cmd_gzip != ''
    let compressed = 1
    let local = local . '.gz'
    let opts = ' -H Accept-Encoding:gzip,deflate'
  endif

  " コマンド構成ダウンロード
  let opts = opts . ' -o ' . fq . local . fq . ' ' . fq . url . fq
  call s:DoExternalCommand(s:cmd_curl . ' ' . opts)

  if compressed
    " 解凍中～
    call s:DoExternalCommand(s:cmd_gzip . ' -d -f ' . fq . local . fq)
    if filereadable(local)
      call rename(local, substitute(local, '\.gz$', '', ''))
    endif
  endif

  redraw!
endfunction

"
" 板一覧のバッファを更新
"
function! s:UpdateBoardList(force)
  call s:GoBuf_BoardList()
  let b:title = s:label_boardlist

  let local = s:dir_cache . s:menu_localpath
  " 板一覧の読み込みと整形
  if a:force || !filereadable(local) || localtime() - getftime(local) > g:chalice_reloadinterval_boardlist
    call s:HttpDownload(s:menu_host, s:menu_remotepath, s:menu_localpath, '')
  endif
  call s:ClearBuffer()
  silent! execute 'read ' . local
  " 改行<BR>を本当の改行に
  silent! execute "%s/\\c<br>/\r/g"
  " カテゴリと板へのリンク以外を消去
  silent! execute '%g!/^<[AB]/delete _'
  " カテゴリを整形
  silent! execute '%s/^<B>\([^<]*\)<\/B>/' . s:label_boardcategory_mark . '\1/'
  " 板名を整形
  silent! execute '%s/^<A HREF=\([^ ]*\)[^>]*>\([^<]*\)<\/A>/ \2\t\t\t\t\1'
  " 「2ch総合案内」を削除…本当はちゃんとチェックしなきゃダメだけど。
  normal! gg"_dd0

  " folding作成
  silent! normal! gg
  while 1
    silent! execute '.,/\n\(\■\)\@=\|\%$/fold'
    let prev = line('.')
    silent! normal! j
    if prev == line('.')
      break
    endif
  endwhile
  silent normal! gg
endfunction

"
" Chalice起動確認
"
function! ChaliceIsRunning()
  return s:opend
endfunction

function! s:GetFileQuote()
  if &shellxquote == '"'
    return "'"
  else
    return '"'
  endif
endfunction

"------------------------------------------------------------------------------
" MOVE AROUND BUFFER
" バッファ移動用関数

function! s:GoBuf_Write()
  let retval = s:SelectWindowByName(s:buftitle_write)
  if retval < 0
    silent! execute "rightbelow split " . s:buftitle_write
    setlocal filetype=2ch_write
  endif
  return retval
endfunction
function! s:GoBuf_Thread()
  let retval = s:SelectWindowByName(s:buftitle_thread)
  return retval
endfunction
function! s:GoBuf_BoardList()
  let retval = s:SelectWindowByName(s:buftitle_boardlist)
  if retval >= 0
    execute "normal! 15\<C-w>|"
  endif
  return retval
endfunction
function! s:GoBuf_ThreadList()
  let retval = s:SelectWindowByName(s:buftitle_threadlist)
  if retval >= 0
    execute "normal! 10\<C-w>_0"
  endif
  return retval
endfunction

"
" s:SelectWindowByName(name) [global function]
"   Acitvate selected window by a:name.
"
function! s:SelectWindowByName(name)
  let num = bufwinnr(a:name)
  if num >= 0 && num != winnr()
    execute 'normal! ' . num . "\<C-W>\<C-W>"
  endif
  return num
endfunction

"------------------------------------------------------------------------------
" JUMPLIST
" 独自のジャンプリスト

let s:jumplist_current = 0
let s:jumplist_max = 0

function! s:JumplistClear()
  let s:jumplist_current = 0
  let s:jumplist_max = 0
endfunction

function! s:JumplistCurrent()
  return s:jumplist_max > 0 ? s:jumplist_data_{s:jumplist_current} : -1
endfunction

function! s:JumplistAdd(data)
  if s:jumplist_max > 0
    let s:jumplist_current = s:jumplist_current + 1
  else
    let s:jumplist_current = 0
  endif
  let s:jumplist_data_{s:jumplist_current} = a:data
  let s:jumplist_max = s:jumplist_current + 1

  " 履歴が増えすぎないように制限
  if s:jumplist_max > g:chalice_jumpmax
    let newmax = g:chalice_jumpmax / 2
    let src = s:jumplist_max - newmax
    let dest = 0
    while dest < newmax
      let s:jumplist_data_{dest} = s:jumplist_data_{src}
      let src = src + 1
      let dest = dest + 1
    endwhile
    let s:jumplist_max = newmax
    let s:jumplist_current = newmax - 1
  endif
endfunction

function! s:JumplistNext()
  if s:jumplist_current >= s:jumplist_max - 1
    let s:jumplist_current = s:jumplist_max - 1
    return -1
  endif
  let s:jumplist_current = s:jumplist_current + 1
  let retval = s:jumplist_data_{s:jumplist_current}
  return retval
endfunction

function! s:JumplistPrev()
  if s:jumplist_max <= 0 || s:jumplist_current <= 0
    let s:jumplist_current = 0
    return -1
  endif
  let s:jumplist_current = s:jumplist_current - 1
  let retval = s:jumplist_data_{s:jumplist_current}
  return retval
endfunction

" ダンプ
function! s:JumplistDump()
  let i = 0
  call s:EchoH('Title',  'Chalice Jumplist (size=' . s:jumplist_max . ')')
  while i < s:jumplist_max
    let padding = i == s:jumplist_current ? '---->' : '     '
    let numstr = matchstr(padding . i, '......$')
    let indicator = (i == s:jumplist_current) ? ' > ' : '  '
    echo numstr . ': ' . s:jumplist_data_{i}
    let i = i + 1
  endwhile
endfunction

"
" 独自ジャンプリストのデバッグ用コマンド
"
if s:debug
  command! JumplistClear			call <SID>JumplistClear()
  command! -nargs=1 JumplistAdd		call <SID>JumplistAdd(<q-args>)
  command! JumplistPrev			echo "Prev: " . <SID>JumplistPrev()
  command! JumplistNext			echo "Next: " . <SID>JumplistNext()
  command! JumplistDump			call <SID>JumplistDump()
endif

"
" ジャンプ履歴に項目を追加
"
function! s:AddHistoryJump(host, board, dat, value)
  if s:JumplistCurrent() != a:value
    call s:JumplistAdd(a:host . ' ' . a:board . ' ' . a:dat . ' ' . a:value)
  endif
endfunction

"
" 履歴をジャンプ
function! s:DoHistoryJump(flag)
  let data = 0
  if a:flag =~ '\c\<next\>'
    let data = s:JumplistNext()
  elseif a:flag =~ '\c\<prev\>'
    let data = s:JumplistPrev()
  endif

  let mx = '^\(\S\+\) \(\S\+\) \(\S\+\) \(\S\+\)'
  if data =~ mx
    " TODO: もっと高度なジャンプを!!
    let host = substitute(data, mx, '\1', '')
    let board = substitute(data, mx, '\2', '')
    let dat = substitute(data, mx, '\3', '')
    let lnum = substitute(data, mx, '\4', '')
    call s:GoBuf_Thread()
    if host != b:host || board != b:board || dat != b:dat
      call s:UpdateThread('', host, board, dat, 'continue,noforce')
    endif
    let opt = (lnum >= line('$') ? 'zb' : 'zt')
    silent! execute "normal! " . lnum . "G" . opt
  endif
endfunction
function! s:JumpPrev()
endfunction

"------------------------------------------------------------------------------
" URL ENCODING
" URLエンコード

"
" 数値を16進数を表す文字列に変換する。(:help eval-examplesより)
"
function! s:Nr2Hex(nr)
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  return r
endfunction

"
" 与えられた文字列をURLエンコードして返す。
"
function! s:URLEncode(instr)
  let len = strlen(a:instr)
  let i = 0
  let outstr = ''
  while i < len
    let ch = a:instr[i]
    if ch =~ '[-*.0-9A-Z_a-z]'
      let outstr = outstr . ch
    elseif ch == ' '
      let outstr = outstr . '+'
    else
      let outstr = outstr . '%' . substitute('0' . s:Nr2Hex(char2nr(ch)), '^.*\(..\)$', '\1', '')
    endif
    let i = i + 1
  endwhile
  return outstr
endfunction

"------------------------------------------------------------------------------
" BOOKMARK FUNCTIONS
" Bookmarkルーチン
"
let s:opened_bookmark = 0

"
" スレ一覧の内容を削除し、ブックマークをファイルから読み込み表示する。
"
function! s:OpenBookmark()
  if s:opened_bookmark
    return
  endif
  call s:GoBuf_ThreadList()
  let s:opened_bookmark = line('.') ? line('.') : 1
  let b:title = s:label_bookmark
  " 栞データの読込み
  call s:ClearBuffer()
  setlocal filetype=2ch_bookmark
  silent! execute "read " . g:chalice_bookmark
  silent! normal! gg"_dd
  redraw!
  call s:EchoH('WarningMsg', s:msg_warn_bookmark)
endfunction

"
" ブックマークをファイルに保存し、バッファを消去する。
"
function! s:CloseBookmark()
  if !s:opened_bookmark
    return
  endif
  let s:opened_bookmark = 0
  call s:GoBuf_ThreadList()
  silent! execute "%write! " . g:chalice_bookmark
  call s:ClearBuffer()

  " ftをセットした瞬間に必要なバッファ変数が消去されてしまうので、その対策。
  " 消去されるバッファ変数は ftplugin/2ch_threadlist.vim 参照:
  "	b:title, b:title_raw, b:host, b:board
  let title_raw = b:title_raw
  let host = b:host
  let board = b:board
  setlocal filetype=2ch_threadlist
  let b:title_raw = title_raw
  let b:host = host
  let b:board = board
endfunction

function! s:AddBookmark(title, url)
  let winnum = winnr()
  call s:OpenBookmark()
  call s:GoBuf_ThreadList()
  let url = a:url

  " 2重登録時
  normal! gg
  let existedbookmark = search(a:url, 'w')
  normal! 0
  if existedbookmark
    echohl Question
    let last_confirm = input(s:msg_confirm_replacebookmark)
    echohl None
    if last_confirm =~ '^\cy'
      silent! execute ':' . existedbookmark . 'delete _'
    elseif last_confirm !~ '^\cn'
      " 登録をキャンセル
      let url = ''
    endif
  endif

  " URLをバッファに書込む
  if url != ''
    call append(0, ' ' . a:title . "\t\t\t\t" . url)
  endif

  execute "normal! " . winnum . "\<C-W>\<C-W>"
  if url == ''
    redraw!
    call s:EchoH('WarningMsg', s:msg_warn_bmkcancel)
  endif
endfunction

function! s:ToggleBookmark(flag)
  if !s:opened_bookmark
    call s:OpenBookmark()
  else
    let lnum = s:opened_bookmark
    call s:UpdateBoard('', '', '', 0)
    call s:GoBuf_ThreadList()
    execute "normal! " . lnum . "G0"
  endif
  if a:flag =~ '\<thread\>'
    call s:GoBuf_Thread()
  elseif a:flag =~ '\<threadlist\>'
    call s:GoBuf_ThreadList()
  endif
endfunction

function! s:Thread2Bookmark(target)
  if a:target =~ '\<thread\>'
    " スレッドから栞に登録
    call s:GoBuf_Thread()
    if b:host == '' || b:board == '' || b:dat == ''
      redraw!
      call s:EchoH('ErrorMsg', s:msg_error_addnothread)
      return
    endif
    let dat = substitute(b:dat, '\.dat$', '', '')
    if b:title_raw == ''
      let title = b:host . b:board . '/' . dat
    else
      let title = b:title_raw
    endif
  elseif a:target =~ '\<threadlist\>'
    " スレ一覧から栞に登録
    call s:GoBuf_ThreadList()
    let curline = getline('.')
    let mx = '^ \(.\+\) (\d\+)\s\+\(\d\+\)\.dat'
    if b:host == '' || b:board == '' || curline !~ mx
      redraw!
      call s:EchoH('ErrorMsg', s:msg_error_addnothreadlist)
      return
    endif
    let title = substitute(curline, mx, '\1', '')
    let dat = substitute(curline, mx, '\2', '')
  endif

  let url = 'http://' . b:host . '/test/read.cgi' . b:board . '/' . dat
  redraw!
  if 0
    echo "title=" . title . " url=" . url
  else
    call s:AddBookmark(title, url)
  endif
endfunction

"------------------------------------------------------------------------------
" WRITE BUFFER
" 書き込みバッファルーチン
"

let s:opened_writebuffer = 0

"
" 書き込み用バッファを開く
"
function! s:OpenWriteBuffer(...)
  " フラグに応じて匿名、sageを自動設定
  let newthread = 0
  let username = g:chalice_username
  let usermail = g:chalice_usermail
  if a:0 > 0
    if a:1 =~ '\<anony\>'
      let username = g:chalice_anonyname
      let usermail = ''
    endif
    if a:1 =~ '\<sage\>'
      let usermail = 'sage'
    endif
    if a:1 =~ '\<new\>'
      let newthread = 1
    endif
  endif

  " スレッドバッファから host, board, dat を取得
  if !newthread
    " 通常の書き込み
    call s:GoBuf_Thread()
    if b:host == '' || b:board == '' || b:dat == ''
      call s:EchoH('ErrorMsg', s:msg_error_appendnothread)
      return 0
    endif
    let title = b:title_raw
    let key = substitute(b:dat, '\.dat$', '', '')
  else
    " TODO 新規書き込み
    call s:GoBuf_ThreadList()
    if b:host == '' || b:board == ''
      call s:EchoH('ErrorMsg', s:msg_error_creatnoboard)
      return 0
    endif
    let title = ''
    let key = localtime()
  endif
  let host = b:host
  let bbs = substitute(b:board, '^/', '', '')

  " バッファの作成
  call s:GoBuf_Write()
  if !newthread
    let b:title = s:prefix_write . title
  else
    let b:title = s:prefix_write . s:label_newthread
  endif
  let b:title_raw = title
  let b:host = host
  let b:bbs = bbs
  let b:key = key
  let b:newthread = newthread
  call s:ClearBuffer()

  redraw
  if 0
    " デバッグ表示
    let mes = ''
    let mes = mes . 'title=' . title . "\<CR>"
    let mes = mes . 'b:host=' . b:host . "\<CR>"
    let mes = mes . 'b:bbs=' . b:bbs . "\<CR>"
    let mes = mes . 'b:key=' . b:key . "\<CR>"
    execute "normal! i" . mes . "\<ESC>"
  else
    let def = ''
    let def = def . 'Title: ' . title . "\<CR>"
    let def = def . 'From: ' . username . "\<CR>"
    let def = def . 'Mail: ' . usermail . "\<CR>"
    let def = def . "--------\<CR>"
    execute "normal! i" . def . "\<ESC>"
  endif
  let s:opened_write = 1
  redraw!
  call s:EchoH('WarningMsg', s:msg_help_write)
  startinsert
endfunction

"
" 書込もう!!。書き込み内容が正しいかチェックしてから書き込み。
"
function! s:DoWriteBuffer(flag)
  if !s:opened_write
    return 0
  endif
  call s:GoBuf_Write()
  let newthread = b:newthread
  " 書き込み実行
  let write_result =  s:DoWriteBufferStub(a:flag)

  " 書き込み後のバッファ処理
  if a:flag =~ '\c\<closing\>'
    let s:opened_write = 0
  elseif write_result != 0
    let s:opened_write = 0
    call s:GoBuf_Write()
    execute ":close"
  endif

  if !s:opened_write
    if !newthread
      call s:GoBuf_Thread()
      normal! zb
    else
      " 新スレ作成時(現在は使われない)
      call s:GoBuf_ThreadList()
    endif
  endif
  return 1
endfunction

function! s:DoWriteBufferStub(flag)
  let force_close = a:flag =~ '\c\<closing\>'
  call s:GoBuf_Write()
  redraw!

  " デバッグ表示
  if 0
    echo 'b:title_raw=' . b:title_raw
    echo 'b:host=' . b:host
    echo 'b:bbs=' . b:bbs
    echo 'b:key=' . b:key
  endif

  " 書き込みバッファヘッダの妥当性検証
  let title = getline(1)
  let name = getline(2)
  let mail = getline(3)
  let sep = getline(4)
  " デバッグ表示
  if 0
    echo 'title=' . title
    echo 'name=' . name
    echo 'mail=' . mail
    echo 'sep=' . sep
  endif
  if title !~ '^Title:\s*' || name !~ '^From:\s*' || mail !~ '^Mail:\s*' || sep != '--------'
    call s:EchoH('ErrorMsg', s:msg_error_writebufhead)
    if force_close
      echohl MoreMsg
      call input(s:msg_prompt_pressenter)
      echohl None
    endif
    return 0
  endif
  let title = s:TrimSpace(substitute(title, '^Title:', '', ''))
  let name = s:TrimSpace(substitute(name, '^From:', '',''))
  let mail = s:TrimSpace(substitute(mail, '^Mail:', '',''))

  " 新スレ作成時にタイトルを設定したか確認
  if b:newthread && title == ''
    call s:EchoH('ErrorMsg', s:msg_error_writetitle)
    if force_close
      echohl MoreMsg
      call input(s:msg_prompt_pressenter)
      echohl None
    endif
    return 0
  endif

  " 本文先頭の空白行を削除
  normal! 5G
  while line('.') > 4
    if getline('.') !~ '^\s*$'
      break
    endif
    normal! "_dd
  endwhile

  " 本文末尾の空白行を削除
  normal! G
  while line('.') > 4
    if getline('.') !~ '^\s*$'
      break
    endif
    normal! "_dd
  endwhile

  " 本文があるかをチェック
  if line('$') < 5
    call s:EchoH('ErrorMsg', s:msg_error_writebufbody)
    if force_close
      echohl MoreMsg
      call input(s:msg_prompt_pressenter)
      echohl None
    endif
    return 0
  endif

  " 本文からメッセージを取得
  let message = getline(5)
  let curline = 6
  let lastline = line('$')
  while curline <= lastline
    let message = message . "\n" . getline(curline)
    let curline = curline + 1
  endwhile
  if 0
    echo "RAW MESSAGE=".message
    echo "MESSAGE=" . s:URLEncode(message)
    call input('---PAUSE---')
  endif

  " (必要ならば)文字コードをeuc-jpからcp932に変換
  if &encoding != s:encoding && has('iconv')
    let title = iconv(title, &encoding, s:encoding)
    let name = iconv(name, &encoding, s:encoding)
    let mail = iconv(mail, &encoding, s:encoding)
    let message = iconv(message, &encoding, s:encoding)
  endif

  " 書き込みデータチャンクを作成
  "   利用すべきデータ変数: name, mail, message, b:bbs, b:key, localtime()
  "   参考URL: http://members.jcom.home.ne.jp/monazilla/document/write.html
  let chunk = ''
  if !b:newthread
    let chunk = chunk . 'submit=' . s:urlencoded_write
  else
    let chunk = chunk . 'subject=' . s:URLEncode(title)
    let chunk = chunk . '&submit=' . s:urlencoded_newwrite
  endif
  let chunk = chunk . '&FROM=' . s:URLEncode(name)
  let chunk = chunk . '&mail=' . s:URLEncode(mail)
  let chunk = chunk . '&MESSAGE=' . s:URLEncode(message)
  let chunk = chunk . '&bbs=' . b:bbs
  " スレッド作成の時はグリニッジ秒が効いてくる?
  if !b:newthread
    let chunk = chunk . '&key=' . b:key
    let chunk = chunk . '&time=' . localtime()
  else
    let chunk = chunk . '&time=' . b:key
  endif

  " 書き込み前の最後の確認
  echohl Question
  if force_close
    " 通常の確認
    let last_confirm = input(s:msg_confirm_appendwrite_yn)
    echohl None
    if last_confirm !~ '^\cy'
      redraw!
      call s:EchoH('ErrorMsg', s:msg_error_writeabort)
      echohl MoreMsg
      call input(s:msg_prompt_pressenter)
      echohl None
      return -1
    endif
  else
    " 選択肢にキャンセルがある確認
    let last_confirm = input(s:msg_confirm_appendwrite_ync)
    echohl None
    if last_confirm =~ '^\cn'
      redraw!
      call s:EchoH('ErrorMsg', s:msg_error_writeabort)
      return -1
    elseif last_confirm !~ '^\cy'
      redraw!
      call s:EchoH('WarningMsg', s:msg_error_writecancel)
      return 0
    endif
  endif

  let tmpfile = tempname()
  redraw!
  execute "redir! > " . tmpfile 
  silent echo chunk
  redir END
  " 書き込みコマンドの発行
  "   必要なデータ変数: tmpflie, b:host, b:bbs
  redraw!
  " 起動オプションの構築→cURLの実行
  let fq = s:GetFileQuote()
  let opts = g:chalice_curl_options
  let opts = opts . ' -b NAME= -b MAIL='
  let opts = opts . ' -d @' . fq .tmpfile . fq
  let opts = opts . ' -e http://' . b:host . '/' . b:bbs . '/index2.html'
  let opts = opts . ' http://' . b:host . '/test/bbs.cgi'
  call s:DoExternalCommand(s:cmd_curl . ' ' . opts)
  " 後始末
  call delete(tmpfile)
  if !b:newthread
    call s:UpdateThread('', '', '', '', 'continue,force')
  else
    call s:UpdateThread(title,  b:host , '/' . b:bbs, b:key . '.dat', '')
  endif
  return 1
endfunction

"------------------------------------------------------------------------------
" COMMAND REGISTER
" コマンド登録ルーチン
"   動的に登録可能なコマンドは動的に登録する
"

function! s:CommandRegister()
  command! ChaliceQuit			call <SID>ChaliceClose('')
  command! ChaliceQuitAll		call <SID>ChaliceClose('all')
  command! ChaliceGoBoardList		call <SID>GoBuf_BoardList()
  command! ChaliceGoThreadList		call <SID>GoBuf_ThreadList()
  command! ChaliceGoThread		call <SID>GoBuf_Thread()
  command! -nargs=? ChaliceOpenBoard	call <SID>OpenBoard(<f-args>)
  command! -nargs=? ChaliceOpenThread	call <SID>OpenThread(<f-args>)
  command! ChaliceHandleJump		call <SID>HandleJump('internal')
  command! ChaliceHandleJumpExt		call <SID>HandleJump('external')
  command! ChaliceReloadBoardList	call <SID>UpdateBoardList(1)
  command! ChaliceReloadThreadList	call <SID>UpdateBoard('', '', '', 1)
  command! ChaliceReloadThread		call <SID>UpdateThread('', '', '', '', 'force')
  command! ChaliceReloadThreadInc	call <SID>UpdateThread('', '', '', '', 'continue,force')
  command! ChaliceDoWrite		call <SID>DoWriteBuffer('')
  command! -nargs=? ChaliceWrite	call <SID>OpenWriteBuffer(<f-args>)
  command! -nargs=1 ChaliceHandleURL	call <SID>HandleURL(<q-args>, 'internal')
  command! -nargs=1 ChaliceBookmarkToggle	call <SID>ToggleBookmark(<q-args>)
  command! -nargs=1 ChaliceBookmarkAdd	call <SID>Thread2Bookmark(<q-args>)
  command! ChaliceJumplist		call <SID>JumplistDump()
  command! ChaliceJumplistNext		call <SID>DoHistoryJump('next')
  command! ChaliceJumplistPrev		call <SID>DoHistoryJump('prev')
endfunction

function! s:CommandUnregister()
  delcommand ChaliceQuit
  delcommand ChaliceQuitAll
  delcommand ChaliceGoBoardList
  delcommand ChaliceGoThreadList
  delcommand ChaliceGoThread
  delcommand ChaliceOpenBoard
  delcommand ChaliceOpenThread
  delcommand ChaliceHandleJump
  delcommand ChaliceHandleJumpExt
  delcommand ChaliceReloadBoardList
  delcommand ChaliceReloadThreadList
  delcommand ChaliceReloadThread
  delcommand ChaliceReloadThreadInc
  delcommand ChaliceWrite
  delcommand ChaliceHandleURL
  delcommand ChaliceBookmarkToggle
  delcommand ChaliceBookmarkAdd
  delcommand ChaliceJumplist
  delcommand ChaliceJumplistNext
  delcommand ChaliceJumplistPrev
endfunction
