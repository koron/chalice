" vim:set ts=8 sts=2 sw=2 tw=0 nowrap:
"
" chalice.vim - 2ch viewer 'Chalice' /
"
" Last Change: 07-Mar-2002.
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

" スレ鮮度表示
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

" Chalice 起動時に'columns'を変えることができる(-1:無効)
if !exists('g:chalice_columns')
  let g:chalice_columns = -1
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
let s:msg_help_threadlist = '(スレ一覧)  <CR>:スレ決定 j/k:スレ選択  d:dat削除  R:更新'
let s:msg_help_thread = '(スレッド)  i:書込  I:sage書込  a:匿名書込  A:匿名sage  r:更新'
let s:msg_help_bookmark = '(スレの栞)  <CR>:URL決定  h/l:閉/開 <C-A>:閉じる  [編集可能]'
let s:msg_help_write = '(書き込み)  <C-CR>:書き込み実行  <C-W>c:閉じる  [編集可能]'

"------------------------------------------------------------------------------
" 定数値 CONSTANT
"   内部でのみ使用するもの

" デバッグフラグ (DEBUG FLAG)
let s:debug = 1

" 2ch認証のための布石
let s:user_agent = 'Monazilla/1.00 Chalice/1.2e'
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

" 起動フラグ
let s:opend = 0

" 外部コマンド実行ファイル名
let s:cmd_curl = ''
let s:cmd_conv = ''
let s:cmd_gzip = ''

" MATCH PATTERNS
let s:mx_thread_dat = '^[ !+] \(.\+\) (\(\d\+\)).*\t\+\(\d\+\.dat\)'

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
  if a:url !~ '\(http\|ftp\)://[-!#%&+,./0-9:;=?@A-Za-z_~]\+' " URLPAT
    return 0
  endif
  if s:DoesFlagHaveTarget(a:flag, '\cexternal') || !s:Parse2chURL(a:url)
    " 強制的に外部ブラウザを使用するように指定されたかURLが、2chではない時
    call s:OpenURL(a:url)
  else
    if !s:DoesFlagHaveTarget(a:flag, '\cnoaddhist')
      call s:AddHistoryJump(s:ScreenLine(), line('.'))
    endif

    " URLが2chと判断される時
    "	s:parse2ch_host, s:parse2ch_board, s:parse2ch_datはParse2chURL()内で
    "	設定される暗黙的な戻り値。
    call s:UpdateThread('', s:parse2ch_host, s:parse2ch_board, s:parse2ch_dat . '.dat', 'continue')

    if s:parse2ch_range_mode =~ 'r'
      if s:parse2ch_range_mode !~ 'l'
	" 非リストモード
	" 表示範囲後のfolding
	if s:parse2ch_range_end != '$'
	  let fold_start = s:GetLnum_Article(s:parse2ch_range_end + 1)  - 1
	  silent! execute fold_start . ',$fold'
	endif
	" 表示範囲前のfolding
	if s:parse2ch_range_start > 1
	  let fold_start = s:GetLnum_Article(s:parse2ch_range_mode =~ 'n' ? 1 : 2) - 1
	  let fold_end = s:GetLnum_Article(s:parse2ch_range_start) - 2
	  silent! execute fold_start . ',' . fold_end . 'fold'
	endif
      else
	" リストモード
	" TODO: 表示範囲指定を解釈
      endif
    endif

    if !s:DoesFlagHaveTarget(a:flag, '\cnoaddhist')
      call s:AddHistoryJump(s:ScreenLine(), line('.'))
    endif
  endif
  return 1
endfunction

