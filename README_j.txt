Chalice ～2ちゃんねる閲覧プラグイン for Vim～ 取扱説明書
                                                            Since: 16-Nov-2001
                                                                  Version: 1.3
                                                 Author: MURAOKA Taoro (KoRoN)
                                                     Last Change: 22-Apr-2002.

概要
  Vim上で2ちゃんねるの掲示板を閲覧するためのプラグインです。Vimさえ動くのであ
  ればどのOSでも同じように操作することができます。スレッドを立てることはできま
  せん。一部2ちゃんねる以外の掲示板を閲覧することが可能な場合もありますが、必
  ずしも読み書きできるとは期待しないでください。また特定の掲示板への対応を要望
  されても通常は対応いたしかねます。

  # 以下の文中ではVim,vim,gvim等など、幾つか違った表記が現れますがどれも同じ
  # Vimとして考えてください。
  
必要要件
  Chaliceを利用するには以下のものが必要になります。1つでも欠けると利用出来ませ
  んので予め入手しインストールしておいてください。
    1. vim      (テキストエディタ 6.0以降6.1推奨)
    2. cURL     (HTTPアクセスソフトウェア 7.9.4以降SSL推奨)
    3. gzip     (圧縮復号ソフト)
  これらに加えてをWindowsで2ちゃんねる以外の掲示板を閲覧する場合には、別途ソフ
  トウェア(4)が必要になる場合があります。
    4. iconv.dll
  UNIXではvimを+iconvでコンパイルするほか次のソフトウェアが必要になります。
    5. qkcかnkf (文字コード変換ソフトウェア qkc推奨)
  各必須ソフトウェアの入手法は以下を参考にしてください。

  (vimの入手) 特に解説すべきことはありません。http://www.vim.org/参照

  (cURLの入手) Chaliceは2ちゃんねるの閲覧と書込みにcURLという外部プログラムを
  使用しています。2ちゃんねるへ正しく書込むにはcURLのcookieという仕組みを利用
  する必要があります。ところがcURLの7.9.4より古いバージョンにはこのcookieを利
  用する際の不具合が知られています。そのためこの不具合が修正された最新版(7.9.4
  以降)が必要です。Windows用のcURLは以下のアドレスのものを使用してください。
  UNIXではcURLのサイトより最新のソースコードをダウンロード&コンパイルして使用
  してください。MacOS Xには元から古いcURLがインストールされていますので、利用
  するには別途cURLを入手する必要があります。

  - Windows用 cURL (香り屋配布版)
    http://www.kaoriya.net/dist/curl-7.9.6-win32-ssl.tar.bz2

  - cURLオフィシャルサイト (ソースコード他)
    http://curl.sourceforge.net/
  
  - MacOS X用 cURL情報 (.pkg/日本語)
    http://www.cosmos.ne.jp/~kaz6120/mclb/osx/curl_wget01.html

  - MacOS X用 cURL情報 (Finkプロジェクト/英語)
    http://fink.sourceforge.net/index.php

  (gzipの入手) 2ちゃんねるは巨大な掲示板であり1日に多くの人が訪れるため、発生
  する膨大なアクセス量が少なからず運営の負担になっています。その負担を少しでも
  減らすため2ちゃんねるはデータを圧縮して送信しています。この圧縮されたデータ
  を読込むためにChaliceはgzipというソフトウェアを利用しています。gzipはUNIXと
  MacOS Xでは標準的にインストールされています。Windowsの場合は次のサイトから
  gzipを入手インストールするか、Cygwinを正しくインストールする必要があります。

  - gzip.org (gzip入手先)
    http://www.gzip.org/ Win用バイナリ http://www.gzip.org/gzip124xN.zip
  
  - Cygwin
    http://www.cygwin.com/

  (iconv) 文字コードを正しく扱うためにiconvというライブラリが必要です。Windows
  では下のURLから入手してください。UNIXでは+iconvでコンパイルする必要がありま
  す。MacOS Xは対応しています(予定)。

  - Windows用 iconv.dll (香り屋配布版)
    http://www.kaoriya.net/dist/iconv-1.7.1-dll.tar.bz2
  
  - iconvライブラリソースコード
    http://www.gnu.org/directory/libiconv.html

  (qkcの入手) UNIXのiconvではコード変換に対応しきれないため文字化けすることが
  あります。それに対応するために別途に文字コード変換外部プログラムqkcかnkfが必
  要となります。特に変換精度の良さからqkcを推奨します。下記のサイトよりソース
  をダウンロードしてインストールしてください。

  - qkcのサイト(ソース)
    http://hp.vector.co.jp/authors/VA000501/index.html

インストール
  ■ Windows
  (Windows お手軽インストール)
    解凍してでてきたディレクトリ chalice-{バージョン名} を vimfiles に変更し、
    curl.exeとgzip.exe一緒にgvim.exeと同じディレクトリへコピーします。このとき
    既に同名のファイル・ディレクトリが存在する場合には上書きしてしまって良いで
    す。あとはVim起動後に
      :Chalice
    とタイプすればプラグインが起動します。インストールは簡単だけどアンインス
    トールが面倒になる、諸刃の剣です。

  (Windows 普通のインストール)
    1. 解凍して出来たディレクトリを適当な場所に置きます。
       ここでは説明のために chalice-{バージョン名} というディレクトリをchalice
       に変更し、gvim.exeと同じディレクトリに置いたとします。
    2. curl.exeとgzip.exeをインストールします。
       インストールとは環境変数PATHで示されるディレクトリのどれかにコピーする
       ことです。よくわからない場合はgvim.exeがあるのと同じディレクトリで良い
       です。
    3. vimを起動して次のようにタイプします。
       :set runtimepath+=$VIM/chalice
       :runtime plugin/chalice.vim
       :Chalice
    4. 必要ならば個人設定ファイル _vimrc に
         set runtimepath+=$VIM/chalice
       と記述しておけばVimを起動した後
         :Chalice
       とタイプするだけでプラグインが起動します。

  ■ UNIX系
  (UNIXインストール時の注意)
    cURLとqkcもしくはnkf(qkc推奨)のインストールを忘れないでください。ftplugin
    を利用するので、これを有効にするのを忘れないでください。
      :filetype plugin on
    $VIMRUNTIME/vimrc_example.vimをsourceすれば自動的に有効化されます。

  (UNIXお手軽インストール)
    インストールスクリプトを作成しました。以下のようにインストール可能です。
      > su ; sh ./install.sh
    $VIMRUNTIMEらしいところにvimfilesを作って必要なファイルをコピーしているだ
    けです。

  (UNIX手動インストール)
    基本的に(Windows 普通のインストール)と同じ方法でインストールが可能です。

  ■ MacOS X
  (Mac OS X お手軽インストール)
    解凍してでてきたディレクトリ chalice-{バージョン名} を vimfiles に変更し、
    gvim実行ファイルと同じディレクトリへコピーします。このとき既に同名のファイ
    ル・ディレクトリが存在する場合には上書きしてしまって良いです。cURL(7.9.4以
    降)を正しくインストールします。あとはVim起動後に
      :Chalice
    とタイプすればプラグインが起動します。インストールは簡単だけどアンインス
    トールが面倒になる、諸刃の剣です。

  (Mac OS X 普通のインストール)
    1. 解凍して出来たディレクトリを適当な場所に置く
       ここでは説明のために chalice-{バージョン名} というディレクトリをchalice
       に変更し、Vimのアイコンと同じディレクトリに置いたとします。
    2. curlをインストールします。
       詳細はcURLの入手先に従ってください。
    3. Chaliceを実行する
       vimを起動して次のコマンドをタイプするとChaliceが起動します。
       :set runtimepath+=$VIM/chalice
       :runtime plugin/chalice.vim
       :Chalice
    4. (必要ならば)簡単に起動できるようにする
       個人設定ファイル $VIM/_vimrc に
         set runtimepath+=$VIM/chalice
       と記述しておけばVimを起動した後
         :Chalice
       とタイプするだけでプラグインが起動します。

起動方法・使い方・終了方法・ヘルプ
  Chaliceを起動するにはインストール後、Exモードコマンドで
    :Chalice
  を実行します。使用法はヘルプファイルに記載されています。正しくインストールが
  行なわれていれば、次のコマンドでヘルプを確認できます。チュートリアルもありま
  すので初めて使う人は必ず確認してください。
    :help Chalice
  q を押すとChaliceは終了します。わからないことがあった際には、まずヘルプファ
  イルをご覧ください。

使用許諾・免責
  Vimを使って2chを見たいという欲求が強い人しか使ってはいけません。というより使
  わないハズです。改良案がある人は遠慮しないで連絡してください。特にパッチは大
  歓迎です。要望だけだと必ずしも満たすことは保証できかねます。

  このソフトウェアを使用したことへの対価は要求しません。このソフトウェアを使用
  したために生じた損害については一切補償いたしません。著作権は放棄しません。転
  載・再配布の際は事後で構わないので連絡をください。

質問・連絡先
  2ちゃんねる、メール、もしくはVim掲示板でお願いします。

  - Vim掲示板
    http://www.kaoriya.net/bbs/bbs.cgi

  - 村岡のemailアドレス
    koron@tka.att.ne.jp

  - 2ch/ソフトウェア板/2ch閲覧プラグイン～Chalice for Vim
    http://pc.2ch.net/test/read.cgi/software/1006852780/l50
  - 2ch/Unix板/Vim6 Part3
    http://pc.2ch.net/test/read.cgi/unix/1019011083/l50

謝辞
  - Chalice/vim6スレの住人さん達
  - パッチをくれた皆さん
  - チュートリアル、カスタマイズ例、FAQを執筆してくれた◆PYOQ4sjoさん
  - ハートに火を点けてくれた「まっつん」こと松本さん
  - そしてVimの作者Bram Moolenaar氏
  以上の方々に感謝いたします。

更新履歴
  ● 22-Apr-2002 (1.3 正式版)
    起動法→終了までの流れを意識して修正
    ドキュメントtypo修正
    HelpInstall()のディレクトリバグを修正
  ● 20-Apr-2002 (1.3i-rc4)
    subject.txt.gzへのアクセスを中止(必要ないことが判明→コード封鎖)
    chalice_nosubject_gzを削除
    UNIX用インストールスクリプトを修正
    gzipが無いと起動しないように変更
    ヘルプファイルとヘルプのインストール機能を追加
    外部ブラウザによる参照URLの展開手順を修正(%の問題)
    noquery_quit=0の時には必ずquery_writeするように変更
  ● 18-Apr-2002 (1.3h-rc3)
    ドキュメントの説明を修正し必要要件を追加
    chalice_writeoptionsを導入
    書込みバッファでの二重引用を別の色で強調
    <C-C><CR>をgui_running以外でも使えるように変更(MacOS X対策)
    オン/オフラインモード切替時にメッセージでも表示
  ● 16-Apr-2002 (1.3g-rc2)
    実体参照をalice.vimへ実装
    書込み時に&を&amp;に置換
    クリップボードにいちいちURLを送るのを取りやめ
    書込みバッファの'bufhidden'設定を解除(Chalice使用時のcdによるエラーを回避)
    二重引用を別の色で強調
    非GUI時の<S-CR>と<C-CR>をそれぞれ<C-S><CR>と<C-C><CR>に変更
    書込みバッファでの<C-X>を無効にした
    dat取得済みのスレを一覧から栞へ登録できない問題修正
    栞への登録が無効になっていた問題を修正
    :Article {n}コマンド追加
  ● 14-Apr-2002 (1.3f-rc1)
    subject.txt.gzに対応(非公開変数chalice_nosubject_gzはchalice.vim参照)
    HttpDownload()がhttpリザルトステータスを帰すように改良
    http://無しのURL(www.kaoriya.netのような表記)を開けるように変更
    外部ブラウザで開く時のURLをAL_quote()するように変更
    一部の関数をaliceへ移動
    chalice_columnsが未設定の時、終了時に'columns'を復帰しないように変更
    /\?に表記を統一
    表記されたhttpsに対応
    一覧から栞へ直接登録ができない問題を修正
    'cmdheight' < 2で起動時に栞を起動するとメッセージがpauseする問題を修正
  ● 13-Apr-2002 (1.3e-beta)
    書込み中
    番号つき外部ブラウザを導入 chalice_exbrowser_{n}が{n}<S-CR>で起動する
    起動時の動作設定変数(chalice_startupflags)を追加
    起動時のスレの栞起動をサポート
    オフライン機能を追加
    もどき板ではスレの"＠｀"を","に置換するように変更
    スレ一覧で、レス数が右にずれていくバグを修正
  ● 12-Apr-2002 (1.3d-beta)
    書込みバッファにcommentsを設定
    chalice_statuslineにより項目を追加可能に改良
    スレの表示を高速化…したつもり
    subjectの&quot;に対応
    したらばのsubject/dat読み対応。
    euc-jpが文字化けすることありiconv治しますかぁ?
  ● 11-Apr-2002 (1.3c-beta)
    OpenThread()で生成されたURLをクリップボードへコピー
    高速URL Encoderの導入
    書込みバッファでの q, Q (Chalice終了)を無効化
  ● 10-Apr-2002 (1.3b-beta)
    板一覧の板名に空白を許すようにした
    書込み時の確認を省略する変数chalice_noquery_writeを導入
    hostの解釈法を変更。概念的にはbbsrootが正しい
    変数chalice_foldmarksを導入
    2ch_writeにformatoptions-=rを追加
    alice.vimに移行を開始
  ● 09-Apr-2002 (1.3a-beta)
    「もどき板」を閲覧できるようにしてみたり
    試験的にsubject.txtの解釈をフレキシブルにしてみる
    メニューのURLを標準以外に設定可能に(変数chalice_menu_url)
    書込み時にcookieを利用(変数chalice_curl_cookies = 0で無効化)
    板整形法を修正
    1.2.2がパッケージに反映されていなかった件を修正

後記
  Chaliceは「チャリス」と発音します。辞書をひけば「杯・聖杯」という意味になり
  ます。開発コードを「Alice」にしたかったという単純な動機から、ちょっとヒネろ
  うかと/\caliceで辞書を検索したところ、今の名前がひっかかりました。2chのブラ
  ウザということもあり、語呂も良さそうなのでChaliceに決定しました。そんな経緯
  の名前なので「ちゃんねるアリス」とか「アリスちゃん」とか、呼びやすい名前で呼
  んでもらって結構です。もっと良い名前があったら変えちゃうかもしれません。

-------------------------------------------------------------------------------
                  生きる事への強い意志が同時に自分と異なる生命をも尊ぶ心となる
                                   MURAOKA Taro/村岡太郎 <koron@tka.att.ne.jp>
 vim:set ts=8 sts=2 sw=2 tw=78 et ft=memo:
