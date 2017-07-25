@echo off

rem ==============================================================================
rem   機能
rem     schtasks の各種出力結果ファイルの一括生成
rem   構文
rem     schtasks_main.bat [out_file_prefix]
rem
rem   Copyright (c) 2010-2017 Yukio Shiiya
rem
rem   This software is released under the MIT License.
rem   https://opensource.org/licenses/MIT
rem ==============================================================================

rem **********************************************************************
rem * 基本設定
rem **********************************************************************
rem 環境変数のローカライズ開始
setlocal

rem 遅延環境変数展開の有効化
verify other 2>nul
setlocal enabledelayedexpansion
if errorlevel 1 (
	echo -E Unable to enable delayedexpansion 1>&2
	exit /b 1
)

rem ウィンドウタイトルの設定
title %~nx0 %*

for /f "tokens=1" %%i in ('echo %~f0') do set SCRIPT_FULL_NAME=%%i
for /f "tokens=1" %%i in ('echo %~dp0') do set SCRIPT_ROOT=%%i
for /f "tokens=1" %%i in ('echo %~nx0') do set SCRIPT_NAME=%%i
set RAND=%RANDOM%

rem **********************************************************************
rem * 変数定義
rem **********************************************************************
rem ユーザ変数
set XML_FILE=schtasks-one.xml
set TSV_FILE=schtasks-one.tsv
set TSV_FILE_WK=schtasks-one.tsv.wk

rem システム環境 依存変数
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set CYGWINROOT=%SystemDrive%\cygwin64
) else (
	set CYGWINROOT=%SystemDrive%\cygwin
)
set PATH=%PATH%;%CYGWINROOT%\bin
set CYGWIN=nodosfilewarning
rem set LANG=ja_JP.UTF-8

set PERL=%CYGWINROOT%\bin\perl.exe
set PERL5LIB=/usr/local/lib/site_perl

set XSL_FILE=%SCRIPT_ROOT%\schtasks.xsl
set SCHTASKS_POSTPROC=%SCRIPT_ROOT%\schtasks_postproc.pl

rem プログラム内部変数
rem set DEBUG=TRUE

rem **********************************************************************
rem * メインルーチン
rem **********************************************************************

rem 第1引数のチェック
if not "%~1"=="" (
	set out_file_prefix=%~1
	set XML_FILE=!out_file_prefix!.xml
	set TSV_FILE=!out_file_prefix!.tsv
	set TSV_FILE_WK=!out_file_prefix!.tsv.wk
)

echo ^<?xml version="1.0" encoding="UTF-8"?^>>                   "%XML_FILE%"
dos2unix                                                         "%XML_FILE%" 2> nul
schtasks /query /xml one | dos2unix | iconv -f CP932 -t UTF-8 >> "%XML_FILE%"
msxsl "%XML_FILE%" "%XSL_FILE%" -o "%TSV_FILE_WK%"
dos2unix                           "%TSV_FILE_WK%" 2> nul
%PERL% "%SCHTASKS_POSTPROC%" "%TSV_FILE_WK%" > "%TSV_FILE%"
del /f "%TSV_FILE_WK%"
goto :EOF