"
" URLを外部ブラウザに開かせる
"
function! s:OpenURL(url)
  let retval = 0
  if a:url == ''
    return retval
  endif
  let url = escape(a:url, '%#')
  if has('win32')
    " URLをクリップボードへ放り込む
    let @* = url
    " Windows環境での外部ブラウザ起動
    if !has('win95') && url !~ '[&!]'
      " NT系ではこっちの方がうまく行くことが多い
      silent execute '!start /min cmd /c start ' . url
      if s:debug | let @a = '!start /min cmd /c start ' . url | endif
    else
      silent! execute "!start rundll32 url.dll,FileProtocolHandler " . url
      if s:debug | let @a = "!start rundll32 url.dll,FileProtocolHandler " . url | endif
    endif
    let retval = 1
  elseif g:chalice_exbrowser != ''
    " 非Windows環境での外部ブラウザ起動
    "
    " 次行の置換で'&'が'%URL%'に置換わるのを防ぐ。
    " '~'が直前の置換パターンで置換わるのを防ぐ
    let url = escape(url, '&~')
    let excmd = substitute(g:chalice_exbrowser, '%URL%', url, 'g')
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
  let mx1 = '>>\(\(\d\+\)\(-\d\+\)\?\)'
  let mx2 = '\(\(h\?ttp\|ftp\)://[-!#%&+,./0-9:;=?@A-Za-z_~]\+\)' " URLPAT

  " カーソル下のリンクを探し出す。なければ後方へサーチ
  let context = expand('<cword>')
  if context !~ mx1 && context !~ mx2
    let context = strpart(getline('.'), col('.') - 1)
  endif

  if context =~ mx1
    " スレの記事番号だった場合
    let num = substitute(matchstr(context, mx1), mx1, '\2', '')
    if s:DoesFlagHaveTarget(a:flag, '\cinternal')
      let oldsc = s:ScreenLine()
      let oldcur = line('.')
      let lnum = s:GoThread_Article(num)
      if lnum > 0
	silent! execute lnum . "foldopen!"
	" 参照元をヒストリに入れる
	call s:AddHistoryJump(oldsc, oldcur)
	" 参照先をヒストリに入れる
	call s:AddHistoryJump(s:ScreenLine(), line('.'))
      endif
    elseif s:DoesFlagHaveTarget(a:flag, '\cexternal')
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
  if !filereadable(local) || !s:DoesFlagHaveTarget(a:flag, '\cnoforce')
    " ファイルの元のサイズを覚えておく
    if filereadable(local)
      let prevsize = getfsize(local)
    endif
    call s:HttpDownload(b:host, remote, local, a:flag)
    " (必要ならば)スレ一覧のスレ情報を更新
    if g:chalice_threadinfo
      call s:FormatThreadInfo(1, 0)
      call s:GoBuf_Thread()
    endif
  endif

  " スレッドをバッファにロードして整形
  call s:ClearBuffer()
  silent! execute "read " . local
  normal! gg"_dd
  if prevsize > 0
    silent! execute 'normal! ' . prevsize . 'go'
    let newarticle = line('.') + 1
  else
    let newarticle = 1
  endif

  " a:titleが設定されていない時、1の書き込みからスレ名を判断する
  if a:title == ''
    let title = substitute(getline(1), '^.\+<>\(.\+\)$', '\1', '')
    if title != ''
      " スレのタイトルをバッファ名に設定
      let b:title = s:prefix_thread . title
      let b:title_raw = title
    endif
  endif

  " 整形
  call s:FormatThread()

  if !s:GoThread_Article(newarticle)
    normal! Gzb
  endif
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
  let local = s:GenerateLocalSubject(b:host, b:board)
  let remote = b:board . '/subject.txt'
  let updated = 0
  if a:force || !filereadable(local) || localtime() - getftime(local) > g:chalice_reloadinterval_threadlist
    call s:HttpDownload(b:host, remote, local, '')
    let updated = 1
  endif

  " スレ一覧をバッファにロードして整形
  call s:ClearBuffer()
  silent! execute "read " . local
  " 整形
  call s:FormatBoard()

  " 先頭行へ移動
  silent! normal! gg0

  if !updated
    redraw!
    call s:EchoH('WarningMsg', s:msg_warn_oldthreadlist)
  endif
