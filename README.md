# schtasks_tools

## 概要

Windows Task Scheduler の補足ツール

このパッケージは、Windows Task Scheduler の標準コマンドラインツールである
「schtasks」で不足している機能を補足するツールを提供します。

## 使用方法

### schtasks.xsl

schtasks の出力結果XMLファイルをTSVファイルに変換します。  
(TSV形式とは[CSV形式](https://ja.wikipedia.org/wiki/Comma-Separated_Values)
の類似フォーマットであり、一般のテキストエディタで開くことができます。)

    「Cygwin」を「管理者として実行」します。

    このツールで使用可能な入力ファイルを作成します。
    # echo ^<?xml version="1.0" encoding="UTF-8"?^>>                   schtasks-one.xml
    # dos2unix                                                         schtasks-one.xml
    # schtasks /query /xml one | dos2unix | iconv -f CP932 -t UTF-8 >> schtasks-one.xml

    上記で作成した入力ファイルをフォーマット変換します。
    # msxsl schtasks-one.xml 本パッケージのインストールディレクトリ/schtasks.xsl -o schtasks-one.tsv

### schtasks_postproc_new.pl

schtasks.xsl の変換結果TSVファイルの後処理をします。

    「Cygwin」を「管理者として実行」します。

    # schtasks_postproc.pl schtasks-one.tsv

### schtasks_main.bat

schtasks の各種出力結果ファイルを一括生成します。

手順例:

schtasks の各種出力結果ファイルを出力先ディレクトリ(DEST_DIR)配下に
「schtasks-one」で始まるファイル名で一括生成する場合:

    「コマンド プロンプト」を「管理者として実行」します。

    mkdir DEST_DIR
    schtasks_main.bat DEST_DIR\schtasks-one

* 出力先ディレクトリに一括生成されるファイルの実例等に関しては、
  [examples ディレクトリ](https://github.com/yuksiy/schtasks_tools/tree/master/examples)
  を参照してください。

## 動作環境

OS:

* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* perl
* [Win32-API](http://search.cpan.org/dist/Win32-API/)
* [common_pl](https://github.com/yuksiy/common_pl)
* dos2unix
* [msxsl](https://github.com/yuksiy/schtasks_tools/blob/master/README_msxsl.md)
* [PsGetsid](https://github.com/yuksiy/schtasks_tools/blob/master/README_psgetsid.md)

## インストール

ソースからインストールする場合:

    (Cygwin の場合)
    # make install

fil_pkg.plを使用してインストールする場合:

[fil_pkg.pl](https://github.com/yuksiy/fil_tools_pl/blob/master/README.md#fil_pkgpl) を参照してください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/schtasks_tools>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/schtasks_tools/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2010-2017 Yukio Shiiya
