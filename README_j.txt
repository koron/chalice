Chalice ～2ちゃんねる閲覧プラグイン for Vim～ 取扱説明書
                                                            Since: 16-Nov-2001
                                                                  Version: 1.2
                                                 Author: MURAOKA Taoro (KoRoN)
                                                     Last Change: 11-Mar-2002.

説明
  Vim上で2ちゃんねるの掲示板を閲覧するためのプラグインです。Vimさえ動くのであ
  ればどのOSでも同じように操作することができます。スレッドを立てることはできま
  せん。
  # Chaliceは「片手でキーボードのみで使える」ことを基本設計方針にしています。
  # (2.0系はこの原則も見直すつもりなので削除予定)

  # 以下の文中ではVim,vim,gvim等など、幾つか違った表記が現れますがどれも同じ
  # Vimとして考えてください。
  
  ChaliceはcURLを使用してスレデータを取得しています。cURLを持ってない方は別途
  入手してください。Windowsでは下記のcurl.exeバイナリをダウンロードします。
  UNIXではソースを持ってきてコンパイル・インストールしてください。Mac OS Xでは
  最初からインストールされています(10.1以降)。

  UNIXで使用するにはvimを+iconvでコンパイルしておく必要があります。またiconvだ
  けでは文字コード変換に対応しきれないため、別途に文字コード変換外部プログラム
  qkcかnkfが必要となります。特に変換精度の良さからqkcを推奨します。下記のサイ
  トよりソースをダウンロードしてインストールしてください。

  - curl.exe
    http://www.kaoriya.net/dist/curl-7.9.1-w32.tar.bz2

  - cURLのサイト(ソース他)
    http://curl.sourceforge.net/

  - qkcのサイト(ソース)
    http://hp.vector.co.jp/authors/VA000501/index.html

インストール
  (Windows お手軽インストール)
    解凍してでてきたディレクトリ chalice-{バージョン名} を vimfiles に変更し、
    curl.exeと一緒にgvim.exeと同じディレクトリへコピーする。このとき既に同名の
    ファイル・ディレクトリが存在する場合には上書きしてしまってよい。あとはVim
    起動後に
      :Chalice
    とタイプすればプラグインが起動する。インストールは簡単だけどアンインストー
    ルが面倒になる、諸刃の剣。

  (Windows 普通のインストール)
    1. 解凍して出来たディレクトリを適当な場所に置きます。
       ここでは説明のために chalice-{バージョン名} というディレクトリをchalice
       に変更し、gvim.exeと同じディレクトリに置いたとします。
    2. curl.exeを環境変数PATHのどこかにコピーしてください。
       よくわからない場合はgvim.exeと同じディレクトリで良いです。
    3. vimを起動して次のようにタイプします。
       :set runtimepath+=$VIM/chalice
       :runtime plugin/chalice.vim
       :Chalice
    4. 必要ならば個人設定ファイル _vimrc に
         set runtimepath+=$VIM/chalice
       と記述しておけばVimを起動した後
         :Chalice
       とタイプするだけでプラグインが起動します。

  (UNIXお手軽インストール)
    インストールスクリプトを作成しました。以下のようにインストール可能です。
      > su ; sh ./install.sh
    $VIMRUNTIMEらしいところにvimfilesを作って必要なファイルをコピーしているだ
    けです。その他にcURLとqkcもしくはnkfのインストールを忘れないで下さい。

  (UNIX手動インストール)
    基本的に(Windows 普通のインストール)と同じ方法でインストールが可能です。た
    だしcURLのインストールと、及びqkcもしくはnkf(qkc推奨)のインストールを忘れ
    ないで下さい。

  (Mac OS X お手軽インストール)
    解凍してでてきたディレクトリ chalice-{バージョン名} を vimfiles に変更し、
    Vim実行ファイルのあるディレクトリにコピーする。このとき既に同名のディレク
    トリが存在する場合には上書きしてしまってよい。あとはVim起動後に
      :Chalice
    とタイプすればプラグインが起動する。インストールは簡単だけどアンインストー
    ルが面倒になる、諸刃の剣。

  (Mac OS X 普通のインストール)
    1. 解凍して出来たディレクトリを適当な場所に置く
       ここでは説明のために chalice-{バージョン名} というディレクトリをchalice
       に変更し、Vimのアイコンと同じディレクトリに置いたとします。
    2. Chaliceを実行する
       vimを起動して次のコマンドをタイプするとChaliceが起動します。
       :set runtimepath+=$VIM/chalice
       :runtime plugin/chalice.vim
       :Chalice
    3. (必要ならば)簡単に起動できるようにする
       個人設定ファイル $VIM/_vimrc に
         set runtimepath+=$VIM/chalice
       と記述しておけばVimを起動した後
         :Chalice
       とタイプするだけでプラグインが起動します。

