" vim:set ts=8 sts=2 sw=2 tw=0 nowrap:
"
" chalice.vim - 2ch viewer 'Chalice' /
"
" Last Change: 07-May-2002.
" Written By:  MURAOKA Taro <koron@tka.att.ne.jp>

scriptencoding cp932
let s:version = '1.3'

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
"   g:chalice_reloadinterval_threadlist	板のリロードタイム(30分間)
"   g:chalice_reloadinterval_thread	スレのリロードタイム(5分間/未使用)
if !exists('g:chalice_reloadinterval_boardlist')
  let g:chalice_reloadinterval_boardlist = 604800
endif
if !exists('g:chalice_reloadinterval_threadlist')
  let g:chalice_reloadinterval_threadlist = 1800
endif
"   g:chalice_reloadinterval_thread	スレのリロードタイム(5分間/未使用)
if !exists('g:chalice_reloadinterval_thread')
  let g:chalice_reloadinterval_thread = 300
endif

" スレ鮮度
"   スレdatの最終更新から設定された時間(2時間)が経過したかを提示する。
"   g:chalice_threadinfo		鮮度表示の有効/無効フラグ
"   g:chalice_threadinfo_expire		鮮度保持期間(1時間)
if !exists('g:chalice_threadinfo')
  let g:chalice_threadinfo = 1
endif
if !exists('g:chalice_threadinfo_expire')
  let g:chalice_threadinfo_expire = 3600
endif

" マルチユーザ設定
if !exists('g:chalice_multiuser')
  let g:chalice_multiuser = has('unix') ? 1 : 0
endif

" 外部ブラウザの指定
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

if !exists('g:chalice_menu_url')
  let g:chalice_menu_url = ''
endif

" PROXYとか書き加えると良いかも
if !exists('g:chalice_curl_options')
  let g:chalice_curl_options= ''
endif

" Cookie使う?
if !exists('g:chalice_curl_cookies')
  let g:chalice_curl_cookies = 1
endif

" gzip圧縮使用フラグ
if !exists('g:chalice_gzip')
  let g:chalice_gzip = 1
endif

" 0以上に設定するとデバッグ用にメッセージが多めに入ってる
if !exists('g:chalice_verbose')
  let g:chalice_verbose = 0
endif

" Chalice 起動時に'columns'を変えることができる(-1:無効)
if !exists('g:chalice_columns')
  let g:chalice_columns = -1
endif

if !exists('g:chalice_foldmarks')
  let g:chalice_foldmarks = ''
endif

" ステータスラインに項目を追加するための変数
if !exists('g:chalice_statusline')
  let g:chalice_statusline = ''
endif

" (非0の時)'q'によるChalice終了時に意思確認をしない
if !exists('g:chalice_noquery_quit')
  let g:chalice_noquery_quit = 1
endif

" (非0の時)カキコ実行の意思確認をしない
if !exists('g:chalice_noquery_write')
  let g:chalice_noquery_write = 0
endif

" 起動時の状態を設定する(bookmark,offline)
if !exists('g:chalice_startupflags')
  let g:chalice_startupflags = ''
endif

" redraw! による再描画を抑制する(遅い端末向け)
if !exists('g:chalice_noredraw')
  let g:chalice_noredraw = 0
endif

if !exists('g:chalice_writeoptions')
  let g:chalice_writeoptions = 'amp,nbsp'
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
let s:label_newthread = '[新スレ]'
let s:label_bookmark = '  スレの栞'
let s:label_offlinemode = 'オフラインモード'
" メッセージ
let s:msg_confirm_appendwrite_yn = 'バッファの内容が書き込み可能です. 書き込みますか?(yes/no): '
let s:msg_confirm_appendwrite_ync = '本当に書き込みますか?(yes/no/cancel): '
let s:msg_confirm_replacebookmark = 'ガイシュツURLです. 置き換えますか?(yes/no/cancel): '
let s:msg_confirm_quit = '本当にChaliceを終了しますか?(yes/no): '
let s:msg_prompt_pressenter = '続けるには Enter を押してください.'
let s:msg_warn_netline_on = 'オフラインモードを解除しました'
let s:msg_warn_netline_off = 'オフラインモードに切替えました'
let s:msg_warn_oldthreadlist = 'スレ一覧が古い可能性があります. R で更新します.'
let s:msg_warn_bookmark = '栞は閉じる時に自動的に保存されます.'
let s:msg_warn_bmkcancel = '栞への登録はキャンセルされました.'
let s:msg_wait_threadformat = '貴様ら!! スレッド整形中のため、しばらくお待ちください...'
let s:msg_wait_download = 'ダウンロード中...'
let s:msg_error_nocurl = 'Chaliceには正しくインストールされたcURLが必要です.'
let s:msg_error_nogzip = 'Chaliceには正しくインストールされたgzipが必要です.'
let s:msg_error_noconv = 'Chaliceを非CP932環境で利用するには qkc もしくは nkf が必要です.'
let s:msg_error_cantjump = 'カーソルの行にアンカーはありません. 鬱氏'
let s:msg_error_appendnothread = 'ゴルァ!! スレッドがないYO!!'
let s:msg_error_creatnoboard = '板を指定しないと糞スレすらも建ちません'
let s:msg_error_writebufhead = '書き込みバッファのヘッダが不正です.'
let s:msg_error_writebufbody = '書き込みメッセージが空です.'
let s:msg_error_writeabort = '書き込みを中止しました.'
let s:msg_error_writecancel = '書き込みをキャンセルします.'
let s:msg_error_writetitle = '新スレにはタイトルが必要です.'
let s:msg_error_addnoboardlist = '板一覧から栞へ登録出来ません.'
let s:msg_error_addnothread = 'まだスレを開いていないので登録出来ません.'
let s:msg_error_addnothreadlist = 'スレ一覧から栞へ登録出来ません.'
let s:msg_error_nocachedir = 'キャッシュディレクトリを作成出来ません.'
let s:msg_chalice_quit = 'Chalice ～～～～～～～～終了～～～～～～～～'
let s:msg_chalice_start = 'Chalice キボンヌ'
" 1行ヘルプ
let s:msg_help_boardlist = '(板一覧)  <CR>:板決定  j/k:板選択  h/l:カテゴリ閉/開  R:更新'
let s:msg_help_threadlist = '(スレ一覧)  <CR>:スレ決定 j/k:スレ選択  d:dat削除  R:更新'
let s:msg_help_thread = '(スレッド)  i:書込  I:sage書込  a:匿名書込  A:匿名sage  r:更新'
let s:msg_help_bookmark = '(スレの栞)  <CR>:URL決定  h/l:閉/開 <C-A>:閉じる  [編集可能]'
let s:msg_help_write = '(書き込み)  <C-CR>:書き込み実行  <C-W>c:閉じる  [編集可能]'

"------------------------------------------------------------------------------
" 定数値 CONSTANT
"   内部でのみ使用するもの

" デバッグフラグ (DEBUG FLAG)
let s:debug = 0

" 2ch認証のための布石
let s:user_agent = 'Monazilla/1.00 Chalice/' . s:version
let s:user_agent_enable = 1
" 2ch依存データ
let s:encoding = 'cp932'
let s:host = 'www.2ch.net'
let s:remote = '2ch.html'
" 2chのメニュー取得用初期データ
let s:menu_host = 'www6.ocn.ne.jp'
let s:menu_remotepath = '~mirv/2chmenu.html'
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
" スクリプトのディレクトリを取得
let s:scriptdir = expand('<sfile>:p:h')

" 起動フラグ
let s:opened = 0
let s:opened_write = 0
let s:dont_download = 0

" 外部コマンド実行ファイル名
let s:cmd_curl = ''
let s:cmd_conv = ''
let s:cmd_gzip = ''

" MATCH PATTERNS
let s:mx_thread_dat = '^[ !+] \(.\+\) (\(\d\+\)).*\t\+\(\d\+\%(_\d\+\)\?\.\%(dat\|cgi\)\)'

" コマンドの設定
command! Chalice			call <SID>ChaliceOpen()

" オートコマンドの設定
augroup Chalice
autocmd!
execute "autocmd BufDelete " . s:buftitle_write . " call <SID>DoWriteBuffer('closing')"
execute "autocmd BufEnter " . s:buftitle_boardlist . " call s:Redraw('force')|call s:EchoH('WarningMsg',s:msg_help_boardlist)|normal! 0"
execute "autocmd BufEnter " . s:buftitle_threadlist . " call s:Redraw('force')|call s:EchoH('WarningMsg',s:opened_bookmark?s:msg_help_bookmark : s:msg_help_threadlist)"
execute "autocmd BufEnter " . s:buftitle_thread . " call s:Redraw('force')|call s:EchoH('WarningMsg',s:msg_help_thread)"
execute "autocmd BufEnter " . s:buftitle_write . " let &undolevels=s:undolevels|call s:EchoH('WarningMsg', s:msg_help_write)"
execute "autocmd BufLeave " . s:buftitle_write . " set undolevels=0"
execute "autocmd BufDelete " . s:buftitle_threadlist . " if s:opened_bookmark|call s:CloseBookmark()|endif"
augroup END

"------------------------------------------------------------------------------
" GLOBAL FUNCTIONS
" グローバル関数

function! Chalice_foldmark(id)
  if a:id == 0
    return s:foldmark_0
  elseif a:id == 1
    return s:foldmark_1
endfunction

"------------------------------------------------------------------------------
" DEVELOPING FUNCTIONS
" 開発途上関数

"
" スレの.datを削除する
"
function! s:DeleteThreadDat()
  call s:GoBuf_ThreadList()
  " バッファがスレ一覧ではなかった場合、即終了
  if b:host == '' || b:board == ''
    return
  endif

  " カーソルの現在位置からdat名を取得
  let curline = getline('.')
  if curline =~ s:mx_thread_dat
    let dat = substitute(curline, s:mx_thread_dat, '\3', '')
    " host,board,datからローカルファイル名を生成
    let local = s:GenerateLocalDat(b:host, b:board, dat)
    " ファイルがあれば消去
    if filereadable(local)
      call delete(local)
      if g:chalice_threadinfo
	call s:FormatThreadInfo(line('.'), line('.'))
      endif
    endif
  endif
endfunction

"
" URLをChaliceで開く
"
function! s:HandleURL(url, flag)
  " 通常のURLだった場合、無条件で外部ブラウザに渡している。URLの形をみて2ch
  " ならば内部で開く。
  if a:url !~ '\(https\?\|ftp\)://[-!#%&+,./0-9:;=?@A-Za-z_~]\+' " URLPAT
    return 0
  endif
  if AL_hasflag(a:flag, '\cexternal')
    " 強制的に外部ブラウザを使用するように指定された
    call s:OpenURL(a:url)
  elseif !s:Parse2chURL(a:url)
    " URLが2chではない時
    call s:GoBuf_BoardList()
    if search(a:url) != 0
      normal! zO0z.
      execute maparg("<CR>")
    else
      call s:GoBuf_Thread()
      call s:OpenURL(a:url)
    endif
  else
    if !AL_hasflag(a:flag, '\cnoaddhist')
      call s:AddHistoryJump(s:ScreenLine(), line('.'))
    endif

    " URLが2chと判断される時
    "	s:parse2ch_host, s:parse2ch_board, s:parse2ch_datはParse2chURL()内で
    "	設定される暗黙的な戻り値。
    let curarticle = s:UpdateThread('', s:parse2ch_host, s:parse2ch_board, s:parse2ch_dat . '.dat', 'continue')

    if s:parse2ch_range_mode =~ 'r'
      if s:parse2ch_range_mode !~ 'l'
	" 非リストモード
	" 表示範囲後のfolding
	if s:parse2ch_range_end != '$'
	  let fold_start = s:GetLnum_Article(s:parse2ch_range_end + 1)  - 1
	  call AL_execute(fold_start . ',$fold')
	endif
	" 表示範囲前のfolding
	if s:parse2ch_range_start > 1
	  let fold_start = s:GetLnum_Article(s:parse2ch_range_mode =~ 'n' ? 1 : 2) - 1
	  let fold_end = s:GetLnum_Article(s:parse2ch_range_start) - 2
	  call AL_execute(fold_start . ',' . fold_end . 'fold')
	endif
	call s:GoThread_Article(s:parse2ch_range_start)
      else
	" リストモード('l')
	let fold_start = s:GetLnum_Article(s:parse2ch_range_mode =~ 'n' ? 1 : 2) - 1
	let fold_end = s:GetLnum_Article(s:GetThreadLastNumber() - s:parse2ch_range_start + (s:parse2ch_range_mode =~ 'n' ? 1 : 2)) - 2
	if fold_start < fold_end
	  call AL_execute(fold_start . ',' . fold_end . 'fold')
	endif
	if !s:GoThread_Article(curarticle)
	  normal! Gzb
	endif
      endif
    endif

    if !AL_hasflag(a:flag, '\cnoaddhist')
      call s:AddHistoryJump(s:ScreenLine(), line('.'))
    endif
  endif
  return 1
endfunction

function! s:GetThreadLastNumber()
  return getbufvar(s:buftitle_thread, 'chalice_lastnum')
endfunction

"
" URLを外部ブラウザに開かせる
"
function! s:OpenURL(url)
  let retval = AL_open_url(a:url, g:chalice_exbrowser)
  call s:Redraw('force')
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
  let mx1 = '>>\(\(\d\+\)\(-\d\+\)\?\)'
  let mx2 = '\(\(h\?ttps\?\|ftp\)://[-!#%&+,./0-9:;=?@A-Za-z_~]\+\)' " URLPAT
  let mx3 = 'www[-!#%&+,./0-9:;=?@A-Za-z_~]\+'

  " カーソル下のリンクを探し出す。なければ後方へサーチ
  let context = expand('<cword>')
  if context !~ mx1 && context !~ mx2
    let context = strpart(getline('.'), col('.') - 1)
  endif

  if context =~ mx1
    " スレの記事番号だった場合
    let num = substitute(matchstr(context, mx1), mx1, '\2', '')
    if AL_hasflag(a:flag, '\cinternal')
      let oldsc = s:ScreenLine()
      let oldcur = line('.')
      let lnum = s:GoThread_Article(num)
      if lnum > 0
	call AL_execute(lnum . "foldopen!")
	" 参照元をヒストリに入れる
	call s:AddHistoryJump(oldsc, oldcur)
	" 参照先をヒストリに入れる
	call s:AddHistoryJump(s:ScreenLine(), line('.'))
      endif
    elseif AL_hasflag(a:flag, '\cexternal')
      if b:host != '' && b:board != '' && b:dat != ''
	let num = substitute(matchstr(context, mx1), mx1, '\1', '')
	call s:OpenURL('http://' . b:host . '/test/read.cgi' . b:board . '/' . substitute(b:dat, '\.dat$', '', '') . '/' . num . 'n')
      endif
    endif
  elseif context =~ mx2
    let url = substitute(matchstr(context, mx2), '^ttp', 'http', '')
    return s:HandleURL(url, a:flag)
  elseif context =~ mx3 " http:// 無しURLの処理
    let url = 'http://' . matchstr(context, mx3)
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
  " バッファ変数のhost,board,datを引数から作成(コピーだけどね)
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

  " URLとダウンロードパスを生成
  let local = s:GenerateLocalDat(b:host, b:board, b:dat)
  let remote = b:board . '/dat/' . b:dat
  let prevsize = 0
  " スレッドの内容をダウンロード
  if !filereadable(local) || !AL_hasflag(a:flag, '\cnoforce')
    " ファイルの元のサイズを覚えておく
    if filereadable(local)
      let prevsize = getfsize(local)
    endif
    call s:HttpDownload(b:host, remote, local, a:flag)
    " (必要ならば)スレ一覧のスレ情報を更新
    if g:chalice_threadinfo
      call s:GoBuf_ThreadList()
      if b:host . b:board ==# a:host . a:board
	if a:dat != '' && search(a:dat, 'w')
	  call s:FormatThreadInfo(line('.'), line('.'))
	endif
      endif
      call s:GoBuf_Thread()
    endif
  endif

  " スレッドをバッファにロードして整形
  call AL_buffer_clear()
  call AL_execute("read " . local)
  let b:datutil_datsize = getfsize(local)
  normal! gg"_dd
  if prevsize > 0
    call AL_execute('normal! ' . prevsize . 'go')
    let newarticle = line('.') + 1
  else
    let newarticle = 1
  endif

  " 整形
  let title = s:FormatThread()
  " 常にdat内のタイトルを使用する
  let b:title = s:prefix_thread . title
  let b:title_raw = title

  if !s:GoThread_Article(newarticle)
    normal! Gzb
  endif
  call s:Redraw('force')
  call s:EchoH('WarningMsg', s:msg_help_thread)
  return newarticle
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
  let local = s:GenerateLocalSubject(b:host, b:board)
  let remote = b:board . '/subject.txt'
  let updated = 0
  if a:force || !filereadable(local) || localtime() - getftime(local) > g:chalice_reloadinterval_threadlist

    let res_gz = -1
    let reg_ng = -1
    if 0
      " 新仕様subject.txt.gzに対応。可能ならまずsubject.txt.gzをトライ。
      " しかしAcceptEncoding:gzipを指定すれば使わなくても良いことが判明
      let local_gz = local . '.gz'
      let res_gz = s:HttpDownload(b:host, remote.'.gz', local_gz, '')
      if res_gz == 200 && filereadable(local_gz)
	call s:DoExternalCommand(s:cmd_gzip . ' -d -f ' . AL_quote(local_gz))
	if !filereadable(local)
	  let reg_ng = s:HttpDownload(b:host, remote, local, '')
	endif
      else
	let reg_ng = s:HttpDownload(b:host, remote, local, '')
      endif
    else
      let reg_ng = s:HttpDownload(b:host, remote, local, '')
    endif
    " subject.txt.gzとsubject.txtの使用状況をレポート
    if s:debug
      let @a = 'http://'.b:host.b:board . '/ -> subject.txt.gz:'.res_gz.' subject.txt:'.reg_ng
    endif

    let updated = 1
  endif

  " スレ一覧をバッファにロードして整形
  call AL_buffer_clear()
  call AL_execute("read " . local)
  call AL_execute("g/^$/delete _") " 空行を削除

  " 整形
  call s:FormatBoard()

  " 先頭行へ移動
  silent! normal! gg0

  if !updated
    call s:Redraw('force')
    call s:EchoH('WarningMsg', s:msg_warn_oldthreadlist)
  endif
endfunction

"------------------------------------------------------------------------------
" 暫定的に固まった関数群 
" FIXED FUNCTIONS

function! s:Redraw(opts)
  if g:chalice_noredraw
    return
  endif
  let cmd = 'redraw'
  if AL_hasflag(a:opts, 'force')
    let cmd = cmd . '!'
  endif
  if AL_hasflag(a:opts, 'silent')
    let cmd = 'silent! ' . cmd
  endif
  execute cmd
endfunction

" スクリーンに表示されている先頭の行番号を取得する
function! s:ScreenLine()
  let wline = winline() - 1
  silent! normal! H
  let retval = line('.')
  while wline > 0
    call AL_execute('normal! gj')
    let wline = wline - 1
  endwhile
  return retval
endfunction