endfunction

"------------------------------------------------------------------------------
" 暫定的に固まった関数群 
" FIXED FUNCTIONS

function! s:DoesFlagHaveTarget(flag, target)
  return a:flag =~ '\(^\|,\)' . a:target .'\(,\|$\)'
endfunction

" スクリーンに表示されている先頭の行番号を取得する
function! s:ScreenLine()
  let wline = winline() - 1
  silent! normal! H
  let retval = line('.')
  while wline > 0
    silent! execute 'normal! gj'
    let wline = wline - 1
  endwhile
  return retval
endfunction

function! s:ScreenLineJump(scline, curline)
  " 大体の位置までジャンプ
  let curline = a:curline > 0 ? a:curline - 1 : 0
  silent! execute 'normal! ' . (a:scline + curline) . 'G'
  " 目的位置との差を計測
  let offset = a:scline - s:ScreenLine()
  if offset < 0
    silent! execute 'normal! ' . (-offset) . "\<C-Y>"
  elseif offset > 0
    silent! execute 'normal! ' . offset . "\<C-E>"
  endif
  " スクリーン内でのカーソル位置を設定する
  silent! execute 'normal! H'
  while curline > 0
    silent! execute 'normal! gj'
    let curline = curline - 1
  endwhile
endfunction

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
  if s:DoesFlagHaveTarget(a:flag, 'all')
    execute "qall!"
  endif
  let s:opend = 0

  " 変更したグローバルオプションの復帰
  let &charconvert = s:charconvert
  let &columns = s:columns
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

  " 退避してあった'wildignore'を復帰
  let &wildignore = wildignore

  " ディレクトリ情報構築
  if exists('g:chalice_cachedir') && isdirectory(g:chalice_cachedir)
    let s:dir_cache = substitute(g:chalice_cachedir, '[^\/]$', '&/', '')
  else
    let s:dir_cache = g:chalice_basedir . '/cache/'
  endif
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
  let s:columns = &columns
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
  set foldcolumn=0
  set ignorecase
  set lazyredraw
  set wrapscan
  set winheight=8
  set winwidth=15
  set scrolloff=0
  let &statusline = '%<%{' . s:sid . 'GetBufferTitle()}%=%l/%L'
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
  if has('win32') && &shell =~ '\ccmd'
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
  let mx2 = '\(http://[-!#%&+,./0-9:;=?@A-Za-z_~]\+\)' " URLPAT

  if curline =~ s:mx_thread_dat
    let host = b:host
    let board = b:board
    let title = substitute(curline, s:mx_thread_dat, '\1', '')
    let dat = substitute(curline, s:mx_thread_dat, '\3', '')
    let url = 'http://' . host . '/test/read.cgi' . board . '/'. substitute(dat, '\.dat$', '', '') . '/l50'
  elseif curline =~ mx2
    let url = matchstr(curline, mx2)
  else
    " foldの開閉をトグル
    normal! 0za
    return
  endif

  call s:HandleURL(url, flag . ',noaddhist')
  if flag =~ '\cfirstline'
    normal! gg
  endif
  call s:AddHistoryJump(s:ScreenLine(), line('.'))
endfunction

"
" 現在のカーソル行の板を開く
"
function! s:OpenBoard(...)
  let board = getline('.')
  let mx = '^ \(\S\+\)\s\+http://\([^/]\+\)\(/\S*\).*$'
  if board !~ mx
    " foldの開閉をトグル
    normal! 0za
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
    if a:0 > 0 && a:1 =~ 'external'
      return s:OpenURL('http://' . host . board . '/')
    endif
    call s:UpdateBoard(title, host, board, 0)
  endif
endfunction