操作法
  - (起動方法)  :Chalice

  閲覧系バッファ
  - (全共通)    q       Chaliceを終了
  - (全共通)    Q       Vimもすべて終了
  - (全共通)    R       現在のバッファをリロード
  - (全共通)    <C-Tab> バッファ間移動(<S-Tab>で逆順)
  - (全共通)    <BS>    板一覧へ移動
  - (全共通)    u       スレ一覧(栞)へ移動
  - (全共通)    U       スレ一覧(栞)へ移動(+栞の起動トグル)
  - (全共通)    m       スレッドへ移動
  - (全共通)    M       スレッドへ移動(+栞の起動トグル)
  - (全共通)    <C-A>   スレの栞(ブックマーク)の起動・終了トグル
  - (全共通)    <Space> 1画面スクロールダウン(<S-Space>及びpでアップ)
  - (全共通)    <C-N>   クリップボードのURLをChaliceで開く

  - (板一覧)    j,k     カテゴリ・板の選択(カーソル移動による)
  - (板一覧)    h,l     カテゴリfoldを閉じる(h)・開く(l)
  - (板一覧)    <CR>    カテゴリfoldの開閉・閲覧する板の決定
  - (板一覧)    <S-CR>  板を外部ブラウザで開く

  - (スレ一覧)  j,k     スレを選択(カーソル移動による)
  - (スレ一覧)  d       スレのキャッシュdatを(存在すれば)削除
  - (スレ一覧)  <CR>    閲覧するスレの決定(<C-CR>で先頭から)
  - (スレ一覧)  <S-CR>  スレを外部ブラウザで開く
  - (スレ一覧)  ~       カーソル行のスレを栞に登録

  - (スレッド)  j,k     カーソル上下移動
  - (スレッド)  h,l     カーソル上下移動
  - (スレッド)  J,K     1行スクロールダウン/アップ
  - (スレッド)  p       1画面スクロールアップ
  - (スレッド)  <,>     前/次の記事へ移動(, と .も同じ意味)
  - (スレッド)  <CR>    カーソル行の記事/URLを開く(Chalice優先)
  - (スレッド)  <S-CR>  カーソル行の記事/URLを外部ブラウザで開く
  - (スレッド)  <C-O>   <CR>ジャンプを遡る(<C-I>で順方向ジャンプ)
  - (スレッド)  r       現在のスレを更新(差分更新のため高速:推奨)
  - (スレッド)  ~       閲覧中のスレをスレの栞に登録

  - (スレの栞)  j,k     カーソル上下移動
  - (スレの栞)  h,l     カテゴリfoldを閉じる(h)・開く(l)
  - (スレの栞)  <CR>    カテゴリfold開閉・閲覧するスレの決定

  スレ一覧では一度でも読んだことのある(ローカルにdatファイルが存在する)スレに
  印が付きます。印には ! と + の2種類があり、! は過去chalice_threadinfo_expire
  秒以内にローカルのdatファイルが更新されたものを、+ は更新されていないものを
  意味します。

  スレの栞はテキストファイルのように編集可能です。カテゴリを作成するには先頭が
  「■」で始まる行を書き、カテゴリ名とします。インデントの深さによりカテゴリを
  階層化することが出来ます。インデントによりカテゴリ名の存在しないfoldが作られ
  ることもあり、わかりにくくなるので気をつけてください。栞の内容は閉じるたびに
  自動的にファイルへ保存されます。保存ファイル名を知るには次のコマンドを使って
  ください。
        :echo chalice_bookmark

  書き込み系バッファ
  - (書き込み)  i,I     書き込みモードへ(Iはsage/o,Oも同じ意味)
  - (書き込み)  a,A     匿名書き込みモードへ(Aはsage)
  - (書き込み)  <C-CR>  書き込み実行

  書込む内容に不備がなければ直前に書込むかどうか最後の確認を求められる。本当に
  書込んでよければ yes とタイプ。no とタイプした時には書き込みは行なわれずバッ
  ファの内容が失われる。書き込みを中断するには cancel (デフォルト)。

  知って得する基本操作
  - (folding)   zr      全fold展開
  - (folding)   zm      全fold閉鎖