function! s:ScreenLineJump(scline, curline)
  " 大体の位置までジャンプ
  let curline = a:curline > 0 ? a:curline - 1 : 0
  call AL_execute('normal! ' . (a:scline + curline) . 'G')
  " 目的位置との差を計測
  let offset = a:scline - s:ScreenLine()
  if offset < 0
    call AL_execute('normal! ' . (-offset) . "\<C-Y>")
  elseif offset > 0
    call AL_execute('normal! ' . offset . "\<C-E>")
  endif
  " スクリーン内でのカーソル位置を設定する
  call AL_execute('normal! H')
  while curline > 0
    call AL_execute('normal! gj')
    let curline = curline - 1
  endwhile
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
  if !s:opened
    return
  endif
  " 書けるバッファあれば書くチャンスを用意する
  if s:opened_write
    call s:DoWriteBuffer('closing,quit')
  endif
  " 必要ならば終了の意思を確認する
  if !g:chalice_noquery_quit && !AL_hasflag(a:flag, 'all')
    echohl Question
    let last_confirm = input(s:msg_confirm_quit)
    echohl None
    if last_confirm !~ '^\cy'
      return
    endif
  endif

  silent! call s:CommandUnregister()
  " ブックマークが開かれていた場合閉じることで保存する
  if s:opened_bookmark
    call s:CloseBookmark()
  endif
  if AL_hasflag(a:flag, 'all')
    execute "qall!"
  endif
  let s:opened = 0

  " 変更したグローバルオプションの復帰
  let &charconvert = s:charconvert
  if g:chalice_columns > 0
    let &columns = s:columns
  endif
  let &equalalways = s:equalalways
  let &foldcolumn = s:foldcolumn
  let &ignorecase = s:ignorecase
  let &lazyredraw = s:lazyredraw
  let &wrapscan = s:wrapscan
  let &winwidth = s:winwidth
  let &winheight = s:winheight
  let &scrolloff = s:scrolloff
  let &statusline = s:statusline
  let &titlestring = s:titlestring
  let &undolevels = s:undolevels

  " Chalice関連のバッファ総てをwipeoutする。 TODO:バッファを番号で管理
  "call AL_execute("bwipeout " . s:buftitle_boardlist)
  "call AL_execute("bwipeout " . s:buftitle_threadlist)
  "call AL_execute("bwipeout " . s:buftitle_thread)
  call AL_execute("bwipeout " . s:buftitle_write)
  silent! new
  silent! only!
  call s:Redraw('silent')

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
  echo "s:sid=".s:sid
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

  " 'wildignore'を退避
  let wildignore = &wildignore
  set wildignore=
  
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
      let s:cmd_curl = AL_quote(s:cmd_curl)
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
  else
    call s:EchoH('ErrorMsg', s:msg_error_nogzip)
    return 0
  endif

  " 退避してあった'wildignore'を復帰
  let &wildignore = wildignore

  " ディレクトリ情報構築
  if exists('g:chalice_cachedir') && isdirectory(g:chalice_cachedir)
    let s:dir_cache = substitute(g:chalice_cachedir, '[^\/]$', '&/', '')
  else
    let s:dir_cache = g:chalice_basedir . '/cache/'
  endif
  " cookieファイル設定
  if !exists('g:chalice_cookies')
    let g:chalice_cookies = s:dir_cache . 'cookie'
  endif
  " ブックマーク情報構築
  if g:chalice_bookmark == ''
    let g:chalice_bookmark = g:chalice_basedir . '/chalice.bmk'
  endif

  " キャッシュディレクトリの保証
  if !isdirectory(s:dir_cache)
    call AL_mkdir(s:dir_cache)
    if !isdirectory(s:dir_cache)
      call s:Redraw('force')
      call s:EchoH('ErrorMsg', s:msg_error_nocachedir)
      return 0
    endif
  endif

  return 1
endfunction

"
" Chaliceヘルプをインストール
"
function! s:HelpInstall(scriptdir)
  let basedir = substitute(a:scriptdir, 'plugin$', 'doc', '')
  if has('unix')
    let docdir = $HOME . '/.vim/doc'
    if !isdirectory(docdir)
      call system('mkdir -p ' . docdir)
    endif
  else
    let docdir = basedir
  endif
  let helporig = basedir . '/chalice.txt.cp932'
  let helpfile = docdir . '/chalice.txt'
  let tagsfile = docdir . '/tags'

  " この関数はpluginの読み込み時に実行されるのでAL_*が使えない

  " 文字コードのコンバート
  if !filereadable(helpfile) || (filereadable(helporig) && getftime(helporig) > getftime(helpfile))
    silent execute "sview " . helporig
    set fileencoding=japan fileformat=unix
    silent execute "write! " . helpfile
    bwipeout!
  endif

  " tagsの更新
  if !filereadable(tagsfile) || getftime(helpfile) > getftime(tagsfile)
    silent execute "helptags " . docdir
  endif
endfunction
silent! call s:HelpInstall(s:scriptdir)

"
" Chalice開始
"
function! s:ChaliceOpen()
  if s:opened
    return
  endif

  " 動作環境のチェック
  if !s:CheckEnvironment()
    return
  endif

  " (必要ならば)ヘルプファイルをインストールする
  silent! call s:HelpInstall(s:scriptdir)

  " 変更するグローバルオプションの保存
  let s:opened = 1
  let s:charconvert = &charconvert
  let s:columns = &columns
  let s:equalalways = &equalalways
  let s:foldcolumn = &foldcolumn
  let s:ignorecase = &ignorecase
  let s:lazyredraw = &lazyredraw
  let s:wrapscan = &wrapscan
  let s:winwidth = &winwidth
  let s:winheight = &winheight
  let s:scrolloff = &scrolloff
  let s:statusline = &statusline
  let s:titlestring = &titlestring
  let s:undolevels = &undolevels

  " グローバルオプションを変更
  if s:cmd_conv != ''
    let &charconvert = s:sid . 'CharConvert()'
  endif
  if g:chalice_columns > 0
    let &columns = g:chalice_columns
  endif
  set noequalalways
  set foldcolumn=0
  set ignorecase
  set lazyredraw
  set wrapscan
  set winheight=8
  set winwidth=15
  set scrolloff=0
  let &statusline = '%<%{' . s:sid . 'GetBufferTitle()}%='.g:chalice_statusline.'%l/%L'
  " let &titlestring = s:label_vimtitle " UpdateTitleString()参照
  set undolevels=0

  " foldmarksの初期化
  let mx = '^\(.\)\(.\)$'
  let foldmarks = '■□'
  if exists('g:chalice_foldmarks') && g:chalice_foldmarks =~ mx
    let foldmarks = g:chalice_foldmarks
  endif
  let s:foldmark_0 = substitute(foldmarks, mx, '\1', '')
  let s:foldmark_1 = substitute(foldmarks, mx, '\2', '')

  " 起動最終準備
  call s:CommandRegister()
  call s:OpenAllChaliceBuffers()
  " オフラインモード用フラグ
  let s:dont_download = AL_hasflag(g:chalice_startupflags, 'offline') ? 1 : 0
  call s:UpdateBoardList(0)
  if AL_hasflag(g:chalice_startupflags, 'bookmark')
    silent! call s:OpenBookmark()
  endif
  call s:UpdateTitleString()

  " 開始メッセージ表示
  call s:Redraw('silent')
  call s:EchoH('WarningMsg', s:msg_chalice_start)
endfunction

" タイトル文字列を設定する。現在のChaliceの状態に応じた文字列になる。
function! s:UpdateTitleString()
  let str = s:label_vimtitle
  if s:dont_download
    let str = str . ' ' . s:label_offlinemode
  endif
  let &titlestring = str
endfunction

function! s:ToggleNetlineState()
  let s:dont_download = s:dont_download ? 0 : 1
  " オフラインモード表示
  call s:UpdateTitleString()
  call s:EchoH('WarningMsg', s:dont_download ? s:msg_warn_netline_off : s:msg_warn_netline_on)
endfunction

"
" 外部コマンドを実行
"   verboseレベルに応じた方法で実行する。
"
function! s:DoExternalCommand(cmd)
  let extcmd = a:cmd
  if has('win32') && &shell =~ '\ccmd'
    let extcmd = '"' . extcmd . '"'
  endif
  if g:chalice_verbose < 1
    return system(extcmd)
  elseif g:chalice_verbose < 2
    call AL_execute(':!' . extcmd)
  else
    execute ':!' . extcmd
  endif
endfunction

"
" 現在のカーソル行のスレッドを開く
"
function! s:OpenThread(...)
  let flag = (a:0 > 0) ? a:1 : 'internal'
  if AL_hasflag(flag, 'firstline')
    " 外部ブラウザにはfirstlineだとかそうじゃないという概念がないから、
    " firstline指定時は暗にinternalとして扱って良い。
    let flag = flag . ',internal'
  endif

  let curline = getline('.')
  let mx2 = '\(http://[-!#%&+,./0-9:;=?@A-Za-z_~]\+\)' " URLPAT

  if curline =~ s:mx_thread_dat
    let host = b:host
    let board = b:board
    let title = substitute(curline, s:mx_thread_dat, '\1', '')
    let dat = substitute(curline, s:mx_thread_dat, '\3', '')
    let url = 'http://' . host . '/test/read.cgi' . board . '/'. substitute(dat, '\.dat$', '', '')
    if !AL_hasflag(flag, 'internal')
      let url = url . '/l50'
    endif
  elseif curline =~ mx2
    let url = matchstr(curline, mx2)
  else
    " foldの開閉をトグル
    silent! normal! 0za
    return
  endif

  " URLは抽出できたが[板]がある場合
  if AL_hasflag(flag, 'bookmark') && curline =~ '^\s*\[板\]'
    return s:OpenBoard()
  endif

  call s:HandleURL(url, flag . ',noaddhist')
  if AL_hasflag(flag, 'firstline')
    normal! gg
  endif
  call s:AddHistoryJump(s:ScreenLine(), line('.'))
endfunction

"
" 現在のカーソル行にあるURLを板として開く
"
function! s:OpenBoard(...)
  let board = AL_chomp(getline('.'))
  let mx = '^\(.\{-\}\)\s\+http://\(..\{-\}\)\(/[^/]\+\)/$'
  if board !~ mx
    " foldの開閉をトグル
    normal! 0za
    return
  endif

  let title = substitute(substitute(board, mx, '\1', ''), '^\s*\([板]\)\?\s*', '', '')
  let host  = substitute(board, mx, '\2', '')
  let board = substitute(substitute(board, mx, '\3', ''), '/$', '', '')
  " デバッグメッセージ作成
  let mes = ''
  let mes = mes . "title=" . title . " host=" . host . " board=" . board

  if a:0 > 0 && AL_hasflag(a:1, 'external')
    return s:OpenURL('http://' . host . board . '/')
  endif
  call s:UpdateBoard(title, host, board, 0)
endfunction

"
" 与えられたURLを2chかどうか判断しる!!
"
function! s:Parse2chURL(url)
  let mx = '^http://\(..\{-\}\)/test/read.cgi\(/[^/]\+\)/\(\d\+\%(_\d\+\)\?\)\(.*\)'
  if a:url !~ mx
    return 0
  endif
  let s:parse2ch_host = substitute(a:url, mx, '\1', '')
  let s:parse2ch_board = substitute(a:url, mx, '\2', '')
  let s:parse2ch_dat = substitute(a:url, mx, '\3', '')

  " 表示範囲を解釈
  " 参考資料: http://pc.2ch.net/test/read.cgi/tech/1002820903/
  let range = substitute(a:url, mx, '\4', '')
  let mx_range = '[-0-9]\+'
  let s:parse2ch_range_mode = ''
  let s:parse2ch_range_start = ''
  let s:parse2ch_range_end = ''
  let str_range = matchstr(range, mx_range)
  if str_range != ''
    " 範囲表記を走査
    let mx_range2 = '\(\d*\)-\(\d*\)'
    if str_range =~ mx_range2
      let s:parse2ch_range_start = substitute(str_range, mx_range2, '\1', '')
      let s:parse2ch_range_end	 = substitute(str_range, mx_range2, '\2', '')
      if s:parse2ch_range_start == ''
	let s:parse2ch_range_start = 1
      endif
      if s:parse2ch_range_end == ''
	let s:parse2ch_range_end = '$'
      endif
    else
      " 数字しかあり得ないので可
      let s:parse2ch_range_start = str_range
      let s:parse2ch_range_end = str_range
    endif
    let s:parse2ch_range_mode = s:parse2ch_range_mode . 'r'
    " 表示フラグ(n/l)の判定
    if range =~ 'n'
      let s:parse2ch_range_mode = s:parse2ch_range_mode . 'n'
    endif
    if range =~ 'l'
      let s:parse2ch_range_mode = s:parse2ch_range_mode . 'l'
    endif
  endif

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
  call AL_execute("edit! " . s:buftitle_thread)
  setlocal filetype=2ch_thread
  let b:title = s:prefix_thread

  " 板一覧用バッファを開く
  call AL_execute("topleft 15vnew! " . s:buftitle_boardlist)
  setlocal filetype=2ch_boardlist
  let b:title = s:label_boardlist

  " スレッド一覧用バッファ(==板)を開く
  call s:GoBuf_Thread()
  call AL_execute("leftabove 10new! " . s:buftitle_threadlist)
  setlocal filetype=2ch_threadlist
  let b:title = s:prefix_board
endfunction

"
" HTTPダウンロードの関数:
"   将来はwgetに依存しないようにしたい。
"
function! s:HttpDownload(host, remotepath, localpath, flag)
  " オフラインのチェック
  if s:dont_download
    return
  endif
  call s:Redraw('force')
  call s:EchoH('WarningMsg', s:msg_wait_download)

  let local = a:localpath
  let url = 'http://' . a:host . '/' . substitute(a:remotepath, '^/', '', '')
  let continued = 0
  let compressed = 0

  " 起動オプションの構築→cURLの実行
  let opts = g:chalice_curl_options

  " 生dat読み込み制限に対応
  if s:user_agent_enable
    let opts = opts . ' -A ' . AL_quote(s:user_agent)
  endif

  " 継続ロードのオプション設定
  if AL_hasflag(a:flag, 'continue')
    let size = getfsize(local)
    if size > 0
      let continued = 1
      let opts = opts . ' -C ' . size
    endif
  endif

  " 圧縮ロードのオプション設定
  if !continued && g:chalice_gzip && s:cmd_gzip != '' && a:remotepath !~ '\.gz$'
    let compressed = 1
    let local = local . '.gz'
    let opts = opts . ' -H Accept-Encoding:gzip,deflate'
  endif

  " ヘッダー情報を取得するためテンポラリファイルを使用
  let tmp_head = tempname()
  let opts = opts . ' -D ' . AL_quote(tmp_head)

  " ダウンロードコマンド構成→ダウンロード実行
  let opts = opts . ' -o ' . AL_quote(local) . ' ' . AL_quote(url)
  call s:DoExternalCommand(s:cmd_curl . ' ' . opts)

  " ヘッダー情報取得→テンポラリファイル削除
  call AL_execute('split ' . tmp_head)
  "  このsplit、直前に'noequalalways'しても反映されない。仕方ないのでスクリ
  "  プト全体に'noequalalways'するようにした。
  let retval = substitute(getline(1), '^HTTP\S*\s\+\(\d\+\).*$', '\1', '') + 0
  bwipeout
  call delete(tmp_head)

  if compressed
    " 解凍中～
    call s:DoExternalCommand(s:cmd_gzip . ' -d -f ' . AL_quote(local))
    if filereadable(local)
      call rename(local, substitute(local, '\.gz$', '', ''))
    endif
  endif

  call s:Redraw('force')
  return retval