"
" 与えられたURLを2chかどうか判断しる!!
"
function! s:Parse2chURL(url)
  let mx = '^http://\([^/]\+\)/test/read.cgi\(/[^/]\+\)/\(\d\+\)\(.*\)'
  if a:url !~ mx
    return 0
  endif
  let s:parse2ch_host = substitute(a:url, mx, '\1', '')
  let s:parse2ch_board = substitute(a:url, mx, '\2', '')
  let s:parse2ch_dat = substitute(a:url, mx, '\3', '')

  " 表示範囲を解釈
  " 参考資料: http://pc.2ch.net/test/read.cgi/tech/1002820903/
  let range = substitute(a:url, mx, '\4', '')
  let mx_n1 = '^/\(n\=\)\(\d\+\)-\(\d\+\)$'
  let mx_n2 = '^/\(n\=\)\(\d\+\)-$'
  let mx_n3 = '^/\(n\=\)-\(\d\+\)$'
  let mx_n4 = '^/\(n\=l\=\)\(\d\+\)$'
  let article_mode = ''
  let article_start = ''
  let article_end = ''
  if range =~ mx_n1
    let article_mode = 'r' . substitute(range, mx_n1, '\1', '')
    let article_start = substitute(range, mx_n1, '\2', '')
    let article_end = substitute(range, mx_n1, '\3', '')
  elseif range =~ mx_n2
    let article_mode = 'r' . substitute(range, mx_n2, '\1', '')
    let article_start = substitute(range, mx_n2, '\2', '')
    let article_end = '$'
  elseif range =~ mx_n3
    let article_mode = 'r' . substitute(range, mx_n3, '\1', '')
    let article_start = 1
    let article_end = substitute(range, mx_n3, '\2', '')
  elseif range =~ mx_n4
    let article_mode = 'r' . substitute(range, mx_n4, '\1', '')
    let article_start = substitute(range, mx_n4, '\2', '')
    let article_end = article_start
  endif
  let s:parse2ch_range_mode = article_mode
  let s:parse2ch_range_start = article_start
  let s:parse2ch_range_end = article_end

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
  silent! execute "topleft 15vnew! " . s:buftitle_boardlist
  setlocal filetype=2ch_boardlist
  let b:title = s:label_boardlist

  " スレッド一覧用バッファ(==板)を開く
  call s:GoBuf_Thread()
  silent! execute "leftabove 10new! " . s:buftitle_threadlist
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

  let local = a:localpath
  let url = 'http://' . a:host . '/' . substitute(a:remotepath, '^/', '', '')
  let continued = 0
  let compressed = 0

  " 起動オプションの構築→cURLの実行
  let fq = s:GetFileQuote()
  let opts = g:chalice_curl_options

  " 生dat読み込み制限に対応
  if s:user_agent_enable
    let opts = opts . ' -A ' .fq. s:user_agent .fq
  endif

  " 継続ロードのオプション設定
  if s:DoesFlagHaveTarget(a:flag, 'continue')
    let size = getfsize(local)
    if size > 0
      let continued = 1
      let opts = opts . ' -C ' . size
    endif
  endif

  " 圧縮ロードのオプション設定
  if !continued && g:chalice_gzip && s:cmd_gzip != ''
    let compressed = 1
    let local = local . '.gz'
    let opts = opts . ' -H Accept-Encoding:gzip,deflate'
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

  let local_menu = s:dir_cache . s:menu_localpath
  " 板一覧の読み込み
  if a:force || !filereadable(local_menu) || localtime() - getftime(local_menu) > g:chalice_reloadinterval_boardlist
    " 2chのフレームを読み込んでframedataに格納
    let local_frame = tempname()
    call s:HttpDownload(s:host, s:remote, local_frame, '')
    silent! execute '%delete _'
    silent! execute 'read ' . local_frame
    silent! execute "%join"
    let framedata = getline('.')
    silent! execute '%delete _'
    call delete(local_frame)

    " frameタグの解釈
    let framedata = substitute(framedata, '^.*\(frame\>[^>]*name="\?menu"\?[^>]*\)>.*$', '\1', '')
    let mx = '^.*src="\?http://\([^/]\+\)/\([^" ]*\)"\?.*$'
    let menu_host = substitute(framedata, mx, '\1', '')
    let menu_remotepath = substitute(framedata, mx, '\2', '')
    if menu_host == ''
      let menu_host = s:menu_host
      let menu_remotepath = s:menu_remotepath
    endif

    " メニューファイルの読込
    call s:HttpDownload(menu_host, menu_remotepath, local_menu, '')
  endif

  " 板一覧の整形
  call s:ClearBuffer()
  silent! execute 'read ' . local_menu
  " 改行<BR>を本当の改行に
  silent! execute "%s/\\c<br>/\r/g"
  " カテゴリと板へのリンク以外を消去
  silent! execute '%g!/^\c<[AB]\>/delete _'
  " カテゴリを整形
  silent! execute '%s/^<B>\([^<]*\)<\/B>/' . s:label_boardcategory_mark . '\1/'
  " 板名を整形
  silent! execute '%s/^<A HREF=\([^ ]*\)[^>]*>\([^<]*\)<\/A>/ \2\t\t\t\t\1'
  " 「2ch総合案内」を削除…本当はちゃんとチェックしなきゃダメだけど。
  silent! execute '1,/^■/-1delete _'
  "normal! gg"_dd0

  " テスト鯖へのリンクを板一覧に埋め込む
  if s:debug
    call append(0, "■テスト鯖")
    call append(1, " ばたー\t\t\t\thttp://tora3.2ch.net/butter/")
  endif

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

function! s:GetLnum_Article(num)
  call s:GoBuf_Thread()
  if a:num =~ '\cnext'
    let lnum = search('^\d\+  ', 'W')
  elseif a:num =~ '\cprev'
    let lnum = search('^\d\+  ', 'bW')
  else
    let lnum = search('^' . a:num . '  ', 'bw')
  endif
  return lnum
endfunction

function! s:GoThread_Article(num)
  let lnum = s:GetLnum_Article(a:num)
  if lnum
    silent! execute "normal! zt\<C-Y>"
  endif
  return lnum
endfunction

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
  if s:DoesFlagHaveTarget(a:flag, '\cnext')
    let data = s:JumplistNext()
  elseif s:DoesFlagHaveTarget(a:flag, '\cprev')
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
    silent! execute 'normal! ' . curline . 'G'
  endif
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
    call append(0, a:title . "\t\t\t\t" . url)
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
  if s:DoesFlagHaveTarget(a:flag, 'thread')
    call s:GoBuf_Thread()
  elseif s:DoesFlagHaveTarget(a:flag, 'threadlist')
    call s:GoBuf_ThreadList()
  endif
endfunction

function! s:Thread2Bookmark(target)
  if a:target =~ 'thread'
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
  elseif a:target =~ 'threadlist'
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
    if a:1 =~ 'anony'
      let username = g:chalice_anonyname
      let usermail = ''
    endif
    if a:1 =~ 'sage'
      let usermail = 'sage'
    endif
    if a:1 =~ 'new'
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
  if s:DoesFlagHaveTarget(a:flag, '\cclosing')
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
  let force_close = s:DoesFlagHaveTarget(a:flag, '\cclosing')
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
  " 半角スペースを&nbsp;に置換
  let message = substitute(message, ' ', '\&nbsp;', 'g')

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
  if s:user_agent_enable
    let opts = opts . ' -A ' .fq. s:user_agent .fq
  endif
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
" FILENAMES
" ファイル名の生成

function! s:GenerateLocalDat(host, board, dat)
  return s:dir_cache . 'dat_' . a:host . substitute(a:board, '/', '_', 'g') . '_' . substitute(a:dat, '\.dat$', '', '')
endfunction