便利な設定・裏技 (+ は1.0以降に追加/変更のあった項目)
  ゆかいな設定変数たち
  - chalice_username                    書き込み時に自動入力するユーザ名
    例:   let chalice_username = 'KoRoN@Vim%Chalice'

  - chalice_anonyname                   匿名書き込み時に自動入力するユーザ名
    例:   let chalice_anonyname = '名無しさん@Vim%Chalice'

  - chalice_usermail                    書き込み時に自動入力するメールアドレス
    例:   let chalice_usermail = 'koron@tka.att.ne.jp'

  - chalice_columns                     Chalice起動時の'columns'を設定
    例:   let chalice_columns = 160
    (解説)Chalice起動時に'columns'を160に設定する。

  - chalice_bookmark                    ブックマークファイルを記憶
    例:   echo chalice_bookmark
    (解説)ブックマークファイル名を確認する。
    例:   let chalice_bookmark = $HOME . '/.chalice_bmk'
    (解説)ブックマークファイルを指定する。

  - chalice_cachedir                    キャッシュ用ディレクトリを指定
    例:   let chalice_cachedir = 'd:/home/vimfiles/chalice_cache'
    (解説)ダウンロード済みdat等を格納するディレクトリを指定する。

  - chalice_jumpmax                     ジャンプ履歴の最大サイズ(省略値:100)
    例:   let chalice_jumpmax = 1000

  - chalice_curl_options                cURLに渡すオプション
    例:   let chalice_curl_options = '-x {host}:{port}'
    (解説)プロキシの設定をする(詳細はcURLの文章を参照)。

  - chalice_exbrowser                   外部ブラウザを指定(非Windowsのみ)
    例:   let chalice_exbrowser = 'netscape %URL% &'
    (解説)文字列中の %URL% はURLに置き換えられる。

  - chalice_reloadinterval_boardlist    板一覧のリロード間隔(秒)
    例:   let chalice_reloadinterval_boardlist = 604800

  - chalice_reloadinterval_threadlist   スレ一覧のリロード間隔(秒)
    例:   let chalice_reloadinterval_threadlist = 0
    (解説)スレ一覧の取得間隔を0秒(常に更新)にする。

  - chalice_threadinfo		        鮮度表示機能フラグ
    例:   let chalice_threadinfo = 0
    (解説)スレのdatファイルの存在・更新状況の表示機能を無効にする。

  - chalice_threadinfo_expire		鮮度保持期間(秒)
    例:   let chalice_threadinfo_expire = 7200
    (解説)既読かつ2時間以上更新されていないスレを強調表示する。

  - chalice_gzip                        gzip圧縮の有無効フラグ
    例:   let chalice_gzip = 0
    (解説)gzip圧縮転送機能がエラーを起こす際に0を設定し、これを無効とする。

  - chalice_multiuser                   マルチユーザモード(UNIXはデフォルト)
    例:   let chalice_multiuser = 1

  - chalice_verbose                     動作情報の報告レベル(デバッグ用)
    例:   let chalice_verbose = 1
    (解説)1以上に設定すると外部コマンドの実行状況を観察できる。

  裏とは言えない技
  - 'I'で書き込みモードに入るとchalice_usermailに関わらず"sage"に
  - 'a'で書き込みモードに入るとchalice_usernameに関わらず「名無し」に
  - 'A'で書き込みモードに入ると強制的に「名無し」「sage」に
  - 実は"y"だけでも書き込める
  - :ChaliceJumplistでジャンプの履歴を参照可
  - :ChaliceGoArticle 番号で指定された記事番号へジャンプ

