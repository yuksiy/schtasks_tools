# PsGetsid

## 最新版の入手先

<https://technet.microsoft.com/en-us/sysinternals/bb896649.aspx>

## インストール

1. 入手先から「PSTools.zip」ファイルをダウンロードしてください。

2. ダウンロードしたファイルから「PsGetsid.exe」ファイルを展開してください。

3. 展開したファイルをパスの通った任意ディレクトリにコピーしてください。

4. 「コマンド プロンプト」を「管理者として実行」します。

5. 以下のコマンドを実行してください。  
   PsGetsid.exe  
   上記の初回実行時のみ「PsGetSid License Agreement」が表示されるので、
   内容を確認し、同意する場合は「Agree」ボタンをクリックしてください。

6. もう一度、以下のコマンドを実行してください。  
   PsGetsid.exe  
   今度は「PsGetSid License Agreement」が表示されずに、
   画面出力の最下部に以下のように表示されることを確認してください。  
   SID for \\ホスト名:  
   S-で始まる任意文字列