function! s:GenerateLocalSubject(host, board)
  return s:dir_cache . 'subject_' . a:host . substitute(a:board, '/', '_', 'g')
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
  if b:host == '' || b:board == ''
    return
  endif

  let i = a:startline
  let lastline = a:endline ? a:endline : line('$')
  if s:debug | let @a = 'i='.i.' lastline='.lastline | endif

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
  " スレデータ(.dat)ではない行を削除
  silent! execute '%g!/^\d\+\.dat/delete _'
  " .dat名を隠蔽
  silent! execute '%s/^\(\d\+\.dat\)<>\(.*\)$/  \2\t\t\t\t\1'
  " 特殊文字潰し
  silent! execute '%s/&amp;/\&/g'
  silent! execute '%s/&gt;/>/g'
  silent! execute '%s/&lt;/</g'

  if g:chalice_threadinfo
    call s:FormatThreadInfo(1, 0)
  endif
endfunction

function! s:FormatThread()
  " 待ってね☆メッセージ
  call s:EchoH('WarningMsg', s:msg_wait_threadformat)
  let max = 7
  if g:chalice_verbose > 0 | call s:EchoH('WarningMsg', '0/'.max) | endif

  " 各書き込みに番号を振る
  let i = 1
  let endline = line('$')
  while i <= endline
    call setline(i, i . '<>' . getline(i))
    let i = i + 1
  endwhile
  if g:chalice_verbose > 0 | call s:EchoH('WarningMsg', '1/'.max."\n") | endif

  " 書き込み時情報の切り分け
  "   スレのdatのフォーマットは、直前に行頭に行(記事)番号を付けているので:
  "	番号<>名前<>メール<>時間<>本文<>スレ名
  "   となる。スレ名は先頭のみ
  if 1
    " \{-}の使用でかなり速くなっていると思われるが…リファレンスコードも残す
    let m1 = '\s*\(.\{-}\)\s*<>' " \{-}は最短マッチ
    let mx = '^' .m1.m1.m1.m1.m1. '\s*\(.*\)$'
  else
    " 遅いがスタックエラーでは落ちない
    let mx = '^\(\d\+\)<>\(.*\)<>\(.*\)<>\(.*\)<>\(.*\)<>\(.*\)$'
  endif
  let out = '\r--------\r\1  From:\2  Date:\4  Mail:\3\r  \5'
  "silent! execute '%s/\s*<>\s*/<>/g'
  if g:chalice_verbose > 0 | call s:EchoH('WarningMsg', '2/'.max."\n") | endif
  silent! execute '%s/' . mx . '/' . out
  if g:chalice_verbose > 0 | call s:EchoH('WarningMsg', '3/'.max."\n") | endif
  " 本文の改行処理
  silent! execute '%s/\s*<br>\s*/\r  /g'
  if g:chalice_verbose > 0 | call s:EchoH('WarningMsg', '4/'.max."\n") | endif

  " <A>タグ消し
  silent! execute '%s/<\/\?a[^>]*>//g'
  if g:chalice_verbose > 0 | call s:EchoH('WarningMsg', '5/'.max."\n") | endif
  " 個人キャップの<b>タグ消し
  silent! execute '%s/\s*<\/\?b>//g'
  if g:chalice_verbose > 0 | call s:EchoH('WarningMsg', '6/'.max."\n") | endif
  " 特殊文字潰し
  silent! execute '%s/&gt;/>/g'
  silent! execute '%s/&lt;/</g'
  silent! execute '%s/&quot;/"/g'
  silent! execute '%s/&nbsp;/ /g'
  silent! execute '%s/&amp;/\&/g'
  if g:chalice_verbose > 0 | call s:EchoH('WarningMsg', '7/'.max."\n") | endif

  " ゴミ行消去
  normal! gg"_dd
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
endfunction

function! s:CommandUnregister()
  delcommand ChaliceQuit
  delcommand ChaliceQuitAll
  delcommand ChaliceGoBoardList
  delcommand ChaliceGoThreadList
  delcommand ChaliceGoThread
  delcommand ChaliceGoArticle
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
  delcommand ChaliceDeleteThreadDat
endfunction
