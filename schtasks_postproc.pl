#!/usr/bin/perl

# ==============================================================================
#   機能
#     schtasks.xsl の変換結果TSVファイルの後処理をする
#   構文
#     USAGE 参照
#
#   Copyright (c) 2010-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
use strict;
use warnings;

use utf8;
binmode(STDOUT, ":encoding(utf8)");
binmode(STDERR, ":encoding(utf8)");

use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt no_ignore_case);
use Sys::Hostname;

my $s_err = "";
$SIG{__DIE__} = $SIG{__WARN__} = sub { $s_err = $_[0]; };

$SIG{WINCH} = "IGNORE";
$SIG{HUP} = $SIG{INT} = $SIG{TERM} = sub { POST_PROCESS();exit 1; };

######################################################################
# 変数定義
######################################################################
# ユーザ変数
my $host = hostname();

# プログラム内部変数
my $DEBUG = 0;
my $TSV_FILE = "";
my ($count, $line);
my ($name, $status, $desc, $account, $logontype);
my @rest;
my $tsv_file_start_row_num = 2;
my ($result, $result_sentinel);
my $desc_str;
my ($sid_str, $account_str);
my ($logontype_val, $logontype_str);
my $logontype_str_1 = "ﾕｰｻﾞｰがﾛｸﾞｵﾝしているときのみ実行する";
my $logontype_str_2 = "ﾕｰｻﾞｰがﾛｸﾞｵﾝしているかどうかにかかわらず実行する";
my $logontype_str_3 = "ﾕｰｻﾞｰがﾛｸﾞｵﾝしているかどうかにかかわらず実行する,ﾊﾟｽﾜｰﾄﾞを保存しない";
my @record;
my $field;

######################################################################
# サブルーチン定義
######################################################################
sub PRE_PROCESS {
}

sub POST_PROCESS {
}

sub USAGE {
	print STDOUT <<EOF;
Usage:
    schtasks_postproc.pl [OPTIONS ...] TSV_FILE

    TSV_FILE  : Specify a TSV file.

OPTIONS:
    --help
       Display this help and exit.
EOF
}

use Common_pl::Win32::API::Indirect_str_load;

######################################################################
# メインルーチン
######################################################################

# オプションのチェック
if ( not eval { GetOptionsFromArray( \@ARGV,
	"help" => sub {
		USAGE();exit 0;
	},
) } ) {
	print STDERR "-E $s_err\n";
	USAGE();exit 1;
}

# 第1引数のチェック
if ( not defined($ARGV[0]) ) {
	print STDERR "-E Missing TSV_FILE argument\n";
	USAGE();exit 1;
} else {
	$TSV_FILE = $ARGV[0];
	# TSVファイルのチェック
	if ( not -f "$TSV_FILE" ) {
		print STDERR "-E TSV_FILE not a file -- \"$TSV_FILE\"\n";
		USAGE();exit 1;
	}
}

# 作業開始前処理
PRE_PROCESS();

#####################
# メインループ 開始 #
#####################
if ( not defined(open(TSV_FILE, '<', "$TSV_FILE")) ) {
	print STDERR "-E TSV_FILE cannot open -- \"$TSV_FILE\": $!\n";
	POST_PROCESS();exit 1;
}
binmode(TSV_FILE, ":encoding(utf8)");
$count = 0;
while ($line = <TSV_FILE>) {
	$count = $count + 1;
	chomp $line;
	# 入力行の分割
	($name, $status, $desc, $account, $logontype, @rest) = split(/\t/, $line, -1);

	# 参照文字列の解決 (desc列)
	if ( ($count >= $tsv_file_start_row_num) and ($desc ne "") ) {
		$desc_str = $desc;
		$desc_str =~ s#^\$\(([^)]+)\)$#$1#;
		$desc_str = INDIRECT_STR_LOAD($desc_str);
		if ( $desc_str =~ m#^-E Load indirect string failed# ) {
			$desc_str = $desc;
		}
	} else {
		$desc_str = $desc;
	}

	# 参照文字列の解決 (account列)
	$result_sentinel = 0;
	$sid_str = "";
	$account_str = "";
	if ( ($count >= $tsv_file_start_row_num) and ($account ne "") ) {
		if ( not defined(open(COM, '-|', "PsGetsid.exe \"$account\" 2>&1")) ) {
			print STDERR "-E PsGetsid.exe cannot exec: $!\n";
			POST_PROCESS();exit 1;
		}
		binmode(COM, ":encoding(cp932):crlf");
		while ($result = <COM>) {
			chomp $result;
			if ( ($result =~ m#^Account for .*\Q$account\E:$#) or
				($result =~ m#^SID for .*\Q$account\E:$#) ) {
				$result_sentinel = 1;
				next;
			} else {
				if ($result_sentinel == 0) {
					next;
				} else {
					last;
				}
			}
		}
		close(COM);
		if ($account =~ m#^S(?:-[0-9]+){3,}$#) {
			$sid_str = $account;
			$account_str = $result;
			$account_str =~ s#^[^:]+: (.+)$#$1#;
			if ($account_str eq "") {
				$account_str = "-E cannot resolv -- " . $account;
			}
		} else {
			$sid_str = $result;
			$account_str = $account;
		}
	} else {
		$account_str = $account;
	}

	# 参照文字列の解決 (logontype列)
	$logontype_val = $logontype;
	$logontype_val =~ s#^LogonType=(.+)$#$1#;
	$logontype_str = "";
	# SIDが「NT Domain SID」の場合
	if ( ($count >= $tsv_file_start_row_num) and ($logontype ne "") ) {
		if ($sid_str =~ m#^S-1-5-21-#) {
			if ($logontype_val eq "InteractiveToken") {
				$logontype_str = $logontype_str_1;
			} elsif ($logontype_val eq "Password") {
				$logontype_str = $logontype_str_2;
			} elsif ($logontype_val eq "S4U") {
				$logontype_str = $logontype_str_3;
			} elsif ($logontype_val eq "なし") {
				$logontype_str = $logontype_str_1;
			} else {
				$logontype_str = $logontype . " " . $logontype;
			}
		# SIDが「NT AUTHORITY\{SYSTEM, LOCAL SERVICE, NETWORK SERVICE}」の場合
		} elsif ( ($sid_str =~ m#^S-1-5-18$#) or
			($sid_str =~ m#^S-1-5-19$#) or
			($sid_str =~ m#^S-1-5-20$#) ) {
			$logontype_str = $logontype_str_2;
		# SIDが上記以外の場合
		} else {
			$logontype_str = $logontype_str_1;
		}
	} else {
		$logontype_str = $logontype;
	}

	# 出力行の連結
	@record = ();
	foreach $field ($name, $status, $desc_str, $account_str, $logontype_str, @rest) {
		# フィールドに含まれるダブルクォートを2つ並べてエスケープ
		$field =~ s#"#""#g;
		# フィールドをダブルクォートで囲んで配列に追加
		push @record, '"' . $field . '"';
	}

	# 行の出力
	print join "\t", @record;
	print "\n";
}
close(TSV_FILE);
#####################
# メインループ 終了 #
#####################