endfunction

"
" 板一覧のバッファを更新
"
function! s:UpdateBoardList(force)
  call s:GoBuf_BoardList()
  let b:title = s:label_boardlist

  let local_menu = s:dir_cache . s:menu_localpath
  " 板一覧の読み込み
  if a:force || !filereadable(local_menu) || localtime() - getftime(local_menu) > g:chalice_reloadinterval_boardlist
    let mx = '^http://\([^/]\+\)/\(.*\)$'
    if exists('g:chalice_menu_url') && g:chalice_menu_url =~ mx
      " 外部からメニューのURLを与える
      let menu_host = substitute(g:chalice_menu_url, mx, '\1', '')
      let menu_remotepath = substitute(g:chalice_menu_url, mx, '\2', '')
    else
      " 2chのフレームを読み込んでframedataに格納
      let local_frame = tempname()
      call s:HttpDownload(s:host, s:remote, local_frame, '')
      call AL_execute('%delete _')
      call AL_execute('read ' . local_frame)
      call AL_execute("%join")
      let framedata = getline('.')
      call AL_execute('%delete _')
      call delete(local_frame)

      " frameタグの解釈
      let framedata = substitute(framedata, '^.*\(frame\>[^>]*name="\?menu"\?[^>]*\)>.*$', '\1', '')
      let mx = '^.*src="\?http://\([^/]\+\)/\([^" ]*\)"\?.*$'
      let menu_host = substitute(framedata, mx, '\1', '')
      let menu_remotepath = substitute(framedata, mx, '\2', '')
    endif

    " 最低限の保証
    if menu_host == ''
      let menu_host = s:menu_host
      let menu_remotepath = s:menu_remotepath
    endif

    " メニューファイルの読込
    call s:HttpDownload(menu_host, menu_remotepath, local_menu, '')
  endif

  " 板一覧の整形
  call AL_buffer_clear()
  call AL_execute('read ' . local_menu)
  " 改行<BR>を本当の改行に
  call AL_execute("%s/\\c<br>/\r/g")
  " カテゴリと板へのリンク以外を消去
  call AL_execute('%g!/^\c<[AB]\>/delete _')
  " カテゴリを整形
  call AL_execute('%s/^<B>\([^<]*\)<\/B>/' . Chalice_foldmark(0) . '\1/')
  " 板名を整形
  call AL_execute('%s/^<A HREF=\([^ ]*\/\)[^/>]*>\([^<]*\)<\/A>/ \2\t\t\t\t\1')
  " 「2ch総合案内」を削除…本当はちゃんとチェックしなきゃダメだけど。
  call AL_execute("1,/^" . Chalice_foldmark(0) . "/-1delete _")
  "normal! gg"_dd0

  " テスト鯖へのリンクを板一覧に埋め込む
  if 1 || s:debug
    " これはしばらく強制的に埋め込む…
    call append(0, Chalice_foldmark(0) . "テスト鯖")
    call append(1, " ばたー\t\t\t\thttp://tora3.2ch.net/butter/")
  endif

  " folding作成
  silent! normal! gg
  while 1
    call AL_execute('.,/\n\(' . Chalice_foldmark(0) . '\)\@=\|\%$/fold')
    let prev = line('.')
    silent! normal! j
    if prev == line('.')
      break
    endif
  endwhile
  silent normal! gg

  call AL_del_lastsearch()
endfunction

"
" Chalice起動確認
"
function! ChaliceIsRunning()
  return s:opened
endfunction

"------------------------------------------------------------------------------
" MOVE AROUND BUFFER
" バッファ移動用関数

function! s:GetLnum_Article(num)
  " 指定した番号の記事の先頭行番号を取得。カーソルは移動しない。
  call s:GoBuf_Thread()
  let oldline = line('.')
  if a:num =~ '\cnext'
    let lnum = search('^\d\+  ', 'W')
  elseif a:num =~ '\cprev'
    " 'nostartofline'対策
    normal! k
    let lnum = search('^\d\+  ', 'bW')
    " 1を超えた時はヘッダ部分を表示
    if lnum == 0
      let lnum = 1
    endif
  elseif a:num =~ '\ccurrent'
    call AL_execute("normal! j")
    let lnum = search('^\d\+  ', 'bW')
  else
    let lnum = search('^' . a:num . '  ', 'bw')
  endif
  call AL_execute("normal! " . oldline . "G")
  return lnum
endfunction

function! s:GoThread_Article(num)
  let lnum = s:GetLnum_Article(a:num)
  if lnum
    call AL_execute("normal! ".lnum."Gzt\<C-Y>")
  endif
  return lnum
endfunction

function! s:GoBuf_Write()
  let retval = s:SelectWindowByName(s:buftitle_write)
  if retval < 0
    call AL_execute("rightbelow split " . s:buftitle_write)
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
function! s:AddHistoryJump(scline, curline)
  call s:GoBuf_Thread()
  let packed = b:host . ' ' . b:board . ' ' . b:dat . ' ' . a:scline
  if strpart(s:JumplistCurrent(), 0, strlen(packed)) !=# packed
    call s:JumplistAdd(packed . ' ' . a:curline . ' ' . b:title_raw)
  endif
endfunction

"
" 履歴をジャンプ
function! s:DoHistoryJump(flag)
  let data = 0
  if AL_hasflag(a:flag, '\cnext')
    let data = s:JumplistNext()
  elseif AL_hasflag(a:flag, '\cprev')
    let data = s:JumplistPrev()
  endif

  let mx = '^\(\S\+\) \(\S\+\) \(\S\+\) \(\S\+\) \(\S\+\).*$'
  if data =~ mx
    " 履歴データを解釈
    let host = substitute(data, mx, '\1', '')
    let board = substitute(data, mx, '\2', '')
    let dat = substitute(data, mx, '\3', '')
    let scline = substitute(data, mx, '\4', '')
    let curline = substitute(data, mx, '\5', '')
    " 履歴にあわせてバッファを移動
    call s:GoBuf_Thread()
    if host != b:host || board != b:board || dat != b:dat
      call s:UpdateThread('', host, board, dat, 'continue,noforce')
    endif
    " スクリーン表示開始行を設定→実行
    call s:ScreenLineJump(scline, 0)
    call AL_execute('normal! ' . curline . 'G')
  endif
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
  call AL_buffer_clear()
  setlocal filetype=2ch_bookmark
  call AL_execute("read " . g:chalice_bookmark)
  silent! normal! gg"_dd0
  call s:Redraw('force')
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
  call AL_execute("%write! " . g:chalice_bookmark)
  call AL_buffer_clear()

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
      call AL_execute(':' . existedbookmark . 'delete _')
    elseif last_confirm !~ '^\cn'
      " 登録をキャンセル
      let url = ''
    endif
  endif

  " URLをバッファに書込む
  if url != ''
    call append(0, a:title . "\t\t\t\t" . url)
  endif

  execute "normal! " . winnum . "\<C-W>\<C-W>"
  if url == ''
    call s:Redraw('force')
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
  if AL_hasflag(a:flag, 'thread')
    call s:GoBuf_Thread()
  elseif AL_hasflag(a:flag, 'threadlist')
    call s:GoBuf_ThreadList()
  endif
endfunction

function! s:Thread2Bookmark(target)
  let title = ''
  let url = ''
  if AL_hasflag(a:target, 'thread')
    " スレッドから栞に登録
    call s:GoBuf_Thread()
    if b:host == '' || b:board == '' || b:dat == ''
      call s:Redraw('force')
      call s:EchoH('ErrorMsg', s:msg_error_addnothread)
      return
    endif
    let dat = substitute(b:dat, '\.dat$', '', '')
    if b:title_raw == ''
      let title = b:host . b:board . '/' . dat
    else
      let title = b:title_raw
    endif
    let url = 'http://' . b:host . '/test/read.cgi' . b:board . '/' . dat
  elseif AL_hasflag(a:target, 'threadlist')
    " スレ一覧から栞に登録
    call s:GoBuf_ThreadList()
    let curline = getline('.')
    let mx = '^. \(.\+\) (\d\+) \%(\d\d\d\d\/\d\d\/\d\d \d\d:\d\d:\d\d\)\?\s*\(\d\+\)\.dat$'
    if b:host == '' || b:board == '' || curline !~ mx
      call s:Redraw('force')
      call s:EchoH('ErrorMsg', s:msg_error_addnothreadlist)
      return
    endif
    let title = substitute(curline, mx, '\1', '')
    let dat = substitute(curline, mx, '\2', '')
    let url = 'http://' . b:host . '/test/read.cgi' . b:board . '/' . dat
  elseif AL_hasflag(a:target, 'boardlist')
    " 板一覧から栞に登録
    call s:GoBuf_BoardList()
    let curline = getline('.')
    let mx = '^ \(.\+\)\s\+\(http:.\+\)$'
    if curline !~ mx
      call s:Redraw('force')
      call s:EchoH('ErrorMsg', s:msg_error_addnoboardlist)
      return
    endif
    " [板]を付けることでスレッドの区別(スレ名が[板]で始まったら泣く?)
    let title = '[板] ' . substitute(curline, mx, '\1', '')
    let url = substitute(curline, mx, '\2', '')
  endif
  " OUT: titleとurl

  call s:Redraw('force')
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

"
" 書き込み用バッファを開く
"
function! s:OpenWriteBuffer(...)
  " フラグに応じて匿名、sageを自動設定
  let newthread = 0
  let quoted = ''
  let username = g:chalice_username
  let usermail = g:chalice_usermail
  if a:0 > 0
    if AL_hasflag(a:1, 'anony')
      let username = g:chalice_anonyname
      let usermail = ''
    endif
    if AL_hasflag(a:1, 'sage')
      let usermail = 'sage'
    endif
    if AL_hasflag(a:1, 'new')
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
    " 現在カーソルがある記事の引用
    if a:0 > 0 && AL_hasflag(a:1, 'quote')
      " 引用開始位置を検索
      let quote_start = s:GetLnum_Article('current') - 1
      let first_article = s:GetLnum_Article(1) - 1
      if quote_start < first_article
	let quote_start = first_article
	let quote_end = s:GetLnum_Article(2) - 3
      else
	" 引用終了位置を検索
	let quote_end = s:GetLnum_Article('next') - 3
      endif
      " 範囲指定がひっくり返っている時、もしくは不正な時
      if quote_end < 1 || quote_end < quote_start
	let quote_end = line("$")
      endif
      " 文章を引用した文字列を作成(->quotedに格納)
      let quoted = '>>' . matchstr(getline(quote_start + 1), '^\(\d\+\)') . "\<CR>"
      let i = quote_start + 2
      while i <= quote_end
	let quoted = quoted . substitute(getline(i), '^.', '>', '') . "\<CR>"
	let i = i + 1
      endwhile
    endif
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
  call AL_buffer_clear()

  call s:Redraw('')
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
    let def = def . quoted
    execute "normal! i" . def . "\<ESC>"
  endif
  let s:opened_write = 1
  call s:Redraw('force')
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
  if AL_hasflag(a:flag, '\cclosing')
    let s:opened_write = 0
  elseif write_result != 0
    let s:opened_write = 0
    call s:GoBuf_Write()
    execute ":close"
  endif

  if !s:opened_write
    if !newthread
      "call s:GoBuf_Thread()
      "normal! zb
    else
      " 新スレ作成時(現在は使われない)
      call s:GoBuf_ThreadList()
    endif
  endif
  return 1
endfunction

function! s:DoWriteBufferStub(flag)
  let force_close = AL_hasflag(a:flag, '\cclosing')
  call s:GoBuf_Write()
  call s:Redraw('force')

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
  let title = AL_chompex(substitute(title,  '^Title:', '', ''))
  let name =  AL_chompex(substitute(name,   '^From:',  '', ''))
  let mail =  AL_chompex(substitute(mail,   '^Mail:',  '', ''))

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
  " &記号を&amp;に置換
  if AL_hasflag(g:chalice_writeoptions, 'amp')
    let message = substitute(message, '&', '\&amp;', 'g')
  endif
  " 半角スペース2個を全角スペース2個に展開
  if AL_hasflag(g:chalice_writeoptions, 'zenkaku')
    let message = substitute(message, '  ', '　', 'g')
  endif
  " 半角スペースを&nbsp;に置換
  if AL_hasflag(g:chalice_writeoptions, 'nbsp')
    let message = substitute(message, ' ', '\&nbsp;', 'g')
  endif

  if 0
    echo "RAW MESSAGE=".message
    echo "MESSAGE=" . AL_urlencode(message)
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
    let chunk = chunk . 'subject=' . AL_urlencode(title)
    let chunk = chunk . '&submit=' . s:urlencoded_newwrite
  endif
  let chunk = chunk . '&FROM=' . AL_urlencode(name)
  let chunk = chunk . '&mail=' . AL_urlencode(mail)
  let chunk = chunk . '&MESSAGE=' . AL_urlencode(message)
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
  " chalice_noquery_writeが設定されている時には有無を言わさず書込む。Chalice
  " 終了に伴う強制書込みでは同オプションに関わらず確認をする。
  if AL_hasflag(a:flag, 'quit') || !exists('g:chalice_noquery_write') || !g:chalice_noquery_write
    if force_close
      " 通常の確認
      let last_confirm = input(s:msg_confirm_appendwrite_yn)
      echohl None
      if last_confirm !~ '^\cy'
	call s:Redraw('force')
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
	call s:Redraw('force')
	call s:EchoH('ErrorMsg', s:msg_error_writeabort)
	return -1
      elseif last_confirm !~ '^\cy'
	call s:Redraw('force')
	call s:EchoH('WarningMsg', s:msg_error_writecancel)
	return 0
      endif
    endif
  endif

  let tmpfile = tempname()
  redraw!
  execute "redir! > " . tmpfile 
  silent echo chunk
  redir END
  " 書き込みコマンドの発行
  "   必要なデータ変数: tmpflie, b:host, b:bbs
  call s:Redraw('force')
  " 起動オプションの構築→cURLの実行
  let opts = g:chalice_curl_options
  if s:user_agent_enable
    let opts = opts . ' -A ' . AL_quote(s:user_agent)
  endif
  let opts = opts . ' -b NAME= -b MAIL='
  if g:chalice_curl_cookies != 0 && exists('g:chalice_cookies')
    let opts = opts . ' -c ' . AL_quote(g:chalice_cookies)
    let opts = opts . ' -b ' . AL_quote(g:chalice_cookies)
  endif
  let opts = opts . ' -d @' . AL_quote(tmpfile)
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
" FILENAMES
" ファイル名の生成

function! s:GenerateLocalDat(host, board, dat)
  return s:dir_cache . 'dat_' . substitute(a:host . a:board, '/', '_', 'g') . '_' . substitute(a:dat, '\.dat$', '', '')
endfunction

function! s:GenerateLocalSubject(host, board)
  return s:dir_cache . 'subject_' . substitute(a:host . a:board, '/', '_', 'g')
endfunction

"------------------------------------------------------------------------------
" FORMATTING
" 各ペインの整形

"
" endlineに0を指定するとバッファの最後。
"
function! s:FormatThreadInfo(startline, endline)
  call s:GoBuf_ThreadList()
  " バッファがスレ一覧ではなかった場合、即終了
  if s:opened_bookmark || b:host == '' || b:board == ''
    return
  endif

  let i = a:startline
  let lastline = a:endline ? a:endline : line('$')

  " 各スレのdatファイルが存在するかチェックし、存在する場合には最終取得時刻
  " をチェックし、それによって強調の仕方を変える。
  " 1. datが存在し過去chalice_threadinfo_expire内に更新 →!を行頭へ
  " 2. datが存在し過去chalice_threadinfo_expire外に更新 →+を行頭へ
  while i <= lastline
    let curline = getline(i)
    if curline =~ s:mx_thread_dat
      let dat = substitute(curline, s:mx_thread_dat, '\3', '')
      let local = s:GenerateLocalDat(b:host, b:board, dat)
      " ファイルが存在するならばファイル情報を取得
      if filereadable(local)
	let lasttime = getftime(local)
	let indicator = localtime() - lasttime > g:chalice_threadinfo_expire ? '+' : '!'
	let time = strftime("%Y/%m/%d %H:%M:%S", lasttime)
      else
	let indicator = ' '
	let time = ''
      endif
      " タイトルと書き込み数を取得
      let title = substitute(curline, s:mx_thread_dat, '\1', '')
      let point = substitute(curline, s:mx_thread_dat, '\2', '')
      " ラインの内容が変化していたら設定
      let newline = indicator . ' ' . title . ' (' . point . ') ' . time . "\t\t\t\t" . dat
      if curline !=# newline
	call setline(i, newline)
      endif
    endif
    let i = i + 1
  endwhile
endfunction

function! s:FormatBoard()
  " subject.txtの整形。各タイプ毎の置換パターンを用意
  " ちょっと免疫アルゴリズム的(笑)
  let mx_shitaraba  = '^\(\d\+_\d\+\)<>\(.\{-\}\)<>\(\d\+\)<><>NULL<>$'
  let mx_mikage	    = '^\(\d\+\.\%(dat\|cgi\)\),\(.*\)(\(\d\+\))$'
  let mx_2ch	    = '^\(\d\+\.dat\)<>\(.*\) (\(\d\+\))$'
  let out_pattern   = '  \2 (\3)\t\t\t\t\1'

  " どのタイプかを判定。デフォルトは2ch形式
  let firstline = getline(1)
  let mx = mx_2ch
  let b:format = '2ch'
  if firstline =~ mx_shitaraba
    " したらばの場合
    let mx = mx_shitaraba
    let out_pattern = out_pattern . '.dat'
    let b:format = 'shitaraba'
  elseif firstline =~ mx_mikage
    " mikageの場合
    let mx = mx_mikage
    let b:format = 'mikage'
  endif

  " 整形を実行
  call AL_execute('%s/' .mx. '/' .out_pattern)
  " 特殊文字潰し
  call AL_decode_entityreference('%')
  call AL_del_lastsearch()

  if g:chalice_threadinfo
    call s:FormatThreadInfo(1, 0)
  endif
endfunction

function! s:FormatThread()
  " 待ってね☆メッセージ
  call s:EchoH('WarningMsg', s:msg_wait_threadformat)
  " 最終記事番号を取得
  let b:chalice_lastnum = line('$')
  return Dat2Text(g:chalice_verbose > 0 ? 'verbose' : '')
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
  command! -nargs=1 ChaliceGoArticle	call <SID>GoThread_Article(<q-args>)
  command! -nargs=1 Article		call <SID>GoThread_Article(<q-args>)
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
  command! ChaliceDeleteThreadDat	call <SID>DeleteThreadDat()
  command! ChaliceToggleNetlineStatus	call <SID>ToggleNetlineState()
endfunction

function! s:CommandUnregister()
  delcommand ChaliceQuit
  delcommand ChaliceQuitAll
  delcommand ChaliceGoBoardList
  delcommand ChaliceGoThreadList
  delcommand ChaliceGoThread
  delcommand ChaliceGoArticle
  delcommand Article
  delcommand ChaliceOpenBoard
  delcommand ChaliceOpenThread
  delcommand ChaliceHandleJump
  delcommand ChaliceHandleJumpExt
  delcommand ChaliceReloadBoardList
  delcommand ChaliceReloadThreadList
  delcommand ChaliceReloadThread
  delcommand ChaliceReloadThreadInc
  delcommand ChaliceDoWrite
  delcommand ChaliceWrite
  delcommand ChaliceHandleURL
  delcommand ChaliceBookmarkToggle
  delcommand ChaliceBookmarkAdd
  delcommand ChaliceJumplist
  delcommand ChaliceJumplistNext
  delcommand ChaliceJumplistPrev
  delcommand ChaliceDeleteThreadDat
  delcommand ChaliceToggleNetlineStatus
endfunction
