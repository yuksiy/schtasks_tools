@echo off

rem ==============================================================================
rem   �@�\
rem     schtasks �̊e��o�͌��ʃt�@�C���̈ꊇ����
rem   �\��
rem     schtasks_main.bat [out_file_prefix]
rem
rem   Copyright (c) 2010-2017 Yukio Shiiya
rem
rem   This software is released under the MIT License.
rem   https://opensource.org/licenses/MIT
rem ==============================================================================

rem **********************************************************************
rem * ��{�ݒ�
rem **********************************************************************
rem ���ϐ��̃��[�J���C�Y�J�n
setlocal

rem �x�����ϐ��W�J�̗L����
verify other 2>nul
setlocal enabledelayedexpansion
if errorlevel 1 (
	echo -E Unable to enable delayedexpansion 1>&2
	exit /b 1
)

rem �E�B���h�E�^�C�g���̐ݒ�
title %~nx0 %*

for /f "tokens=1" %%i in ('echo %~f0') do set SCRIPT_FULL_NAME=%%i
for /f "tokens=1" %%i in ('echo %~dp0') do set SCRIPT_ROOT=%%i
for /f "tokens=1" %%i in ('echo %~nx0') do set SCRIPT_NAME=%%i
set RAND=%RANDOM%

rem **********************************************************************
rem * �ϐ���`
rem **********************************************************************
rem ���[�U�ϐ�
set XML_FILE=schtasks-one.xml
set TSV_FILE=schtasks-one.tsv
set TSV_FILE_WK=schtasks-one.tsv.wk

rem �V�X�e���� �ˑ��ϐ�
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

rem �v���O���������ϐ�
rem set DEBUG=TRUE

rem **********************************************************************
rem * ���C�����[�`��
rem **********************************************************************

rem ��1�����̃`�F�b�N
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