問題点
  解決する意思はある(上にあるものほど優先順位が高いかも)
  - URL中のlによる部分的な表示に未対応
  - 古い書き込みのfolding等ができない…仕様が固まればやる

  こっちは仕様(仕方ないとか、要らないとか)
  - 古い形式(read.cgi?bbs=...)は未サポート
  - 9xでのブラウザ起動は動作チェックしていない(誰か使ってくれてるよね?)
  - UNIXで「◆Vim6 2」だけを栞登録すると化ける←文字コード上致し方なし
  - UNIXからの書き込みにはiconvが必要→無いと化ける。
  - あぼ～ん対策が弱い→<C-R>の強制リロードで対応可能
  - スレッドを建てられない…というよりもプロトコルが一定でないので保留
  - AAがズレる

使用許諾・免責
  Vimを使って2chを見たいという欲求が強い人しか使ってはいけません。というより使
  わないハズです。改良案がある人は遠慮しないで連絡してください。特にパッチは大
  歓迎です。要望だけだと必ずしも満たすことは保証できかねます。

  このソフトウェアを使用したことへの対価は要求しません。このソフトウェアを使用
  したために生じた損害については一切補償いたしません。著作権は放棄しません。転
  載・再配布の際は事後で構わないので連絡をください。

質問・連絡先
  Vim掲示板・もしくはメールでお願いします。

  - Vim掲示板
    http://www.kaoriya.net/bbs/bbs.cgi

  - 村岡のemailアドレス
    koron@tka.att.ne.jp

  - 2ch/ソフトウェア板/2ch閲覧プラグイン～Chalice fro Vim
    http://pc.2ch.net/test/read.cgi/software/1006852780/l50
  - 2ch/Unix板/◆Vim6 2
    http://pc.2ch.net/test/read.cgi/unix/1006246205/l50

謝辞
  - Chalice/vim6スレの住人さん達
  - ハートに火を点けてくれた「まっつん」こと松本さん
  - そしてVimの作者Bram Moolenaar氏
  以上の方々に感謝。

更新履歴
  ● 11-Mar-2002 (1.2)
    正式版リリース
  ● 07-Mar-2002 (1.2f-beta)
    ブックマーク起動後のフォーカスがスレッドに行くバグを修正
  ● 06-Mar-2002 (1.2e-beta)
    書き込み時に半角スペースを&nbsp;に置換
    'isk'を変更した副作用で各オプションが無効になるバグを修正
  ● 06-Mar-2002 (1.2d-beta)
    "&amp;"から"&"へ変換する順番を最後に変更
    カーソル位置で1行内複数リンクのどれにジャンプするか選択可能に
  ● 05-Mar-2002 (1.2c-beta)
    'wildignore'対策を追加
    'splitbelow'及び'splitright'対策を追加
    板一覧のURLをhttp://www.2ch.net/2ch.htmlの<frame>タグから取得
    cacheディレクトリを任意に設定可能に
    2chメニューが頻繁に変更(要改良)
    非Win32での外部コマンドによるURL解釈時に"~"をエスケープ
    ファイル名の生成関数の宣言をfunction!に変更
    板一覧のURL変更
  ● 07-Feb-2002 (1.2b-beta)
    スレのフォーマットを少し高速化
    verbose設定にスレのフォーマット時にプログレス表示
    URLパターンに"@"を追加
    URLを開いた時に自動的にクリップボードへURLをコピー
    URLパターンに"!"を追加
    auth2chの実装(今は使えない)
  ● 19-Jan-2002 (1.2a-beta)
    dat直読み禁止への暫定対応
    dat直読みが禁止される問題への対応開始
    ばたーへのリンク埋め込み
    HTMLのマッチパターン修正
    多階層栞の実装
    スレのフォーマット方法を高速化(\{-}を使用)

後記
  Chaliceは「チャリス」と発音します。辞書をひけば「杯・聖杯」という意味になり
  ます。開発コードを「Alice」にしたかったという単純な動機から、ちょっとヒネろ
  うかと/\caliceで辞書を検索したところ、今の名前がひっかかりました。2chのブラ
  ウザということもあり、語呂も良さそうなのでChaliceに決定しました。そんな経緯
  の名前なので「ちゃんねるアリス」とか「アリスちゃん」とか、呼びやすい名前で呼
  んでもらっても結構です。もっと良い名前があったら変えちゃうかもしれません。

-------------------------------------------------------------------------------
                  生きる事への強い意志が同時に自分と異なる生命をも尊ぶ心となる
                                   MURAOKA Taro/村岡太郎 <koron@tka.att.ne.jp>
 vim:set ts=8 sts=2 sw=2 tw=78 et ft=memo:
