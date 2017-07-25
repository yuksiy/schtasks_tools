# examples

## 「default.win10home」ディレクトリ

Windows 10 Home が新規インストールされたばかりの初期に近い状態で、
[schtasks_main.bat](https://github.com/yuksiy/schtasks_tools/blob/master/README.md#schtasks_mainbat)
を実行することにより一括生成されたファイル、およびその派生ファイルを格納しています。  
(ユーザー情報などの内部情報は「*」文字で置き換えています。)

## 「default.win10home/output」ディレクトリ

* schtasks-one.xml  
  スケジューラのタスク一覧。

* schtasks-one.tsv  
  スケジューラのタスク一覧を設定書向けのTSV形式に変換した出力結果ファイル。  
  上記のTSVファイルを一般のテキストエディタで開き、
  表計算ソフトにコピー・アンド・ペーストし、書式を整えることによって、
  スケジューラの設定書として使用することができます。

## 「default.win10home/spreadsheet」ディレクトリ

* scheduled-task.ods  
  上記で生成された「schtasks-one.tsv」ファイルを
  表計算ソフトにコピー・アンド・ペーストし、簡単に書式を整えた
  「スケジューラ タスク設定書」の一例です。
