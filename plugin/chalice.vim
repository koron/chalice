" vim:set ts=8 sts=2 sw=2 tw=0:
"
" chalice.vim - 2ch viewer 'Chalice' /
"
" Last Change: 06-Aug-2002.
" Written By:  MURAOKA Taro <koron@tka.att.ne.jp>

scriptencoding cp932
let s:version = '1.6'

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

" ブックマークのバックアップ作成間隔 (2日, 1時間未満なら無効化)
if !exists('g:chalice_bookmark_backupinterval')
  let g:chalice_bookmark_backupinterval = 172800
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

" 起動時の状態を設定する(bookmark,offline,nohelp,noanime)
if !exists('g:chalice_startupflags')
  let g:chalice_startupflags = ''
endif

" (非0の時)オートプレビュー機能を使用する
if !exists('g:chalice_preview')
  let g:chalice_preview = 1
endif

" 動作時の各種設定(1,above, autoclose)
if !exists('g:chalice_previewflags')
  let g:chalice_previewflags = ''
endif

" redraw! による再描画を抑制する(遅い端末向け)
if !exists('g:chalice_noredraw')
  let g:chalice_noredraw = 0
endif

" 書込み時に実体参照へ変更する文字を指定(amp,nbsp)
if !exists('g:chalice_writeoptions')
  let g:chalice_writeoptions = 'amp,nbsp'
endif

" スレ一覧表示時に更新チェックをするかどうかを指定(0: チェックしない)
if !exists('g:chalice_autonumcheck')
  let g:chalice_autonumcheck = 0
endif

" アニメーション時のウェイト。最適な値はCPUや表示装置に依存
if !exists('g:chalice_animewait')
  let g:chalice_animewait = 200
endif

"------------------------------------------------------------------------------
" 定数値
"   将来はグローバルオプション化できそうなの。もしくはユーザが書き換えても良
"   さそうなの。

let s:prefix_board = '  スレ一覧 '
let s:prefix_thread = '  スレッド '
let s:prefix_write = '  書込スレ '
let s:prefix_preview = '  プレビュー '
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
let s:msg_prompt_articlenumber = '何番、逝ってよし? '
let s:msg_prompt_pressenter = '続けるには Enter を押してください.'
let s:msg_warn_preview_on = 'プレビュー機能を有効化しました'
let s:msg_warn_preview_off = 'プレビュー機能を解除しました'
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
let s:msg_error_cantjump = 'カーソルの行にアンカーはありません. 髭氏'
let s:msg_error_cantpreview = 'アンカーが無効です. 鬱氏'
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
let s:msg_error_nothread = 'スレッドが存在しないか, 倉庫入り(HTML化)待ちです.'
let s:msg_error_accesshere = '下記URLに外部ブラウザでアクセスしてみてください.'
let s:msg_error_newversion = 'Chaliceの新しいバージョン・パッチがリリースされています.'
let s:msg_error_htmlnotopen = 'スレッドが開かれていません.'
let s:msg_error_htmlnodat = 'スレッドのdatがありません.'
let s:msg_thread_hasnewarticles = '新しい書き込みがあります.'
let s:msg_thread_nonewarticle = '新たな書き込みはありません'
let s:msg_thread_dead = '倉庫に落ちたかHTML化待ちとオモワレ.'
let s:msg_thread_lost = '倉庫に落ちました.'
let s:msg_thread_unknown = '初めて見るスレです. 更新チェックはできません.'
let s:msg_chalice_quit = 'Chalice ～～～～～～～～終了～～～～～～～～'
let s:msg_chalice_start = 'Chalice キノーン'
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
let s:buftitle_preview	  = 'Chalice_2ちゃんねる_プレビュー'
" ブックマーク自動バックアップ間隔の下限
let s:minimum_backupinterval = 3600
let s:bookmark_filename = 'chalice.bmk'
let s:bookmark_backupname = 'bookmark.bmk'
let s:bookmark_backupsuffix = '.chalice_backup'
" バージョンチェック
let s:verchk_verurl = 'http://www.kaoriya.net/update/chalice-version'
let s:verchk_path = g:chalice_basedir.'/VERSION'
let s:verchk_interval = 86400
let s:verchk_url_1 = 'http://www.kaoriya.net/testdir/patches-chalice/?C=M&O=D'
let s:verchk_url_2 = 'http://www.kaoriya.net/#CHALICE'

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
let s:mx_thread_dat = '^[ !\*+x] \(.\+\) (\(\%(\%(\d\+\|???\)/\)\?\d\+\)).*\t\+\(\d\+\%(_\d\+\)\?\.\%(dat\|cgi\)\)'
let s:mx_anchor_num = '>>\(\(\d\+\)\%(-\(\d\+\)\)\?\)'
let s:mx_anchor_url = '\(\(h\?ttps\?\|ftp\)://'.g:AL_pattern_class_url.'\+\)'
let s:mx_anchor_www = 'www'.g:AL_pattern_class_url.'\+'
let s:mx_url_2channel = 'http://\(..\{-\}\)/test/read.cgi\(/[^/]\+\)/\(\d\+\%(_\d\+\)\?\)\(.*\)'
let s:mx_servers_oldkako = '^\(piza\.\|www\.bbspink\|mentai\.2ch\.net/mukashi\|www\.2ch\.net/\%(tako\|kitanet\)\)'
let s:mx_servers_jbbstype = '\%(^jbbs\.shitaraba\.com\|machibbs\.com$\|jbbs\.net\)'
let s:mx_servers_shitaraba = '^www\.shitaraba\.com$'
let s:mx_servers_machibbs = 'machibbs.com$'
let s:mx_servers_euc = '\%(jbbs\.net\|shitaraba\.com\)'

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
execute "autocmd CursorHold " . s:buftitle_thread . " call s:OpenPreview_autocmd()"
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

" 起動AA表示
function! s:StartupAA(filename, wait)
  if !filereadable(a:filename)
    return 0
  endif
  call s:GoBuf_Thread()
  let oldline = line('.')
  silent! execute 'read '.a:filename
  " アニメーション
  if a:wait >= 0
    " 初期化
    let spnum = 70
    let spstr = AL_string_multiplication(' ', spnum)
    let save_hlsearch = &hlsearch
    let save_wrap = &wrap
    set nohlsearch
    set nowrap
    silent! execute '%s/^        /&'.spstr.'/'
    redraw
    " アニメーションループ
    let i = 0
    while i < spnum
      silent! %s/^        /       /
      redraw
      let wait = a:wait
      while wait > 0
	let wait = wait - 1
      endwhile
      let i = i + 1
    endwhile
    " 後片付け
    let @/ = ''
    let &hlsearch = save_hlsearch
    let &wrap = save_wrap
  endif
  execute oldline
  return 1
endfunction

function! s:AdjustWindowSize(dirwidth, listheight)
  let winnum = winnr()
  if s:GoBuf_BoardList() >= 0
    execute a:dirwidth.' wincmd |'
  endif
  if s:GoBuf_ThreadList() >= 0
    execute a:listheight.' wincmd _'
  endif
  execute winnum.' wincmd w'
endfunction

function! s:CheckNewVersion(verurl, verpath, vercache, ...)
  if !filereadable(a:verpath)
    return 0
  endif
  let interval = a:0 > 0 ? a:1 : 0

  " バージョン情報ダウンロード
  if !filereadable(a:vercache) || localtime() - getftime(a:vercache) > interval
    let mx = '^http://\(.*\)/\([^/]*\)$'
    let host  = substitute(a:verurl, mx, '\1', '')
    let rpath = substitute(a:verurl, mx, '\2', '')
    call s:HttpDownload(host, rpath, a:vercache, '')
  endif
  if !filereadable(a:vercache)
    return 0
  endif

  " 各バージョン番号をファイルから読み取る
  call AL_execute('vertical 1sview '.a:verpath)
  setlocal bufhidden=delete
  let verold = getline(1)
  call AL_execute('view '.a:vercache)
  setlocal bufhidden=delete
  let vernew = getline(1)
  silent! bwipeout!

  return AL_compareversion(verold, vernew) > 0 ? 1 : 0
endfunction

function! s:CheckThreadUpdate(flags)
  if AL_hasflag(a:flags, 'write')
    if exists('b:url')
      call s:HasNewArticle(b:url)
    endif
    call s:GoBuf_Write()
  endif
endfunction

function! s:NextLine()
  if AL_islastline()
    normal! gg
  else
    normal! j
  endif
endfunction

"
" 巡回っぽいことをする
"
function! s:Cruise(flags)
  if AL_hasflag(a:flags, 'thread')
    " スレッドでの巡回
    if AL_islastline() && s:opened_bookmark
      call s:GoBuf_ThreadList()
      call s:NextLine()
      call s:Cruise('bookmark')
    else
      call AL_execute("normal! \<C-F>")
    endif
  elseif AL_hasflag(a:flags, 'bookmark')
    while 1
      " ブックマークでの巡回
      if foldclosed(line('.')) > 0
	normal! zv
      endif
      if !s:ParseURL(matchstr(getline('.'), s:mx_anchor_url))
	call s:NextLine()
      else
	" エントリーがスレッドなら新着チェック
	normal! z.
	" Hotlink表示
	call AL_execute('match DiffAdd /^.*\%'.line('.').'l.*$/')
	" スレ読み込み。ifmodifiedが肝。
	let retval = s:UpdateThread('', s:parseurl_host, s:parseurl_board, s:parseurl_dat, 'continue,ifmodified')
	call s:GoBuf_ThreadList()
	if retval > 0
	  " 更新があった場合
	  call AL_execute('match DiffChange /^.*\%'.line('.').'l.*$/')
	  call s:GoBuf_Thread()
	  call s:AddHistoryJump(s:ScreenLine(), line('.'))
	  while getchar(0) != 0
	  endwhile
	  call s:EchoH('WarningMsg', s:msg_thread_hasnewarticles)
	else
	  " 無かった場合
	  call AL_execute('match Constant /^.*\%'.line('.').'l.*$/')
	  call s:NextLine()
	  " エラーメッセージ選択
	  if retval == -3
	    call s:EchoH('Error', s:msg_thread_lost)
	  elseif retval == -2
	    call s:EchoH('Error', s:msg_thread_dead)
	  else
	    call s:EchoH('', s:msg_thread_nonewarticle)
	  endif
	endif
	break
      endif
    endwhile
  endif
endfunction

"
" 透明あぼーんを示すフラグファイルを作成する。透明あぼーん化した日時とスレタ
" イトルを記入。
"
function! s:AboneThreadDat()
  call s:GoBuf_ThreadList()
  " バッファがスレ一覧ではなかった場合、即終了
  if b:host == '' || b:board == ''
    return
  endif

  " カーソルの現在位置からdat名を取得
  let curline = getline('.')
  if curline =~ s:mx_thread_dat
    let title = substitute(curline, s:mx_thread_dat, '\1', '')
    let dat = substitute(curline, s:mx_thread_dat, '\3', '')
    let abone = s:GenerateAboneFile(b:host, b:board, dat)
    call AL_execute('redir! >' . abone)
    silent echo strftime("%Y/%m/%d %H:%M:%S " .title)
    silent echo ""
    redir END
    if g:chalice_threadinfo
      call s:FormatThreadInfo(line('.'), line('.'), 'numcheck')
    endif
  endif
endfunction

"
" スレの.datを削除する。aboneファイルがあった場合にはそちらを優先して削除。
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
    let abone = s:GenerateAboneFile(b:host, b:board, dat)
    if filereadable(abone)
      " aboneファイルがあれば先に消去
      call delete(abone)
    elseif filereadable(local)
      " datファイルがあれば消去
      call delete(local)
    endif
    if g:chalice_threadinfo
      call s:FormatThreadInfo(line('.'), line('.'), 'numcheck')
    endif
  endif
endfunction

"
" 引数があれば引数の、なければカーソル下のURLを取り出し、スレ更新の有無を
" チェックする。
"
function! s:HasNewArticle(...)
  " 引数もしくは現在行からURLだけを取り出し、host/board/datを抽出
  if a:0 > 0
    let url = a:1
  else
    let url = getline('.')
  endif
  let url = matchstr(url, s:mx_url_2channel)
  if url == ''
    return 0
  endif
  let host = substitute(url, s:mx_url_2channel, '\1', '')
  let board = substitute(url, s:mx_url_2channel, '\2', '')
  let dat = substitute(url, s:mx_url_2channel, '\3.dat', '')

  " 未知のスレ、倉庫落ちしたスレはチェック対象外とする
  let local_dat = s:GenerateLocalDat(host, board, dat)
  let local_kako = s:GenerateLocalKako(host, board, dat)
  if !filereadable(local_dat)
    call s:EchoH('Error', s:msg_thread_unknown)
    return 0
  elseif filereadable(local_kako)
    call s:EchoH('Error', s:msg_thread_lost)
    return 0
  endif

  let remote = board . '/dat/' . dat
  let result = s:HttpDownload(host, remote, local_dat, 'continue,head')

  if result == 206
    call s:EchoH('WarningMsg', s:msg_thread_hasnewarticles)
    return 1
  elseif result == 302
    call s:EchoH('Error', s:msg_thread_dead)
    return 0
  else
    call s:EchoH('', s:msg_thread_nonewarticle)
    return 0
  endif
endfunction

"
" URLをChaliceで開く
"
function! s:HandleURL(url, flag)
  " 通常のURLだった場合、無条件で外部ブラウザに渡している。URLの形をみて2ch
  " ならば内部で開く。
  if a:url !~ '\(https\?\|ftp\)://'.g:AL_pattern_class_url.'\+'
    return 0
  endif
  if AL_hasflag(a:flag, 'external')
    " 強制的に外部ブラウザを使用するように指定された
    call s:OpenURL(a:url)
    return 2
  elseif !s:ParseURL(a:url)
    " Chaliceで取り扱えるURLではない時
    let oldbuf = bufname('%')
    call s:GoBuf_BoardList()
    if search(a:url) != 0
      normal! zO0z.
      execute maparg("<CR>")
    else
      call s:OpenURL(a:url)
    endif
    call AL_selectwindow(oldbuf)
    return 2
  else
    if !AL_hasflag(a:flag, '\cnoaddhist')
      call s:AddHistoryJump(s:ScreenLine(), line('.'))
    endif
    " プレビューウィンドウを閉じる
    if !(g:chalice_preview && AL_hasflag(g:chalice_previewflags, '1'))
      call s:ClosePreview()
    endif

    " Chaliceで取り扱えるURLの時
    "	s:parseurl_host, s:parseurl_board, s:parseurl_datは
    "	ParseURL()内で設定される暗黙的な戻り値。
    let curarticle = s:UpdateThread('', s:parseurl_host, s:parseurl_board, s:parseurl_dat, 'continue')

    if s:parseurl_range_mode =~ 'r'
      if s:parseurl_range_mode !~ 'l'
	" 非リストモード
	" 表示範囲後のfolding
	if s:parseurl_range_end != '$'
	  let fold_start = s:GetLnum_Article(s:parseurl_range_end + 1)  - 1
	  if 0 < fold_start
	    call AL_execute(fold_start . ',$fold')
	  endif
	endif
	" 表示範囲前のfolding
	if s:parseurl_range_start > 1
	  let fold_start = s:GetLnum_Article(s:parseurl_range_mode =~ 'n' ? 1 : 2) - 1
	  let fold_end = s:GetLnum_Article(s:parseurl_range_start) - 2
	  if 0 < fold_start && fold_start < fold_end
	    call AL_execute(fold_start . ',' . fold_end . 'fold')
	  endif
	endif
	call s:GoThread_Article(s:parseurl_range_start)
      else
	" リストモード('l')
	let fold_start = s:GetLnum_Article(s:parseurl_range_mode =~ 'n' ? 1 : 2) - 1
	let fold_end = s:GetLnum_Article(s:GetThreadLastNumber() - s:parseurl_range_start + (s:parseurl_range_mode =~ 'n' ? 1 : 2)) - 2
	if 0 < fold_start && fold_start < fold_end
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

function! s:GetThreadDatname()
  return s:GenerateLocalDat(getbufvar(s:buftitle_thread, 'host'), getbufvar(s:buftitle_thread, 'board'), getbufvar(s:buftitle_thread, 'dat'))
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

function! s:GetAnchor(str)
  let anchor = matchstr(a:str, s:mx_anchor_num)
  if anchor != ''
    return anchor
  endif
  let anchor = matchstr(a:str, s:mx_anchor_url)
  if anchor != ''
    return anchor
  endif
  let anchor = matchstr(a:str, s:mx_anchor_www)
  if anchor != ''
    return anchor
  endif
  return ''
endfunction

function! s:GetAnchorCurline()
  " カーソル下のリンクを探し出す。なければ後方へサーチ
  let context = expand('<cword>')
  let anchor = s:GetAnchor(context)
  if anchor == ''
    let anchor = s:GetAnchor(strpart(getline('.'), col('.') - 1))
  endif
  return anchor
endfunction

"
" 書き込み内のリンクを処理
"
function! s:HandleJump(flag)
  call s:GoBuf_Thread()

  let anchor = s:GetAnchorCurline()

  if anchor =~ s:mx_anchor_num
    let anchor = matchstr(anchor, s:mx_anchor_num)
    " スレの記事番号だった場合
    let num = substitute(anchor, s:mx_anchor_num, '\2', '')
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
    elseif AL_hasflag(a:flag, 'external')
      if b:host != '' && b:board != '' && b:dat != ''
	let num = substitute(anchor, s:mx_anchor_num, '\1', '')
	call s:OpenURL('http://' . b:host . '/test/read.cgi' . b:board . '/' . substitute(b:dat, '\.dat$', '', '') . '/' . num . 'n')
      endif
    endif
  elseif anchor =~ s:mx_anchor_url
    let url = substitute(matchstr(anchor, s:mx_anchor_url), '^ttp', 'http', '')
    return s:HandleURL(url, a:flag)
  elseif anchor =~ s:mx_anchor_www " http:// 無しURLの処理
    let url = 'http://' . matchstr(anchor, s:mx_anchor_www)
    return s:HandleURL(url, a:flag)
  else
    call s:EchoH('ErrorMsg', s:msg_error_cantjump)
  endif
endfunction

function! s:UpdateThreadInfo(host, board, dat)
  if g:chalice_threadinfo
    call s:GoBuf_ThreadList()
    if !exists('b:host') || !exists('b:board')
      return
    endif
    if b:host . b:board ==# a:host . a:board
      if a:dat != '' && search(a:dat, 'w')
	call s:FormatThreadInfo(line('.'), line('.'), 'numcheck')
      endif
    endif
    call s:GoBuf_Thread()
  endif
endfunction

function! s:DatCatchup_2ch(host, board, dat, flags)
  let local = ''
  let prevsize = 0
  let oldarticle = 0
  " 基本戦略
  "   1. kako_dat_*があれば以下はスルー
  "   2. 無い場合にはdat_*の(差分)取得を試みる
  "   3. HTTP返答コードをチェックし、スレが存命なら以下はスルー
  "   4. 倉庫入りしていたら、kako_dat_*として全体を取得する
  "   5. (未定)元のdat_*は捨てるか放置
  let remote = a:board . '/dat/' . a:dat
  let local_dat  = s:GenerateLocalDat(a:host, a:board, a:dat)
  let local_kako = s:GenerateLocalKako(a:host, a:board, a:dat)
  if filereadable(local_kako)
    " 手順1
    let local = local_kako
    let prevsize = getfsize(local_kako)
    let oldarticle = s:CountLines(local_kako)
  elseif filereadable(local_dat) && AL_hasflag(a:flags, 'noforce')
    " noforce指定時はネットアクセスを強制的に行なわない(意味が…変)
    let local = local_dat
    let prevsize = getfsize(local_dat)
    let oldarticle = s:CountLines(local_dat)
  else
    " スレッドの内容をダウンロード
    " ファイルの元のサイズを覚えておく
    if filereadable(local_dat)
      let prevsize = getfsize(local_dat)
      let oldarticle = s:CountLines(local_dat)
    endif
    " 手順2
    let didntexist = filereadable(local_dat) ? 0 : 1
    let result = s:HttpDownload(a:host, remote, local_dat, a:flags)
    if result < 300 || result == 304 || result == 416
      " 手順3
      let local = local_dat
      " (必要ならば)スレ一覧のスレ情報を更新
      call s:UpdateThreadInfo(a:host, a:board, a:dat)
      " TODO: 416の時は2通りの可能性がある。あぼーん発生で本当に範囲外を指定
      " したのか、Apacheが新しい場合は差分が存在しない時。後者については古い
      " Apacheが200を返すのが間違っている。…本当はあぼーん検出に使いたかっ
      " たのだが、ちょっと無理。
    else
      " HTTPエラー時に、元々なかったファイルが出来ていたらゴミとして消去
      if didntexist && filereadable(local_dat)
	call delete(local_dat)
      endif
      " 手順4
      if !AL_hasflag(a:flags, 'ifmodified')
	let idstr = matchstr(a:dat, '\d\+')
	" 新スレッド(1000000000番以降)は格納場所が微妙に異なる
	let remote = strpart(idstr, 0, 3)
	if strlen(idstr) > 9
	  let remote = remote. strpart(idstr, 3, 1) .'/'. strpart(idstr, 0, 5)
	endif
	let remote = a:board.'/kako/'.remote.'/'.a:dat
	" 旧形式の過去ログサーバではログは圧縮されない
	if a:host.a:board !~ s:mx_servers_oldkako
	  let remote = remote.'.gz'
	  let local_kako = local_kako.'.gz'
	endif
	" 2度目の正直、ダウンロード
	let result = s:HttpDownload(a:host, remote, local_kako, '')
	if result == 200 && filereadable(local_kako)
	  if local_kako =~ '\.gz$'
	    call s:Gunzip(local_kako)
	    let local_kako = substitute(local_kako, '\.gz$', '', '')
	  endif
	  let local = local_kako
	else
	  " HTML化待ち
	  call delete(local_kako)
	  if filereadable(local_dat)
	    let local = local_dat
	  endif
	endif " 手順4
      endif
    endif
  endif
  if local == '' && !AL_hasflag(a:flags, 'ifmodified')
    " エラー: スレ無しかHTML化待ち
    call AL_buffer_clear()
    call setline(1, 'Error: '.s:msg_error_nothread)
    call append('$', 'Error: '.s:msg_error_accesshere)
    call append('$', '')
    call append('$', '  '.s:GenerateOpenURL(a:host, a:board, a:dat))
    let b:host = a:host
    let b:board = a:board
    let b:dat = a:dat
    let b:title = s:prefix_thread
    let b:title_raw = ''
    normal! G^
    return 0
  endif

  let b:datutil_datsize = getfsize(local)
  " 更新が無い場合は即終了
  if AL_hasflag(a:flags, 'ifmodified') && prevsize >= b:datutil_datsize
    if local ==# local_dat
      return -1
    elseif local ==# local_kako
      return -3
    else
      return -2
    endif
  endif

  " 不本意なグローバル(バッファ)変数の使用
  let b:chalice_local = local
  return oldarticle + 1
endfunction

"
" スレッドの更新を行なう
"   ifmodifiedを指定した場合には、スレに更新がなかった際にスレは表示せずに-1
"   を返す。通常はスレの取得した分の先頭記事番号を返す。
"
function! s:UpdateThread(title, host, board, dat, flags)
  call s:GoBuf_Thread()
  if a:title != ''
    " スレのタイトルをバッファ名に設定
    let b:title = s:prefix_thread . a:title
    let b:title_raw = a:title
  endif
  " バッファ変数のhost,board,datを引数から作成(コピーだけどね)
  let host  = a:host  != '' ? a:host  : b:host
  let board = a:board != '' ? a:board : b:board
  let dat   = a:dat   != '' ? a:dat   : b:dat
  if host == '' || board == '' || dat == ''
    " TODO: 何かエラー処理が欲しい
    return -1
  endif

  " datファイルを更新する
  if host =~ s:mx_servers_jbbstype
    let dat = substitute(dat, '\.dat$', '.cgi', '')
    let newarticle = s:DatCatchup_JBBS(a:title, host, board, dat, a:flags)
  else
    let newarticle = s:DatCatchup_2ch(host, board, dat, a:flags)
  endif
  " 使用したdatファイル名を取得する
  if exists('b:chalice_local')
    let local = b:chalice_local
    unlet! b:chalice_local
  else
    let local = ''
  endif

  " エラーの場合は終了
  if newarticle <= 0
    return newarticle
  endif

  " スレッドをバッファにロードして整形
  if 1 && (!AL_hasflag(a:flags, 'continue') || a:host != '' || a:board != '' || a:dat != '')
    " 開くべきスレ(URL)が異なっているので、バッファ変数へ格納
    let b:host = host
    let b:board = board
    let b:dat = dat
    " 整形作業
    let title = s:FormatThread(local)
    " 常にdat内のタイトルを使用する
    let b:title = s:prefix_thread . title
    let b:title_raw = title
  else
    " 差分整形
    call s:FormatThreadDiff(local, newarticle)
  endif

  if !s:GoThread_Article(newarticle)
    normal! Gzb
  endif
  call s:Redraw('force')
  call s:EchoH('WarningMsg', s:msg_help_thread)
  " 'nostartofline'対策
  normal! 0
  return newarticle
endfunction

"
" 板内容を更新する
"
function! s:UpdateBoard(title, host, board, flag)
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
  if AL_hasflag(a:flag, 'force') || !filereadable(local) || localtime() - getftime(local) > g:chalice_reloadinterval_threadlist
    call s:HttpDownload(b:host, remote, local, '')
    let updated = 1
  endif

  " スレ一覧をバッファにロードして整形
  call AL_buffer_clear()
  call AL_execute("read " . local)
  call AL_execute("g/^$/delete _") " 空行を削除

  " 整形
  call s:FormatBoard()
  if !AL_hasflag(a:flag, 'showabone')
    call AL_execute('g/^x/delete _')
  endif

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

if has('perl')
  function! s:CountLines_perl(target)
    perl << END_PERL
      my $file = VIM::Eval('a:target');
      open IN, $file;
      1 while <IN>;
      VIM::DoCommand('let lines = '.$.);
      close IN;
END_PERL
    return lines
  endfunction
endif

function! s:CountLines(target)
  if filereadable(a:target)
    if has('perl')
      let lines = s:CountLines_perl(a:target)
    else
      call AL_execute('vertical 1sview ++enc= '.a:target)
      let lines = line('$')
      silent! bwipeout!
    endif
  else
    let lines = 0
  endif
  return lines
endfunction

function! s:Gunzip(filename)
  if filereadable(a:filename) && a:filename =~ '\.gz$'
    call s:DoExternalCommand(s:cmd_gzip . ' -d -f ' . AL_quote(a:filename))
    if filereadable(a:filename)
      call rename(a:filename, substitute(a:filename, '\.gz$', '', ''))
    endif
  endif
endfunction

function! s:Redraw(opts)
  if g:chalice_noredraw
    return
  endif
  let cmd = 'redraw'
  if AL_hasflag(a:opts, 'force')
    "let cmd = cmd . '!'
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
  execute "echohl " . (a:hlname != '' ? a:hlname : 'None')
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

  " Chalice関連のバッファ総てをwipeoutする。
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
  " cURLのパスを取得
  let s:cmd_curl = AL_hascmd('curl')

  " 非CP932環境ではコンバータを取得する必要がある。
  if &encoding != 'cp932'
    if AL_hascmd('qkc') != ''
      let s:cmd_conv = 'qkc -e -u'
    elseif AL_hascmd('nkf') != ''
      let s:cmd_conv = 'nkf -e'
    else
      call s:EchoH('ErrorMsg', s:msg_error_noconv)
      return 0
    endif
  else
    let s:cmd_conv = ''
  endif

  " gzipを探す
  let s:cmd_gzip = AL_hascmd('gzip')
  if s:cmd_gzip == ''
    call s:EchoH('ErrorMsg', s:msg_error_nogzip)
    return 0
  endif

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
    let g:chalice_bookmark = g:chalice_basedir . '/' . s:bookmark_filename
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
  " 以前、この関数はpluginの読み込み時に実行されることがあったので、AL_*が使
  " えなかった。現在はそのようなことはなくなったが、その名残でAL_*は使用して
  " いない。

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

  " 文字コードのコンバート
  if !filereadable(helpfile) || (filereadable(helporig) && getftime(helporig) > getftime(helpfile))
    silent execute "sview " . helporig
    set fileencoding=japan fileformat=unix
    silent execute "write! " . helpfile
    silent! bwipeout!
  endif

  " tagsの更新
  if !filereadable(tagsfile) || getftime(helpfile) > getftime(tagsfile)
    silent execute "helptags " . docdir
  endif
endfunction

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
  if !AL_hasflag(g:chalice_startupflags, 'nohelp')
    silent! call s:HelpInstall(s:scriptdir)
  endif

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
  " set equalalwaysした瞬間に、高さ調整が行なわれてしまうのでpluginを通じて
  " noequalalwaysにした。
  set noequalalways
  set foldcolumn=0
  set ignorecase
  set lazyredraw
  set wrapscan
  set winheight=8
  set winwidth=15
  set scrolloff=0
  let &statusline = '%<%{' . s:sid . 'GetBufferTitle()}%='.g:chalice_statusline.'%{'.s:sid.'GetDatStatus()} %l/%L'
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
  call s:AdjustWindowSize(15, 10)

  " あらゆるネットアクセスの前にオフラインモードフラグを設定
  let s:dont_download = AL_hasflag(g:chalice_startupflags, 'offline') ? 1 : 0

  call s:UpdateBoardList(0)

  " バージョンチェック
  if 1
    let ver_cache = s:dir_cache.'VERSION'
    if 0 < s:CheckNewVersion(s:verchk_verurl, s:verchk_path, ver_cache, s:verchk_interval)
      call s:GoBuf_Thread()
      call AL_buffer_clear()
      call setline(1, 'Info: '.s:msg_error_newversion)
      call append('$', 'Info: '.s:msg_error_accesshere)
      call append('$', '')
      call append('$', '  '.s:verchk_url_1)
      call append('$', '  '.s:verchk_url_2)
      let b:title = s:prefix_thread
      let b:title_raw = ''
      normal! G^
    endif
  endif

  " 指定された場合は栞を開いておく
  if AL_hasflag(g:chalice_startupflags, 'bookmark')
    silent! call s:OpenBookmark()
  endif

  " 起動AA表示
  if 1
    let startup = g:chalice_basedir.'/startup.aa'
    if !filereadable(startup)
      let startup = s:scriptdir.'/../startup.aa'
    endif
    call s:StartupAA(startup, AL_hasflag(g:chalice_startupflags, 'noanime') ? -1 : g:chalice_animewait)
  endif

  " ブックマークへカーソルを移動する
  if AL_hasflag(g:chalice_startupflags, 'bookmark')
    call s:GoBuf_ThreadList()
  endif

  " 開始メッセージ表示
  call s:UpdateTitleString()
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
  " オフラインモードをトグルする
  let s:dont_download = s:dont_download ? 0 : 1
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
    "let extcmd = '"' . extcmd . '"'
    " 何故この処理が必要なのかわからない(思い出せない)。引用符内に&などの特
    " 殊文字があると正しく解釈されない問題があり、それを回避するために暫定的
    " に外すことにする。よってここは意図的に何もしないブロックになる。
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
  let mx2 = '\(http://'.g:AL_pattern_class_url.'\+\)'

  if curline =~ s:mx_thread_dat
    let host = b:host
    let board = b:board
    let title = substitute(curline, s:mx_thread_dat, '\1', '')
    let dat = substitute(curline, s:mx_thread_dat, '\3', '')
    let url = s:GenerateOpenURL(host, board, dat, flag)
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

  let retval =  s:HandleURL(url, flag . ',noaddhist')
  if AL_hasflag(flag, 'firstline')
    normal! gg
  endif

  if retval == 1 && !AL_hasflag(flag, 'external')
    call s:AddHistoryJump(s:ScreenLine(), line('.'))
    if g:chalice_preview && AL_hasflag(g:chalice_previewflags, '1')
      call s:OpenPreview('>>1')
    endif
  endif
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
  call s:UpdateBoard(title, host, board, '')
endfunction

"
" 与えられたURLを2chかどうか判断しる!!
"
function! s:ParseURL_is2ch(url)
  " 各種URLパターン
  let mx = '^' . s:mx_url_2channel
  let mx_old = '^\(http://..\{-}/test/read.cgi\)?bbs=\([^&]\+\)&\%(amp\)\?key=\(\d\+\)\(\S\+\)\?'
  let mx_kako = '^\(http://..\{-}\)/\([^/]\+\)/kako/\%(\d\+/\)\{1,2}\(\d\+\)\.\%(html\|dat\%(\.gz\)\?\)'

  " 古い形式のURLは、現在の形式へ正規化する(→url)
  let url = ''
  if a:url =~ mx
    let url = a:url
  elseif a:url =~ mx_old
    let url = substitute(a:url, mx_old, '\=submatch(1)."/".submatch(2)."/".submatch(3).s:ConvertOldRange(submatch(4))', '')
  elseif a:url =~ mx_kako
    let url = substitute(a:url, mx_kako, '\1/test/read.cgi/\2/\3', '')
  endif

  " 2ch-URLの各構成要素へ分解する
  if url == ''
    return 0
  endif
  let s:parseurl_host = substitute(url, mx, '\1', '')
  let s:parseurl_board = substitute(url, mx, '\2', '')
  let s:parseurl_dat = substitute(url, mx, '\3', '') . '.dat'

  " 表示範囲を解釈
  " 参考資料: http://pc.2ch.net/test/read.cgi/tech/1002820903/
  let range = substitute(url, mx, '\4', '')
  let mx_range = '[-0-9]\+'
  let s:parseurl_range_mode = ''
  let s:parseurl_range_start = ''
  let s:parseurl_range_end = ''
  let str_range = matchstr(range, mx_range)
  if str_range != ''
    " 範囲表記を走査
    let mx_range2 = '\(\d*\)-\(\d*\)'
    if str_range =~ mx_range2
      let s:parseurl_range_start = substitute(str_range, mx_range2, '\1', '')
      let s:parseurl_range_end	 = substitute(str_range, mx_range2, '\2', '')
      if s:parseurl_range_start == ''
	let s:parseurl_range_start = 1
      endif
      if s:parseurl_range_end == ''
	let s:parseurl_range_end = '$'
      endif
    else
      " 数字しかあり得ないので可
      let s:parseurl_range_start = str_range
      let s:parseurl_range_end = str_range
    endif
    let s:parseurl_range_mode = s:parseurl_range_mode . 'r'
    " 表示フラグ(n/l)の判定
    if range =~ 'n'
      let s:parseurl_range_mode = s:parseurl_range_mode . 'n'
    endif
    if range =~ 'l'
      let s:parseurl_range_mode = s:parseurl_range_mode . 'l'
    endif
  endif

  return 1
endfunction

function! s:ConvertOldRange(range_old)
  " 旧形式の2chのURLから、範囲指定を取り出す
  if a:range_old == ''
    return ''
  endif

  let mx_range_last = '&\%(amp\)\?ls=\(\d\+\)'
  let mx_range_part = '&\%(amp\)\?st=\(\d\+\)\%(&\%(amp\)\?to=\(\d\+\)\)\?'
  let mx_range_nofirst = '&\%(amp\)\?nofirst=true'

  let range = ''
  if a:range_old =~ mx_range_last
    let range = AL_sscan(a:range_old, mx_range_last, 'l\1')
  elseif a:range_old =~ mx_range_part
    let range = AL_sscan(a:range_old, mx_range_part, '\1-\2')
  endif
  if a:range_old =~ mx_range_nofirst
    let range = range . 'n'
  endif
  return '/'.range
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

"
" dat, kakoの有無を表示する
"
function! s:GetDatStatus()
  if exists('b:host') && exists('b:board') && exists('b:dat')
    if b:host != '' && b:board != '' && b:dat != ''
      let dat  = s:GenerateLocalDat(b:host, b:board, b:dat)
      let kako = s:GenerateLocalKako(b:host, b:board, b:dat)
      return '['.(filereadable(dat) ? 'D' : '-').(filereadable(kako) ? 'K' : '-').']'
    else
      return '[--]'
    endif
  else
    return ''
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
"
" Flags:
"   continue	継続ダウンロードを行なう
"   head	ヘッダー情報だけを取得する
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

  " ファイルに更新がある時だけ、実際の転送を試みる(If-Modified-Since)
  "if filereadable(local) && (AL_hasflag(a:flag, 'continue') || !AL_hasflag(a:flag, 'force'))
  "  let opts = opts . ' -z ' . AL_quote(local)
  "endif
  " MEMO: 本当に要るのか?

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
  if AL_hasflag(a:flag, 'head')
    " ヘッダー情報だけを取得する (-I オプション)
    let opts = opts . ' -I'
    let opts = opts . ' -o ' . AL_quote(tmp_head)
  else
    let opts = opts . ' -D ' . AL_quote(tmp_head)
    let opts = opts . ' -o ' . AL_quote(local)
  endif
  let opts = opts . ' ' . AL_quote(url)

  " ダウンロード実行
  call s:DoExternalCommand(s:cmd_curl . ' ' . opts)

  " ヘッダー情報取得→テンポラリファイル削除
  call AL_execute('1vsplit ' . tmp_head)
  let retval = substitute(getline(1), '^HTTP\S*\s\+\(\d\+\).*$', '\1', '') + 0
  if compressed
    if search('^\ccontent-encoding:.*gzip', 'w')
      call s:Gunzip(local)
    else
      call rename(local, substitute(local, '\.gz$', '', ''))
    endif
  endif
  silent! bwipeout!
  call delete(tmp_head)

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
    call append(1, " 実験室\t\t\t\thttp://ooo.2ch.net/jikken/")
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
  let oldcol = col('.')
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
    " 入力する方法もあり
    let target = a:num
    if a:num =~ '\cinput'
      let target = input(s:msg_prompt_articlenumber)
    endif
    " 番号から記事の位置を調べる
    let lnum = search('^' . target . '  ', 'bw')
  endif
  call cursor(oldline, oldcol)
  return lnum
endfunction

function! s:GoThread_Article(target)
  let lnum = s:GetLnum_Article(a:target)
  if lnum
    if a:target ==# 'input'
      call s:AddHistoryJump(s:ScreenLine(), line('.'))
    endif
    call AL_execute("normal! ".lnum."Gzt\<C-Y>")
    if foldclosed(lnum) > 0
      normal! zO
    endif
    if a:target ==# 'input'
      call s:AddHistoryJump(s:ScreenLine(), line('.'))
    endif
  endif
  return lnum
endfunction

function! s:GoBuf_Write()
  let retval = AL_selectwindow(s:buftitle_write)
  if retval < 0
    call AL_execute("rightbelow split " . s:buftitle_write)
    setlocal filetype=2ch_write
  endif
  return retval
endfunction

function! s:GoBuf_Preview()
  let retval = AL_selectwindow(s:buftitle_preview)
  return retval
endfunction

function! s:GoBuf_Thread()
  let retval = AL_selectwindow(s:buftitle_thread)
  return retval
endfunction

function! s:GoBuf_BoardList()
  let retval = AL_selectwindow(s:buftitle_boardlist)
  return retval
endfunction

function! s:GoBuf_ThreadList()
  let retval = AL_selectwindow(s:buftitle_threadlist)
  return retval
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

" 最後の要素を削除
function! s:JumplistRemoveLast()
  if s:jumplist_max > 0
    let s:jumplist_max = s:jumplist_max - 1
    if s:jumplist_max <= s:jumplist_current
      let s:jumplist_current = s:jumplist_max - 1
      if s:jumplist_current < 0
	let s:jumplist_current = 0
      endif
    endif
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
  if b:host == '' || b:board == '' || b:dat == ''
    return ''
  endif
  let packed = b:host . ' ' . b:board . ' ' . b:dat . ' ' . a:scline
  if strpart(s:JumplistCurrent(), 0, strlen(packed)) !=# packed
    call s:JumplistAdd(packed . ' ' . a:curline . ' ' . b:title_raw)
    return packed
  endif
  return ''
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
" PREVIEW FUNCTIONS

function! s:OpenPreview_autocmd()
  if g:chalice_preview
    call s:OpenPreview()
  endif
endfunction

"
" カーソル直下のアンカーをプレビュー窓で開く
"
function! s:OpenPreview(...)
  " 現在行のアンカーの検出
  let anchor = a:0 > 0 && a:1 != '' ? a:1 : s:GetAnchorCurline()
  " アンカーがなければ何もしないかプレビューを閉じる
  if anchor !~ s:mx_anchor_num
    if AL_hasflag(g:chalice_previewflags, 'autoclose')
      call s:ClosePreview()
    endif
    return
  endif

  " アンカーとdat名から最後に表示したプレビューを識別し、同じなら表示しない
  let id = s:GetThreadDatname() . anchor
  if id == getbufvar(s:buftitle_preview, 'chalice_preview_id')
    return
  endif

  " アンカーから開始記事と終了記事の番号を取得し、行番号へ変換
  let startnum = substitute(anchor, s:mx_anchor_num, '\2', '') + 0
  let endnum = substitute(anchor, s:mx_anchor_num, '\3', '') + 0
  if startnum > endnum
    let endnum = startnum
  endif
  " 行番号へ変換(先頭の--------を含める)
  let startline = s:GetLnum_Article(startnum) - 1
  let endline = s:GetLnum_Article(endnum + 1) - 3
  if endline < startline
    let endline = line('$')
  endif

  " 存在しないアンカーであればエラーメッセージを表示
  if !(0 < startline && startline < endline)
    call setbufvar(s:buftitle_preview, 'chalice_preview_id', id)
    call s:EchoH('ErrorMsg', s:msg_error_cantpreview .': "'.anchor.'"')
    call s:GoBuf_Thread()
    return
  endif

  " プレビューバッファへ移動、必要なら作成してから移動
  if s:GoBuf_Preview() < 0
    let dir = AL_hasflag(g:chalice_previewflags, 'above') ? 'aboveleft' : 'belowright'
    call AL_execute(dir.' pedit '.s:buftitle_preview)
    call s:GoBuf_Preview() " 失敗したら?…知らん!!
    setlocal filetype=2ch_thread
  endif

  " プレビューバッファを準備する
  call setbufvar(s:buftitle_preview, 'chalice_preview_id', id)
  let b:title = s:prefix_preview . anchor
  call AL_buffer_clear()

  " 該当範囲をプレビューバッファにコピー
  call s:GoBuf_Thread()
  let save_reg = @"
  let @" = ''
  " foldが悪さをしないように退避してfoldenableをリセット
  let save_foldenable = &l:foldenable
  let &l:foldenable = 0
  call AL_execute(startline.','.endline.'yank "')
  let &l:foldenable = save_foldenable
  " 貼り付け～
  call s:GoBuf_Preview()
  call AL_execute("normal! pgg\"_dd")
  let @" = save_reg

  " プレビューの高さ、表示位置を調節する。
  call AL_setwinheight(&previewheight)
  normal! 2GztL$
  let height = winline()
  if height < &previewheight
    call AL_setwinheight(height)
  endif
  normal! 2Gzt

  call s:GoBuf_Thread()
endfunction

function! s:ClosePreview()
  call AL_execute('pclose')
endfunction

function! s:TogglePreview()
  if g:chalice_preview
    let g:chalice_preview = 0
    call s:ClosePreview()
  else
    let g:chalice_preview = 1
  endif
  " プレビューモード表示
  call s:EchoH('WarningMsg', g:chalice_preview ? s:msg_warn_preview_on : s:msg_warn_preview_off)
endfunction

"------------------------------------------------------------------------------
" 2HTML
" HTML化
"

function! s:ShowWithHtml(...)
  call s:GoBuf_Thread()
  if !exists("b:host") || !exists("b:board") || !exists("b:dat")
    call s:EchoH('Error', s:msg_error_htmlnotopen)
    return 0
  endif
  let dat = s:GenerateLocalKako(b:host, b:board, b:dat)
  if !filereadable(dat)
    let dat = s:GenerateLocalDat(b:host, b:board, b:dat)
    if !filereadable(dat)
      call s:EchoH('Error', s:msg_error_htmlnodat)
      return 0
    endif
  endif

  " HTML化開始記事番号と終了記事番号を取得
  if a:0 == 0
    let startnum = matchstr(getline(s:GetLnum_Article('current')), '^\d\+')
    let endnum = startnum
  elseif a:0 == 1
    let mx = '\(\d\+\)-\(\d\+\)'
    if a:1 =~ mx
      let startnum = AL_sscan(a:1, mx, '\1') + 0
      let endnum = AL_sscan(a:1, mx, '\2') + 0
    else
      let startnum = a:1 + 0
      let endnum = startnum
    endif
  else
    let startnum = a:1 + 0
    let endnum = a:2 + 0
  endif

  let url_base  = 'http://'.b:host.'/test/read.cgi'.b:board.'/'.matchstr(b:dat, '\d\+').'/'
  let url_board = 'http://'.b:host.b:board.'/'

  let html = Dat2HTML(dat, startnum, endnum, url_base, url_board)
  if html != ''
    " ファイルへ書き出し
    let temp = s:dir_cache.'tmp.html'
    call AL_execute('redir! > '.temp)
    silent echo html
    redir END
    return AL_open_url('file://'.temp, g:chalice_exbrowser)
  else
    " 通常は起こらないエラー
    call s:EchoH('Error', 'Something wrong with Dat2HTML()!!')
    return 0
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
  match none
  " ブックマークのバックアップファイルネームを作成
  let mx = escape(s:bookmark_filename, '.').'$'
  let backupname = g:chalice_bookmark . s:bookmark_backupsuffix
  if g:chalice_bookmark =~ mx
    let backupname = substitute(g:chalice_bookmark, mx, s:bookmark_backupname, '')
  endif
  " バックアップファイルが充分古ければ再度バックアップを行なう
  if g:chalice_bookmark_backupinterval >= s:minimum_backupinterval && localtime() - getftime(backupname) > g:chalice_bookmark_backupinterval
    call rename(g:chalice_bookmark, backupname)
  endif
  " ブックマークファイルを保存
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

  execute winnum.'wincmd w'
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
    call s:UpdateBoard('', '', '', '')
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
    if b:title_raw == ''
      let title = b:host . b:board . '/' . b:dat
    else
      let title = b:title_raw
    endif
    let url = s:GenerateOpenURL(b:host, b:board, b:dat, 'internal')
  elseif AL_hasflag(a:target, 'threadlist')
    " スレ一覧から栞に登録
    call s:GoBuf_ThreadList()
    let curline = getline('.')
    let mx = '^. \(.\+\) (\d\+) \%(\d\d\d\d\/\d\d\/\d\d \d\d:\d\d:\d\d\)\?\s*\(\d\+\)\.\%(dat\|cgi\)$'
    if b:host == '' || b:board == '' || curline !~ mx
      call s:Redraw('force')
      call s:EchoH('ErrorMsg', s:msg_error_addnothreadlist)
      return
    endif
    let title = substitute(curline, mx, '\1', '')
    let dat = substitute(curline, mx, '\2', '')
    let url = s:GenerateOpenURL(b:host, b:board, dat, 'internal')
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
    let key = substitute(b:dat, '\.\(dat\|cgi\)$', '', '')
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
  " 書き込むべきスレのURLを作成しバッファ変数に保存する
  let b:url = 'http://'.host.'/test/read.cgi/'.bbs.'/'.key
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
    call s:GoBuf_Thread()
  elseif write_result != 0
    let s:opened_write = 0
    call s:GoBuf_Write()
    execute ":close"
    call s:GoBuf_Thread()
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

  " 書き込みデータチャンク作成
  let key = b:key
  let flags = ''
  if b:newthread
    let key = localtime()
    let flags = flags . 'new'
  endif
  let chunk = s:CreateWriteChunk(b:host, b:bbs, key, title, name, mail, message, flags)
  if chunk == ''
    return 0
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
  let opts = opts . ' ' . s:GenerateWriteURL(b:host, b:bbs, b:key)
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

function! s:CreateWriteChunk(host, board, key, title, name, mail, message, ...)
  let flags = a:0 > 0 ? a:1 : ''

  " ホストに合わせてサブミットキーを決定
  let sbmk = '書き込み'
  if AL_hasflag(flags, 'new')
    if a:host =~ s:mx_servers_jbbstype
      let sbmk = '新規書き込み'
    else
      let sbmk = '新規スレッド作成'
    endif
  endif

  " ホストに合わせて書き込みエンコーディングを決定
  let enc_write = 'cp932'
  if a:host =~ s:mx_servers_euc
    let enc_write = 'euc-jisx0213'
  endif

  " 文字コード変換
  let title = a:title
  let name = a:name
  let mail = a:mail
  let msg = a:message
  if &encoding != enc_write
    if has('iconv')
      let title	= iconv(title,	&encoding, enc_write)
      let name	= iconv(name,	&encoding, enc_write)
      let mail	= iconv(mail,	&encoding, enc_write)
      let msg	= iconv(msg,	&encoding, enc_write)
      let sbmk	= iconv(sbmk,	&encoding, enc_write)
    else
      " TODO: エラーメッセージ
      return ''
    endif
  endif

  " 書き込み用チャンク作成
  let sbmk = AL_urlencode(sbmk)
  if b:host =~ s:mx_servers_jbbstype
    return s:CreateWriteChunk_JBBS(a:host, a:board, a:key, title, name, mail, msg, sbmk, flags)
  else

    return s:CreateWriteChunk_2ch(a:host, a:board, a:key, title, name, mail, msg, sbmk, flags)
  endif
endfunction

function! s:CreateWriteChunk_2ch(host, board, key, title, name, mail, message, submitkey, ...)
  " 書き込みデータチャンクを作成
  " 2ちゃんねる、2ちゃんねる互換板、したらば用
  "   利用すべきデータ変数: name, mail, message, a:board, a:key(, host)
  "   参考URL: http://members.jcom.home.ne.jp/monazilla/document/write.html
  let flags = a:0 > 0 ? a:1 : ''
  let chunk = ''
  let chunk = chunk . 'submit=' . a:submitkey
  if !AL_hasflag(flags, 'new')
    let chunk = chunk . '&key=' . a:key
  else
    let chunk = chunk . '&subject=' . AL_urlencode(a:title)
  endif
  let chunk = chunk . '&FROM=' . AL_urlencode(a:name)
  let chunk = chunk . '&mail=' . AL_urlencode(a:mail)
  let chunk = chunk . '&MESSAGE=' . AL_urlencode(a:message)
  let chunk = chunk . '&bbs=' . a:board
  let chunk = chunk . '&time=' . localtime()
  return chunk
endfunction

"------------------------------------------------------------------------------
" FILENAMES
" ファイル名の生成

function! s:GenerateAboneFile(host, board, dat)
  return s:dir_cache . 'abonedat_' . substitute(a:host . a:board, '/', '_', 'g') . '_' . substitute(a:dat, '\.\(dat\|cgi\)$', '', '')
endfunction

function! s:GenerateLocalDat(host, board, dat)
  return s:dir_cache . 'dat_' . substitute(a:host . a:board, '/', '_', 'g') . '_' . substitute(a:dat, '\.\(dat\|cgi\)$', '', '')
endfunction

function! s:GenerateLocalKako(host, board, dat)
  return s:dir_cache . 'kako_dat_' . substitute(a:host . a:board, '/', '_', 'g') . '_' . substitute(a:dat, '\.\(dat\|cgi\)$', '', '')
endfunction

function! s:GenerateLocalSubject(host, board)
  return s:dir_cache . 'subject_' . substitute(a:host . a:board, '/', '_', 'g')
endfunction

"------------------------------------------------------------------------------
" FORMATTING
" 各ペインの整形

function! s:ShowNumberOfArticle(flags)
  if AL_hasflag(a:flags, 'all')
    call s:FormatThreadInfo(1, 0, 'numcheck')
  elseif AL_hasflag(a:flags, 'curline')
    call s:FormatThreadInfo(line('.'), line('.'), 'numcheck')
  endif
endfunction

function! s:FormatThread(local)
  " バッファクリアとスレdatの読み込み
  call AL_buffer_clear()
  call AL_execute("read " . a:local)
  normal! gg"_dd
  " 最終記事番号を取得
  let b:chalice_lastnum = line('$')
  " Do the 整形
  call s:EchoH('WarningMsg', s:msg_wait_threadformat)
  return Dat2Text(g:chalice_verbose > 0 ? 'verbose' : '')
endfunction

function! s:FormatThreadDiff(local, newarticle)
  call AL_execute('vertical 1sview '.a:local)
  " 整形作業
  let contents = ''
  let i = a:newarticle
  let lastnum = line('$')
  while i <= lastnum
    let contents =  contents ."\r". DatLine2Text(i, getline(i))
    let i = i + 1
  endwhile
  silent! bwipeout!
  " スレバッファへ挿入
  let save_reg = @"
  let @" = substitute(contents, "\r", "\<NL>", 'g')
  call s:GoBuf_Thread()
  normal! G$p
  let @" = save_reg
  " 最終記事番号を保存
  let b:chalice_lastnum = lastnum
endfunction

"
" endlineに0を指定するとバッファの最後。
"
function! s:FormatThreadInfo(startline, endline, ...)
  call s:GoBuf_ThreadList()
  " バッファがスレ一覧ではなかった場合、即終了
  if s:opened_bookmark || b:host == '' || b:board == ''
    return
  endif
  let flags = a:0 > 0 ? a:1 : ''

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
      let abone = s:GenerateAboneFile(b:host, b:board, dat)
      " ファイルが存在するならばファイル情報を取得
      let indicator = ' '
      let time = ''
      let artnum = 0
      if filereadable(abone)
	let indicator = 'x'
      elseif filereadable(local)
	let lasttime = getftime(local)
	let indicator = localtime() - lasttime > g:chalice_threadinfo_expire ? '+' : '*'
	let time = strftime("%Y/%m/%d %H:%M:%S", lasttime)
	" 既存の書込み数をチェック
	if AL_hasflag(flags, 'numcheck')
	  let artnum = s:CountLines(local)
	endif
      endif
      " タイトルと書き込み数を取得
      let title = substitute(curline, s:mx_thread_dat, '\1', '')
      let point = substitute(curline, s:mx_thread_dat, '\2', '')
      let point = matchstr(point, '\d\+$')
      " 書き込み数を表示に反映
      if artnum > 0
	if point > artnum
	  let indicator = '!'
	endif
      endif
      let numloc = artnum == 0 && filereadable(local) ? '???' : artnum
      let numrem = point < artnum ? artnum : point
      let point = numloc .'/'. numrem
      " ラインの内容が変化していたら設定
      let newline = indicator . ' ' . title . ' (' . point . ') ' . time . "\t\t\t\t" . dat
      if curline !=# newline
	call setline(i, newline)
      endif
    endif
    let i = i + 1
  endwhile

  normal! 0
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
  call AL_decode_entityreference_with_range('%')
  call AL_del_lastsearch()

  if g:chalice_threadinfo
    call s:FormatThreadInfo(1, 0, g:chalice_autonumcheck != 0 ? 'numcheck' : '')
  endif
endfunction

"------------------------------------------------------------------------------
" BBS WRAPPER
" BBSの種別を隠蔽するためのラッパー
"

function! s:GenerateWriteURL(host, board, key, ...)
  " host, board, key, flagからき込み用URLを生成する
  let flags = a:0 > 0 ? a:1 : ''
  if a:host =~ s:mx_servers_jbbstype
    let url = ' http://' . a:host . '/bbs/write.cgi'
  elseif a:host =~ s:mx_servers_shitaraba
    let url = ' http://' . a:host . '/../cgi-bin/bbs.cgi'
  else
    let url = ' http://' . a:host . '/test/bbs.cgi'
  endif
  return url
endfunction

function! s:GenerateOpenURL(host, board, key, ...)
  " host, board, key, flagから開くべきURLを生成する
  let flags = a:0 > 0 ? a:1 : ''
  let board = substitute(a:board, '^/', '', '')
  let key = substitute(a:key, '\.\(dat\|cgi\)$', '', '')
  if a:host =~ s:mx_servers_jbbstype
    let url = 'http://'.a:host.'/bbs/read.cgi?BBS='.board.'&KEY='.key
    if !AL_hasflag(flags, 'internal')
      let url = url . '&LAST=50'
    endif
  else
    let url = 'http://'.a:host.'/test/read.cgi/'.board.'/'.key
    if !AL_hasflag(flags, 'internal')
      let url = url . '/l50'
    endif
  endif
  return url
endfunction

function! s:ParseURL(url)
  if s:ParseURL_is2ch(a:url)
    return 1
  elseif s:ParseURL_isJBBS(a:url)
    return 1
  else
    return 0
  endif
endfunction

"------------------------------------------------------------------------------
" JBBS
" JBBS/したらば/まちBBS対応用
"

function! s:ParseURL_isJBBS(url)
  let mx = '^http://\(..\{-\}\)/bbs/read.cgi?BBS=\([^/&]\+\)&KEY=\(\d\+\)\(.*\)'
  if a:url !~ mx
    return 0
  endif

  let s:parseurl_host = substitute(a:url, mx, '\1', '')
  let s:parseurl_board = substitute(a:url, mx, '/\2', '')
  let s:parseurl_dat = substitute(a:url, mx, '\3', '') . '.cgi'

  let s:parseurl_range_mode = ''
  let s:parseurl_range_start = ''
  let s:parseurl_range_end = ''
  let range = substitute(a:url, mx, '\4', '')
  if range != ''
    let mx_range_start = '&START=\(\d\+\)'
    let mx_range_end = '&END=\(\d\+\)'
    let mx_range_last = '&LAST=\(\d\+\)'
    let mx_range_nofirst = '&NOFIRST=TRUE'
    if range =~ mx_range_start
      let s:parseurl_range_start = AL_sscan(range, mx_range_start, '\1')
    endif
    if range =~ mx_range_end
      let s:parseurl_range_end = AL_sscan(range, mx_range_end, '\1')
    endif
    if s:parseurl_range_start == ''
      let s:parseurl_range_start = 1
    endif
    if s:parseurl_range_end == ''
      let s:parseurl_range_end = '$'
    endif
    let s:parseurl_range_mode = s:parseurl_range_mode . 'r'
    if range =~ mx_range_nofirst
      let s:parseurl_range_mode = s:parseurl_range_mode . 'n'
    endif
    if range =~ mx_range_last
      let s:parseurl_range_mode = s:parseurl_range_mode . 'l'
      let s:parseurl_range_start = substitute(range, mx_range_last, '\1', '')
    endif
  endif
  return 1
endfunction

function! s:DatCatchup_JBBS(title, host, board, dat, flags)
  let local = s:GenerateLocalDat(a:host, a:board, a:dat)
  let prevsize = getfsize(local)
  let oldarticle = 0
  " 差分取得用のフラグ
  let continued = 0
  if AL_hasflag(a:flags, 'continue') && filereadable(local)
    let continued = 1
    let oldarticle = s:CountLines(local)
  endif

  let newarticle = oldarticle + 1

  if !s:dont_download && !AL_hasflag(a:flags, 'noforce')
    let tmpfile = tempname()
    let bbs = substitute(a:board, '^/', '', '')
    let key = substitute(a:dat, '\.cgi$', '', '')
    " WORKAROUND: まちBBSではread.plを使ったほうが速い。
    let cgi = a:host =~# s:mx_servers_machibbs ? 'read.pl' : 'read.cgi'
    if continued
      let remote = '/bbs/'.cgi.'?BBS='.bbs.'&KEY='.key.'&START='.newarticle.'&NOFIRST=TRUE'
    else
      let remote = '/bbs/'.cgi.'?BBS='.bbs.'&KEY='.key
    endif
    let result = s:HttpDownload(a:host, remote, tmpfile, '')
    let result = s:Convert_JBBSHTML2DAT(local, tmpfile, continued)
    call delete(tmpfile)
    if !result
      " スレが存在しない
      call s:GoBuf_Thread()
      call AL_buffer_clear()
      call setline(1, 'Error: '.s:msg_error_nothread)
      call append('$', 'Error: '.s:msg_error_accesshere)
      call append('$', '')
      call append('$', '  '.s:GenerateOpenURL(a:host, a:board, a:dat))
      let b:host = a:host
      let b:board = a:board
      let b:dat = a:dat
      let b:title = s:prefix_thread
      let b:title_raw = ''
      return 0
    endif
  endif

  call s:GoBuf_Thread()
  let b:datutil_datsize = getfsize(local)
  if AL_hasflag(a:flags, 'ifmodified') && prevsize >= b:datutil_datsize
    return -1
  endif

  call s:UpdateThreadInfo(a:host, a:board, a:dat)
  let b:chalice_local = local
  return newarticle
endfunction

function! s:Convert_JBBSHTML2DAT(datfile, htmlfile, continued)
  " jbbs.net、jbbs.shitaraba.com、machibbs.comのcgiアウトプットを解析。
  " 1レスは<dt>要素から始まる1行で形成されており、下の様な形式（共通）：
  "
  " <dt>1 名前：<b>NAME</b> 投稿日： 2002/05/29(水) 00:48<br><dd>本文 <br><br>
  " ^^^^^^^^^^^^           ^^^^^^^^^                     ^^^^^^^^    ^^^^^^^^^
  "
  " 上の '^' で示した部分を削除、または区切り文字 '<>' に置換することで、2
  " ちゃんのdat形式に変換する。

  call AL_execute('1vsplit '.a:htmlfile)
  if !a:continued
    " 全取得の場合、タイトルを保持しておく
    call search('<title>')
    let title = substitute(getline('.'), '<title>\([^<]*\)</title>', '\1', '')
  endif
  " リモートホストのアドレス表示機能がある板（まち、JBBSの一部）で、記事中に
  " 挿入される改行を修正。例：
  "
  " <dt>1 名前：<b>NAME</b> 投稿日： 2002/07/12(金) 14:55 [ remote.host.ip
  "  ]<br><dd> 本文 <br><br>
  if getline(search('^<dt>') + 1) =~ '^\s*]'
    silent g/^<dt>/join
  endif
  silent v/^<dt>/delete _
  silent %s+^<dt>\d\+\s*名前：\%(<a href="mailto:\([^"]*\)">\)\?\(.\{-\}\)\%(</a>\)\?\s*投稿日：\s*\(.*\)\s*<br>\s*<dd>+\2<>\1<>\3<>+ie
  if getline(1) !~ '^$'
    if a:continued
      silent %s/\s*\(<br>\)\+$/<>/
      call AL_execute('write! >> '.a:datfile)
    else
      silent 1s/\s*\(<br>\)\+$/\='<>'.title/
      if line('$') > 1
	silent 2,$s/\s*\(<br>\)\+$/<>/
      endif
      call AL_execute('write! '.a:datfile)
    endif
  endif
  silent! bwipeout!
  if !filereadable(a:datfile)
    return 0
  else
    return 1
  endif
endfunction

function! s:CreateWriteChunk_JBBS(host, board, key, title, name, mail, message, submitkey, ...)
  " jbbs.net, jbbs.shitaraba.com, machibbs.com用の書き込みデータチャンク作成
  let chunk = ''
  let chunk = chunk . 'submit=' . a:submitkey
  if !b:newthread
    let chunk = chunk . '&KEY=' . b:key
  else
    let chunk = chunk . '&SUBJECT=' . AL_urlencode(a:title)
  endif
  let chunk = chunk . '&NAME=' . AL_urlencode(a:name)
  let chunk = chunk . '&MAIL=' . AL_urlencode(a:mail)
  let chunk = chunk . '&MESSAGE=' . AL_urlencode(a:message)
  let chunk = chunk . '&BBS=' . b:bbs
  if !b:newthread
    let chunk = chunk . '&TIME=' . localtime()
  else
    let chunk = chunk . '&TIME=' . b:key
  endif
  return chunk
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
  command! -nargs=1 ChaliceReloadThreadList	call <SID>UpdateBoard('', '', '', <q-args>)
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
  command! ChaliceAboneThreadDat	call <SID>AboneThreadDat()
  command! ChaliceToggleNetlineStatus	call <SID>ToggleNetlineState()
  command! -nargs=* ChalicePreview	call <SID>OpenPreview(<q-args>)
  command! ChalicePreviewClose		call <SID>ClosePreview()
  command! ChalicePreviewToggle		call <SID>TogglePreview()
  command! -nargs=* ChaliceCruise	call <SID>Cruise(<q-args>)
  command! -nargs=* ChaliceShowNum	call <SID>ShowNumberOfArticle(<q-args>)
  command! -nargs=* ChaliceCheckThread	call <SID>CheckThreadUpdate(<q-args>)
  command! -nargs=* Chalice2HTML	call <SID>ShowWithHtml(<f-args>)
  command! ChaliceAdjWinsize		call <SID>AdjustWindowSize(15,10)
  delcommand Chalice
endfunction

function! s:CommandUnregister()
  command! Chalice			call <SID>ChaliceOpen()
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
  delcommand ChaliceAboneThreadDat
  delcommand ChaliceToggleNetlineStatus
  delcommand ChalicePreview
  delcommand ChalicePreviewClose
  delcommand ChalicePreviewToggle
  delcommand ChaliceCruise
  delcommand ChaliceShowNum
  delcommand ChaliceCheckThread
  delcommand Chalice2HTML
  delcommand ChaliceAdjWinsize
endfunction
