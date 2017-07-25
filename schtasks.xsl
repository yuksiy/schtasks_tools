<?xml version="1.0" encoding="UTF-8"?>

<!--
==============================================================================
  機能
    schtasks の出力結果XMLファイルをTSVファイルに変換する
  構文
    echo ^<?xml version="1.0" encoding="UTF-8"?^>>                   schtasks-one.xml
    dos2unix                                                         schtasks-one.xml
    schtasks /query /xml one | dos2unix | iconv -f CP932 -t UTF-8 >> schtasks-one.xml
    msxsl schtasks-one.xml schtasks.xsl -o schtasks-one.tsv

  Copyright (c) 2010-2017 Yukio Shiiya

  This software is released under the MIT License.
  https://opensource.org/licenses/MIT
==============================================================================
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:task="http://schemas.microsoft.com/windows/2004/02/mit/task">

	<xsl:output method="text" encoding="UTF-8" />

	<xsl:variable name="LowerCaseChars" select="abcdefghijklmnopqrstuvwxyz" />
	<xsl:variable name="UpperCaseChars" select="ABCDEFGHIJKLMNOPQRSTUVWXYZ" />

	<xsl:variable name="DEBUG" select="0" />

	<!-- 列のｽｷｯﾌﾟ (「状態」～「構成」) -->
	<!-- (TAB * 7) -->
	<xsl:variable name="SKIP_COLS_STATUS_CONFIG" select="'							'" />
	<!-- 列のｽｷｯﾌﾟ (「ﾄﾘｶﾞｰ」～「有効」) -->
	<!-- (TAB * 14) -->
	<xsl:variable name="SKIP_COLS_TRIGGER_ENABLE" select="'														'" />
	<!-- 列のｽｷｯﾌﾟ (「操作」～「操作」) -->
	<!-- (TAB * 1) -->
	<xsl:variable name="SKIP_COLS_ACTION_ACTION" select="'	'" />
	<!-- 列のｽｷｯﾌﾟ (「次の間ｱｲﾄﾞﾙ状態の場合のみﾀｽｸを開始する」～「ﾀｽｸが既に実行中の場合に適用される規則」) -->
	<!-- (TAB * 21) -->
	<xsl:variable name="SKIP_COLS_RUNONLYIFIDLE_MULTIPLEINSTANCESPOLICY" select="'																					'" />

	<xsl:template match="/">
		<!-- ﾍｯﾀﾞの出力 -->
		<xsl:text>場所\ﾀｽｸ名</xsl:text>
		<xsl:text>	状態</xsl:text>
		<!-- 全般 -->
		<xsl:text>	説明</xsl:text>
		<xsl:text>	ﾀｽｸの実行時に使うﾕｰｻﾞｰ ｱｶｳﾝﾄ</xsl:text>
		<!--
		<xsl:text>	(ｱｶｳﾝﾄ種別)</xsl:text>
		-->
		<xsl:text>	(実行種別)</xsl:text>
		<xsl:text>	最上位の特権で実行する</xsl:text>
		<xsl:text>	表示しない</xsl:text>
		<xsl:text>	構成</xsl:text>
		<!-- ﾄﾘｶﾞｰ -->
		<xsl:text>	ﾀｽｸの開始</xsl:text>
		<xsl:text>	遅延時間を指定する</xsl:text>
		<xsl:text>	遅延時間</xsl:text>
		<xsl:text>	繰り返し間隔</xsl:text>
		<xsl:text>	繰り返し間隔</xsl:text>
		<xsl:text>	継続時間</xsl:text>
		<xsl:text>	繰り返し継続時間の最後に実行中のすべてのﾀｽｸを停止する</xsl:text>
		<xsl:text>	停止するまでの時間</xsl:text>
		<xsl:text>	停止するまでの時間</xsl:text>
		<xsl:text>	開始/ｱｸﾃｨﾌﾞ化</xsl:text>
		<xsl:text>	開始/ｱｸﾃｨﾌﾞ化</xsl:text>
		<xsl:text>	有効期限</xsl:text>
		<xsl:text>	有効期限</xsl:text>
		<xsl:text>	有効</xsl:text>
		<!-- 操作 -->
		<xsl:text>	操作</xsl:text>
		<!-- 条件 -->
		<xsl:text>	次の間ｱｲﾄﾞﾙ状態の場合のみﾀｽｸを開始する</xsl:text>
		<xsl:text>	時間</xsl:text>
		<xsl:text>	ｱｲﾄﾞﾙ状態になるのを待機する時間</xsl:text>
		<xsl:text>	ｺﾝﾋﾟｭｰﾀがｱｲﾄﾞﾙ状態でなくなった場合は停止する</xsl:text>
		<xsl:text>	再びｱｲﾄﾞﾙ状態になったら再開する</xsl:text>
		<xsl:text>	ｺﾝﾋﾟｭｰﾀをAC電源で使用している場合のみﾀｽｸを開始する</xsl:text>
		<xsl:text>	ｺﾝﾋﾟｭｰﾀの電源をﾊﾞｯﾃﾘに切り替える場合は停止する</xsl:text>
		<xsl:text>	ﾀｽｸを実行するためにｽﾘｰﾌﾟを解除する</xsl:text>
		<xsl:text>	次のﾈｯﾄﾜｰｸ接続が使用可能な場合のみﾀｽｸを開始する</xsl:text>
		<xsl:text>	ﾈｯﾄﾜｰｸ接続</xsl:text>
		<!-- 設定 -->
		<xsl:text>	ﾀｽｸを要求時に実行する</xsl:text>
		<xsl:text>	ｽｹｼﾞｭｰﾙされた時刻にﾀｽｸを開始できなかった場合、すぐにﾀｽｸを実行する</xsl:text>
		<xsl:text>	ﾀｽｸが失敗した場合の再起動の間隔</xsl:text>
		<xsl:text>	間隔</xsl:text>
		<xsl:text>	再起動試行の最大数</xsl:text>
		<xsl:text>	ﾀｽｸを停止するまでの時間</xsl:text>
		<xsl:text>	時間</xsl:text>
		<xsl:text>	要求時に実行中のﾀｽｸが終了しない場合、ﾀｽｸを強制的に停止する</xsl:text>
		<xsl:text>	ﾀｽｸの再実行がｽｹｼﾞｭｰﾙされていない場合に削除されるまでの時間</xsl:text>
		<xsl:text>	時間</xsl:text>
		<xsl:text>	ﾀｽｸが既に実行中の場合に適用される規則</xsl:text>
		<!-- 改行を出力 -->
		<xsl:text>
</xsl:text>
		<xsl:apply-templates select="Tasks" />
	</xsl:template>

	<xsl:template match="Tasks">
		<xsl:apply-templates select="comment() | task:Task" />
	</xsl:template>

	<xsl:template match="comment()">
		<!-- ﾀｽｸ名 -->
		<!-- (ｺﾒﾝﾄﾉｰﾄﾞの先頭1文字と末尾1文字の半角ｽﾍﾟｰｽを除去) -->
		<xsl:value-of select="substring(., 2, string-length(.) - 2)" />
	</xsl:template>

	<xsl:template match="task:Task">
		<!-- 状態 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Status" select="task:Settings/task:Enabled" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$Status" />
			<xsl:with-param name="Default" select="'有効'" />
			<xsl:with-param name="False" select="'無効'" />
			<xsl:with-param name="True" select="'有効'" />
		</xsl:call-template>

		<!-- ============================================================ -->
		<!-- 全般 -->
		<!-- ============================================================ -->
		<!-- 説明 -->
		<xsl:text>	</xsl:text>
		<xsl:value-of select="task:RegistrationInfo/task:Description" />

		<!-- ﾀｽｸの実行時に使うﾕｰｻﾞｰ ｱｶｳﾝﾄ -->
		<xsl:text>	</xsl:text>
		<xsl:choose>
			<xsl:when test="task:Principals/task:Principal/task:GroupId">
				<xsl:value-of select="task:Principals/task:Principal/task:GroupId" />
			</xsl:when>
			<xsl:when test="task:Principals/task:Principal/task:UserId">
				<xsl:value-of select="task:Principals/task:Principal/task:UserId" />
			</xsl:when>
		</xsl:choose>

		<!-- (ｱｶｳﾝﾄ種別) -->
		<!--
		<xsl:text>	</xsl:text>
		<xsl:choose>
			<xsl:when test="task:Principals/task:Principal/task:GroupId">
				<xsl:text>ｸﾞﾙｰﾌﾟ</xsl:text>
			</xsl:when>
			<xsl:when test="task:Principals/task:Principal/task:UserId">
				<xsl:text>ﾕｰｻﾞｰ</xsl:text>
			</xsl:when>
		</xsl:choose>
		-->

		<!-- (実行種別) -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="LogonType" select="task:Principals/task:Principal/task:LogonType" />
		<!--
		<xsl:choose>
			<xsl:when test="task:Principals/task:Principal/task:GroupId">
				<xsl:text>－</xsl:text>
			</xsl:when>
			<xsl:when test="task:Principals/task:Principal/task:UserId">
		-->
				<xsl:choose>
					<xsl:when test="$LogonType">
						<xsl:choose>
							<xsl:when test="$LogonType = 'InteractiveToken'">
								<!-- <xsl:text>ﾕｰｻﾞｰがﾛｸﾞｵﾝしているときのみ実行する</xsl:text> -->
								<xsl:text>LogonType=InteractiveToken</xsl:text>
							</xsl:when>
							<xsl:when test="$LogonType = 'Password'">
								<!-- <xsl:text>ﾕｰｻﾞｰがﾛｸﾞｵﾝしているかどうかにかかわらず実行する</xsl:text> -->
								<xsl:text>LogonType=Password</xsl:text>
							</xsl:when>
							<xsl:when test="$LogonType = 'S4U'">
								<!-- <xsl:text>ﾕｰｻﾞｰがﾛｸﾞｵﾝしているかどうかにかかわらず実行する,ﾊﾟｽﾜｰﾄﾞを保存しない</xsl:text> -->
								<xsl:text>LogonType=S4U</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>-E LogonType=</xsl:text>
								<xsl:value-of select="$LogonType" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<!-- <xsl:text>ﾕｰｻﾞｰがﾛｸﾞｵﾝしているかどうかにかかわらず実行する</xsl:text> -->
						<xsl:text>LogonType=なし</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
		<!--
			</xsl:when>
		</xsl:choose>
		-->

		<!-- 最上位の特権で実行する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="RunLevel" select="task:Principals/task:Principal/task:RunLevel" />
		<xsl:choose>
			<xsl:when test="$RunLevel">
				<xsl:choose>
					<xsl:when test="$RunLevel = 'LeastPrivilege'">
						<xsl:text>□</xsl:text>
					</xsl:when>
					<xsl:when test="$RunLevel = 'HighestAvailable'">
						<xsl:text>レ</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>-E RunLevel=</xsl:text>
						<xsl:value-of select="$RunLevel" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>□</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<!-- 表示しない -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Hidden" select="task:Settings/task:Hidden" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$Hidden" />
			<xsl:with-param name="Default" select="'□'" />
		</xsl:call-template>

		<!-- 構成 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="version" select="@version" />
		<xsl:choose>
			<xsl:when test="$version = '1.1'">
				<xsl:text>Windows Server 2003, Windows XP, または Windows 2000</xsl:text>
			</xsl:when>
			<xsl:when test="$version = '1.2'">
				<xsl:text>Windows Vista, Windows Server 2008</xsl:text>
			</xsl:when>
			<xsl:when test="$version = '1.3'">
				<xsl:text>Windows 7, Windows Server 2008 R2</xsl:text>
			</xsl:when>
			<xsl:when test="($version = '1.4') or ($version = '1.5') or ($version = '1.6')">
				<xsl:text>Windows 10</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-E version=</xsl:text>
				<xsl:value-of select="$version" />
			</xsl:otherwise>
		</xsl:choose>

		<!-- ============================================================ -->
		<!-- ﾄﾘｶﾞｰ -->
		<!-- ============================================================ -->
		<xsl:variable name="Trigger" select="task:Triggers/*[1]" />
		<xsl:call-template name="Trigger_Main">
			<xsl:with-param name="Trigger" select="$Trigger" />
		</xsl:call-template>

		<!-- ============================================================ -->
		<!-- 操作 -->
		<!-- ============================================================ -->
		<xsl:variable name="Action" select="task:Actions/*[1]" />
		<xsl:call-template name="Action_Main">
			<xsl:with-param name="Action" select="$Action" />
		</xsl:call-template>

		<!-- ============================================================ -->
		<!-- 条件 -->
		<!-- ============================================================ -->
		<!-- 次の間ｱｲﾄﾞﾙ状態の場合のみﾀｽｸを開始する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="RunOnlyIfIdle" select="task:Settings/task:RunOnlyIfIdle" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$RunOnlyIfIdle" />
			<xsl:with-param name="Default" select="'□'" />
		</xsl:call-template>

		<!-- 時間 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Duration" select="task:Settings/task:IdleSettings/task:Duration" />
		<xsl:if test="translate($RunOnlyIfIdle, $UpperCaseChars, $LowerCaseChars) = 'true'">
			<xsl:call-template name="Time">
				<xsl:with-param name="Time" select="$Duration" />
				<xsl:with-param name="Default" select="'10分間'" />
			</xsl:call-template>
		</xsl:if>

		<!-- ｱｲﾄﾞﾙ状態になるのを待機する時間 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="WaitTimeout" select="task:Settings/task:IdleSettings/task:WaitTimeout" />
		<xsl:if test="translate($RunOnlyIfIdle, $UpperCaseChars, $LowerCaseChars) = 'true'">
			<xsl:choose>
				<xsl:when test="$WaitTimeout = 'PT0S'">
					<xsl:text>待機しない</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="Time">
						<xsl:with-param name="Time" select="$WaitTimeout" />
						<xsl:with-param name="Default" select="'1時間'" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!-- ｺﾝﾋﾟｭｰﾀがｱｲﾄﾞﾙ状態でなくなった場合は停止する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="StopOnIdleEnd" select="task:Settings/task:IdleSettings/task:StopOnIdleEnd" />
		<xsl:if test="translate($RunOnlyIfIdle, $UpperCaseChars, $LowerCaseChars) = 'true'">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$StopOnIdleEnd" />
				<xsl:with-param name="Default" select="'レ'" />
			</xsl:call-template>
		</xsl:if>

		<!-- 再びｱｲﾄﾞﾙ状態になったら再開する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="RestartOnIdle" select="task:Settings/task:IdleSettings/task:RestartOnIdle" />
		<xsl:if test="translate($RunOnlyIfIdle, $UpperCaseChars, $LowerCaseChars) = 'true'">
			<xsl:if test="(translate($StopOnIdleEnd, $UpperCaseChars, $LowerCaseChars) = 'true') or
							(not($StopOnIdleEnd))">
				<xsl:call-template name="Bool">
					<xsl:with-param name="Bool" select="$RestartOnIdle" />
					<xsl:with-param name="Default" select="'□'" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<!-- ｺﾝﾋﾟｭｰﾀをAC電源で使用している場合のみﾀｽｸを開始する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="DisallowStartIfOnBatteries" select="task:Settings/task:DisallowStartIfOnBatteries" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$DisallowStartIfOnBatteries" />
			<xsl:with-param name="Default" select="'レ'" />
		</xsl:call-template>

		<!-- ｺﾝﾋﾟｭｰﾀの電源をﾊﾞｯﾃﾘに切り替える場合は停止する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="StopIfGoingOnBatteries" select="task:Settings/task:StopIfGoingOnBatteries" />
		<xsl:if test="(translate($DisallowStartIfOnBatteries, $UpperCaseChars, $LowerCaseChars) = 'true') or
						(not($DisallowStartIfOnBatteries))">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$StopIfGoingOnBatteries" />
				<xsl:with-param name="Default" select="'レ'" />
			</xsl:call-template>
		</xsl:if>

		<!-- ﾀｽｸを実行するためにｽﾘｰﾌﾟを解除する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="WakeToRun" select="task:Settings/task:WakeToRun" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$WakeToRun" />
			<xsl:with-param name="Default" select="'□'" />
		</xsl:call-template>

		<!-- 次のﾈｯﾄﾜｰｸ接続が使用可能な場合のみﾀｽｸを開始する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="RunOnlyIfNetworkAvailable" select="task:Settings/task:RunOnlyIfNetworkAvailable" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$RunOnlyIfNetworkAvailable" />
			<xsl:with-param name="Default" select="'□'" />
		</xsl:call-template>

		<!-- ﾈｯﾄﾜｰｸ接続 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="NetworkSettings" select="task:Settings/task:NetworkSettings" />
		<xsl:if test="translate($RunOnlyIfNetworkAvailable, $UpperCaseChars, $LowerCaseChars) = 'true'">
			<xsl:choose>
				<xsl:when test="not($NetworkSettings)">
					<xsl:text>任意の接続</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$NetworkSettings/task:Id" />
					<xsl:text>:</xsl:text>
					<xsl:value-of select="$NetworkSettings/task:Name" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!-- ============================================================ -->
		<!-- 設定 -->
		<!-- ============================================================ -->
		<!-- ﾀｽｸを要求時に実行する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="AllowStartOnDemand" select="task:Settings/task:AllowStartOnDemand" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$AllowStartOnDemand" />
			<xsl:with-param name="Default" select="'レ'" />
		</xsl:call-template>

		<!-- ｽｹｼﾞｭｰﾙされた時刻にﾀｽｸを開始できなかった場合、すぐにﾀｽｸを実行する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="StartWhenAvailable" select="task:Settings/task:StartWhenAvailable" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$StartWhenAvailable" />
			<xsl:with-param name="Default" select="'□'" />
		</xsl:call-template>

		<!-- ﾀｽｸが失敗した場合の再起動の間隔 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="RestartOnFailure" select="task:Settings/task:RestartOnFailure" />
		<xsl:variable name="RestartOnFailure_bool">
			<xsl:choose>
				<xsl:when test="$RestartOnFailure">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$RestartOnFailure_bool" />
			<!-- <xsl:with-param name="Default" select="" /> -->
		</xsl:call-template>

		<!-- 間隔 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Interval" select="$RestartOnFailure/task:Interval" />
		<xsl:if test="$RestartOnFailure_bool = 'true'">
			<xsl:call-template name="Time">
				<xsl:with-param name="Time" select="$Interval" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>

		<!-- 再起動試行の最大数 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Count" select="$RestartOnFailure/task:Count" />
		<xsl:if test="$RestartOnFailure_bool = 'true'">
			<xsl:call-template name="Value">
				<xsl:with-param name="Value" select="$Count" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>

		<!-- ﾀｽｸを停止するまでの時間 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="ExecutionTimeLimit" select="task:Settings/task:ExecutionTimeLimit" />
		<xsl:variable name="ExecutionTimeLimit_bool">
			<xsl:choose>
				<xsl:when test="$ExecutionTimeLimit = 'PT0S'">
					<xsl:text>false</xsl:text>
				</xsl:when>
				<xsl:when test="$ExecutionTimeLimit">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>true</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$ExecutionTimeLimit_bool" />
			<!-- <xsl:with-param name="Default" select="" /> -->
		</xsl:call-template>

		<!-- 時間 -->
		<xsl:text>	</xsl:text>
		<xsl:if test="$ExecutionTimeLimit_bool = 'true'">
			<xsl:call-template name="Time">
				<xsl:with-param name="Time" select="$ExecutionTimeLimit" />
				<xsl:with-param name="Default" select="'3日間'" />
			</xsl:call-template>
		</xsl:if>

		<!-- 要求時に実行中のﾀｽｸが終了しない場合、ﾀｽｸを強制的に停止する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="AllowHardTerminate" select="task:Settings/task:AllowHardTerminate" />
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$AllowHardTerminate" />
			<xsl:with-param name="Default" select="'レ'" />
		</xsl:call-template>

		<!-- ﾀｽｸの再実行がｽｹｼﾞｭｰﾙされていない場合に削除されるまでの時間 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="DeleteExpiredTaskAfter" select="task:Settings/task:DeleteExpiredTaskAfter" />
		<xsl:variable name="DeleteExpiredTaskAfter_bool">
			<xsl:choose>
				<xsl:when test="$DeleteExpiredTaskAfter">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="Bool">
			<xsl:with-param name="Bool" select="$DeleteExpiredTaskAfter_bool" />
			<!-- <xsl:with-param name="Default" select="" /> -->
		</xsl:call-template>

		<!-- 時間 -->
		<xsl:text>	</xsl:text>
		<xsl:if test="$DeleteExpiredTaskAfter_bool = 'true'">
			<xsl:choose>
				<xsl:when test="$DeleteExpiredTaskAfter = 'PT0S'">
					<xsl:text>今すぐ</xsl:text>
				</xsl:when>
				<xsl:when test="$DeleteExpiredTaskAfter">
					<xsl:call-template name="Time">
						<xsl:with-param name="Time" select="$DeleteExpiredTaskAfter" />
						<!-- <xsl:with-param name="Default" select="" /> -->
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:if>

		<!-- ﾀｽｸが既に実行中の場合に適用される規則 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="MultipleInstancesPolicy" select="task:Settings/task:MultipleInstancesPolicy" />
		<xsl:choose>
			<xsl:when test="$MultipleInstancesPolicy">
				<xsl:choose>
					<xsl:when test="$MultipleInstancesPolicy = 'IgnoreNew'">
						<xsl:text>新しいｲﾝｽﾀﾝｽを開始しない</xsl:text>
					</xsl:when>
					<xsl:when test="$MultipleInstancesPolicy = 'Parallel'">
						<xsl:text>新しいｲﾝｽﾀﾝｽを並列で実行</xsl:text>
					</xsl:when>
					<xsl:when test="$MultipleInstancesPolicy = 'Queue'">
						<xsl:text>新しいｲﾝｽﾀﾝｽをｷｭｰに追加</xsl:text>
					</xsl:when>
					<xsl:when test="$MultipleInstancesPolicy = 'StopExisting'">
						<xsl:text>既存のｲﾝｽﾀﾝｽの停止</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>-E MultipleInstancesPolicy=</xsl:text>
						<xsl:value-of select="$MultipleInstancesPolicy" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>新しいｲﾝｽﾀﾝｽを開始しない</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<!-- 追加行 (改行前処理) -->
		<xsl:variable name="Triggers_max" select="count(task:Triggers/*)" />
		<xsl:variable name="Actions_max" select="count(task:Actions/*)" />
		<xsl:variable name="Add_lines_max">
			<xsl:choose>
				<xsl:when test="$Triggers_max &gt;= $Actions_max">
					<xsl:value-of select="$Triggers_max" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Actions_max" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$DEBUG != 0">
			<xsl:text>	</xsl:text>
			<xsl:value-of select="$Triggers_max" />
			<xsl:text>	</xsl:text>
			<xsl:value-of select="$Actions_max" />
			<xsl:text>	</xsl:text>
			<xsl:value-of select="$Add_lines_max" />
		</xsl:if>

		<!-- 改行を出力 -->
		<xsl:text>
</xsl:text>

		<!-- 追加行 (改行後処理) -->
		<xsl:call-template name="Add_lines">
			<xsl:with-param name="from" select="2" />
			<xsl:with-param name="to" select="$Add_lines_max" />
		</xsl:call-template>

	</xsl:template>

	<!-- ============================================================ -->
	<!-- 名前付きﾃﾝﾌﾟﾚｰﾄ (追加行) -->
	<!-- ============================================================ -->
	<xsl:template name="Add_lines">
		<xsl:param name="from" />
		<xsl:param name="to" />

		<xsl:if test="$from &lt;= $to">
			<xsl:value-of select="$SKIP_COLS_STATUS_CONFIG" />

			<!-- ﾄﾘｶﾞｰ -->
			<xsl:variable name="Trigger" select="task:Triggers/*[$from]" />
			<xsl:choose>
				<xsl:when test="$Trigger">
					<xsl:call-template name="Trigger_Main">
						<xsl:with-param name="Trigger" select="$Trigger" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$SKIP_COLS_TRIGGER_ENABLE" />
				</xsl:otherwise>
			</xsl:choose>

			<!-- <xsl:value-of select="$SKIP_COLS__" /> -->

			<!-- 操作 -->
			<xsl:variable name="Action" select="task:Actions/*[$from]" />
			<xsl:choose>
				<xsl:when test="$Action">
					<xsl:call-template name="Action_Main">
						<xsl:with-param name="Action" select="$Action" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$SKIP_COLS_ACTION_ACTION" />
				</xsl:otherwise>
			</xsl:choose>

			<xsl:value-of select="$SKIP_COLS_RUNONLYIFIDLE_MULTIPLEINSTANCESPOLICY" />

			<!-- 改行を出力 -->
			<xsl:text>
</xsl:text>

			<!-- カウンタの増加 -->
			<xsl:call-template name="Add_lines">
				<xsl:with-param name="from" select="$from + 1" />
				<xsl:with-param name="to" select="$to" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- ============================================================ -->
	<!-- 名前付きﾃﾝﾌﾟﾚｰﾄ (共通) -->
	<!-- ============================================================ -->
	<!-- 値 -->
	<xsl:template name="Value">
		<xsl:param name="Value" />
		<xsl:param name="Default" select="''" />
		<xsl:choose>
			<xsl:when test="$Value">
				<xsl:value-of select="$Value" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Default" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ブール -->
	<xsl:template name="Bool">
		<xsl:param name="Bool" />
		<xsl:param name="Default" select="'□'" />
		<xsl:param name="False" select="'□'" />
		<xsl:param name="True" select="'レ'" />
		<xsl:choose>
			<xsl:when test="$Bool">
				<xsl:variable name="BoolLowerCase" select="translate($Bool, $UpperCaseChars, $LowerCaseChars)" />
				<xsl:choose>
					<xsl:when test="$BoolLowerCase = 'false'">
						<xsl:value-of select="$False" />
					</xsl:when>
					<xsl:when test="$BoolLowerCase = 'true'">
						<xsl:value-of select="$True" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>-E Bool=</xsl:text>
						<xsl:value-of select="$Bool" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Default" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 日時 -->
	<xsl:template name="DateTime">
		<xsl:param name="DateTime" />
		<xsl:param name="Default" select="''" />
		<!-- 参考 DateTimeの形式 -->
		<!-- yyyy-mm-ddThh:mm:ss[.sssssss][Z] -->

		<!-- 日時 -->
		<!-- (DateTimeの先頭19文字の日時「yyyy-mm-ddThh:mm:ss」を取得し、
			日付と時刻の区切り文字「T」を半角ｽﾍﾟｰｽに置換) -->
		<!-- <xsl:value-of select="translate(substring($DateTime, 1, 19), 'T', ' ')" /> -->
		<!-- ﾀｲﾑｿﾞｰﾝ -->
		<!-- (DateTimeの末尾1文字のﾀｲﾑｿﾞｰﾝ記号「Z」(存在する場合のみ)を取得) -->
		<!-- <xsl:variable name="timezone" select="substring($DateTime, string-length($DateTime), 1)" /> -->
		<!-- <xsl:if test="$timezone = 'Z'"> -->
		<!-- 	<xsl:text>Z</xsl:text> -->
		<!-- </xsl:if> -->

		<!-- 日時 -->
		<!-- (DateTimeの日付と時刻の区切り文字「T」を半角ｽﾍﾟｰｽに置換) -->
		<xsl:choose>
			<xsl:when test="$DateTime">
				<xsl:value-of select="translate($DateTime, 'T', ' ')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Default" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 月 -->
	<xsl:template name="Months">
		<xsl:param name="Months" />
		<xsl:param name="Default" select="''" />
		<xsl:text> 月:</xsl:text>
		<xsl:choose>
			<xsl:when test="$Months">
				<xsl:variable name="Months_tree">
					<xsl:if test="$Months/task:January">
						<xsl:text>,1</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:February">
						<xsl:text>,2</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:March">
						<xsl:text>,3</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:April">
						<xsl:text>,4</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:May">
						<xsl:text>,5</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:June">
						<xsl:text>,6</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:July">
						<xsl:text>,7</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:August">
						<xsl:text>,8</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:September">
						<xsl:text>,9</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:October">
						<xsl:text>,10</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:November">
						<xsl:text>,11</xsl:text>
					</xsl:if>
					<xsl:if test="$Months/task:December">
						<xsl:text>,12</xsl:text>
					</xsl:if>
				</xsl:variable>
				<!-- 先頭1文字の「,」を除去 -->
				<xsl:value-of select="substring-after($Months_tree, ',')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Default" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 日 -->
	<xsl:template name="DaysOfMonth">
		<xsl:param name="DaysOfMonth" />
		<xsl:param name="Default" select="''" />
		<xsl:text> 日:</xsl:text>
		<xsl:choose>
			<xsl:when test="$DaysOfMonth">
				<xsl:variable name="DaysOfMonth_tree">
					<xsl:for-each select="$DaysOfMonth/task:Day">
						<xsl:text>,</xsl:text>
						<xsl:choose>
							<xsl:when test=". = 'Last'">
								<xsl:text>最終</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="." />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				<!-- 先頭1文字の「,」を除去 -->
				<xsl:value-of select="substring-after($DaysOfMonth_tree, ',')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Default" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 週 -->
	<xsl:template name="Weeks">
		<xsl:param name="Weeks" />
		<xsl:param name="Default" select="''" />
		<xsl:text> 週:</xsl:text>
		<xsl:choose>
			<xsl:when test="$Weeks">
				<xsl:variable name="Weeks_tree">
					<xsl:for-each select="$Weeks/task:Week">
						<xsl:text>,</xsl:text>
						<xsl:choose>
							<xsl:when test=". = 'Last'">
								<xsl:text>最終</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="." />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				<!-- 先頭1文字の「,」を除去 -->
				<xsl:value-of select="substring-after($Weeks_tree, ',')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Default" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 曜日 -->
	<xsl:template name="DaysOfWeek">
		<xsl:param name="DaysOfWeek" />
		<xsl:param name="Default" select="''" />
		<xsl:text> 曜日:</xsl:text>
		<xsl:choose>
			<xsl:when test="$DaysOfWeek">
				<xsl:variable name="DaysOfWeek_tree">
					<xsl:if test="$DaysOfWeek/task:Sunday">
						<xsl:text>,日</xsl:text>
					</xsl:if>
					<xsl:if test="$DaysOfWeek/task:Monday">
						<xsl:text>,月</xsl:text>
					</xsl:if>
					<xsl:if test="$DaysOfWeek/task:Tuesday">
						<xsl:text>,火</xsl:text>
					</xsl:if>
					<xsl:if test="$DaysOfWeek/task:Wednesday">
						<xsl:text>,水</xsl:text>
					</xsl:if>
					<xsl:if test="$DaysOfWeek/task:Thursday">
						<xsl:text>,木</xsl:text>
					</xsl:if>
					<xsl:if test="$DaysOfWeek/task:Friday">
						<xsl:text>,金</xsl:text>
					</xsl:if>
					<xsl:if test="$DaysOfWeek/task:Saturday">
						<xsl:text>,土</xsl:text>
					</xsl:if>
				</xsl:variable>
				<!-- 先頭1文字の「,」を除去 -->
				<xsl:value-of select="substring-after($DaysOfWeek_tree, ',')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Default" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 時刻 -->
	<xsl:template name="Time">
		<xsl:param name="Time" />
		<xsl:param name="Default" select="''" />
		<xsl:choose>
			<xsl:when test="$Time">
				<!-- 単位記号 -->
				<!-- (Timeの末尾1文字を取得) -->
				<xsl:variable name="unit" select="substring($Time, string-length($Time), 1)" />
				<xsl:variable name="Time_tree">
					<xsl:choose>
						<!-- 「時間」が「PT」で始まる場合 -->
						<xsl:when test="starts-with($Time, 'PT')">
							<!-- 時間(数字部分) -->
							<!-- (Timeの先頭2文字(=PT)と末尾1文字(=単位記号)を除去) -->
							<xsl:variable name="time_num" select="substring($Time, 3, string-length($Time) - 3)" />
							<xsl:choose>
								<!-- 「単位記号」が「S」の場合 -->
								<xsl:when test="$unit = 'S'">
									<xsl:value-of select="$time_num" />
									<xsl:text>秒間</xsl:text>
								</xsl:when>
								<!-- 「単位記号」が「M」の場合 -->
								<xsl:when test="$unit = 'M'">
									<xsl:value-of select="$time_num" />
									<xsl:text>分間</xsl:text>
								</xsl:when>
								<!-- 「単位記号」が「H」の場合 -->
								<xsl:when test="$unit = 'H'">
									<xsl:value-of select="$time_num" />
									<xsl:text>時間</xsl:text>
								</xsl:when>
								<!-- 上記以外の場合 -->
								<xsl:otherwise>
									<xsl:text>-E Time=</xsl:text>
									<xsl:value-of select="$Time" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- 「時間」が「P」で始まる場合 -->
						<xsl:when test="starts-with($Time, 'P')">
							<!-- 時間(数字部分) -->
							<!-- (Timeの先頭1文字(=P)と末尾1文字(=単位記号)を除去) -->
							<xsl:variable name="time_num" select="substring($Time, 2, string-length($Time) - 2)" />
							<xsl:choose>
								<!-- 「単位記号」が「D」の場合 -->
								<xsl:when test="$unit = 'D'">
									<xsl:value-of select="$time_num" />
									<xsl:text>日間</xsl:text>
								</xsl:when>
								<!-- 上記以外の場合 -->
								<xsl:otherwise>
									<xsl:text>-E Time=</xsl:text>
									<xsl:value-of select="$Time" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- 上記以外の場合 -->
						<xsl:otherwise>
							<xsl:text>-E Time=</xsl:text>
							<xsl:value-of select="$Time" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$Time_tree" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Default" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ﾕｰｻﾞｰID -->
	<xsl:template name="UserId">
		<xsl:param name="UserId" />
		<xsl:choose>
			<!-- 「UserId」が「特定のﾕｰｻﾞｰ」の場合 -->
			<xsl:when test="$UserId">
				<xsl:text>特定のﾕｰｻﾞｰ</xsl:text>
				<xsl:text> ﾕｰｻﾞｰ名:</xsl:text>
				<xsl:value-of select="$UserId" />
			</xsl:when>
			<!-- 「UserId」が「任意のﾕｰｻﾞｰ」の場合 -->
			<xsl:otherwise>
				<xsl:text>任意のﾕｰｻﾞｰ</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================ -->
	<!-- 名前付きﾃﾝﾌﾟﾚｰﾄ (ﾄﾘｶﾞｰ) -->
	<!-- ============================================================ -->
	<xsl:template name="Trigger_Main">
		<xsl:param name="Trigger" />
		<!-- ﾀｽｸの開始 -->
		<xsl:text>	ﾀｽｸの開始:</xsl:text>
		<xsl:choose>
			<!-- 「ﾀｽｸの開始」が「ｽｹｼﾞｭｰﾙに従う」の場合 -->
			<xsl:when test="(local-name($Trigger) = 'TimeTrigger') or
							(local-name($Trigger) = 'CalendarTrigger')">
				<xsl:text>ｽｹｼﾞｭｰﾙに従う</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:variable name="ScheduleByDay"            select="$Trigger/task:ScheduleByDay" />
				<xsl:variable name="ScheduleByWeek"           select="$Trigger/task:ScheduleByWeek" />
				<xsl:variable name="ScheduleByMonth"          select="$Trigger/task:ScheduleByMonth" />
				<xsl:variable name="ScheduleByMonthDayOfWeek" select="$Trigger/task:ScheduleByMonthDayOfWeek" />
				<xsl:choose>
					<!-- 「設定」が「毎日」の場合 -->
					<xsl:when test="$ScheduleByDay">
						<xsl:text>毎日</xsl:text>
						<xsl:text> 間隔(日):</xsl:text>
						<xsl:value-of select="$ScheduleByDay/task:DaysInterval" />
					</xsl:when>
					<!-- 「設定」が「毎週」の場合 -->
					<xsl:when test="$ScheduleByWeek">
						<xsl:text>毎週</xsl:text>
						<xsl:text> 間隔(週):</xsl:text>
						<xsl:value-of select="$ScheduleByWeek/task:WeeksInterval" />
						<xsl:call-template name="DaysOfWeek">
							<xsl:with-param name="DaysOfWeek" select="$ScheduleByWeek/task:DaysOfWeek" />
						</xsl:call-template>
					</xsl:when>
					<!-- 「設定」が「毎月」かつ種別が「日」の場合、または -->
					<!-- 「設定」が「毎月」かつ種別が「曜日」の場合 -->
					<xsl:when test="$ScheduleByMonth or $ScheduleByMonthDayOfWeek">
						<xsl:text>毎月</xsl:text>
						<xsl:choose>
							<!-- 「設定」が「毎月」かつ種別が「日」の場合 -->
							<xsl:when test="$ScheduleByMonth">
								<xsl:call-template name="Months">
									<xsl:with-param name="Months"      select="$ScheduleByMonth/task:Months" />
								</xsl:call-template>
								<xsl:call-template name="DaysOfMonth">
									<xsl:with-param name="DaysOfMonth" select="$ScheduleByMonth/task:DaysOfMonth" />
								</xsl:call-template>
							</xsl:when>
							<!-- 「設定」が「毎月」かつ種別が「曜日」の場合 -->
							<xsl:when test="$ScheduleByMonthDayOfWeek">
								<xsl:call-template name="Months">
									<xsl:with-param name="Months"     select="$ScheduleByMonthDayOfWeek/task:Months" />
								</xsl:call-template>
								<xsl:call-template name="Weeks">
									<xsl:with-param name="Weeks"      select="$ScheduleByMonthDayOfWeek/task:Weeks" />
								</xsl:call-template>
								<xsl:call-template name="DaysOfWeek">
									<xsl:with-param name="DaysOfWeek" select="$ScheduleByMonthDayOfWeek/task:DaysOfWeek" />
								</xsl:call-template>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<!-- 「設定」が「1回」の場合 -->
					<xsl:otherwise>
						<xsl:text>1回</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- 「ﾀｽｸの開始」が「ﾛｸﾞｵﾝ時」の場合 -->
			<xsl:when test="local-name($Trigger) = 'LogonTrigger'">
				<xsl:text>ﾛｸﾞｵﾝ時</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:call-template name="UserId">
					<xsl:with-param name="UserId" select="$Trigger/task:UserId" />
				</xsl:call-template>
			</xsl:when>
			<!-- 「ﾀｽｸの開始」が「ｽﾀｰﾄｱｯﾌﾟ時」の場合 -->
			<xsl:when test="local-name($Trigger) = 'BootTrigger'">
				<xsl:text>ｽﾀｰﾄｱｯﾌﾟ時</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:(なし)</xsl:text>
			</xsl:when>
			<!-- 「ﾀｽｸの開始」が「ｱｲﾄﾞﾙ時」の場合 -->
			<xsl:when test="local-name($Trigger) = 'IdleTrigger'">
				<xsl:text>ｱｲﾄﾞﾙ時</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:(なし)</xsl:text>
			</xsl:when>
			<!-- 「ﾀｽｸの開始」が「ｲﾍﾞﾝﾄ時」の場合 -->
			<xsl:when test="local-name($Trigger) = 'EventTrigger'">
				<xsl:text>ｲﾍﾞﾝﾄ時</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:variable name="Subscription" select="$Trigger/task:Subscription" />
				<xsl:choose>
					<xsl:when test="$Subscription">
						<xsl:text>ｲﾍﾞﾝﾄﾌｨﾙﾀｰ:</xsl:text>
						<!-- Subscription中の全ての改行文字を除去 -->
						<xsl:value-of select="translate($Subscription, '
', '')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>-E Element not found - Subscription</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- 「ﾀｽｸの開始」が「ﾀｽｸの作成/変更時」の場合 -->
			<xsl:when test="local-name($Trigger) = 'RegistrationTrigger'">
				<xsl:text>ﾀｽｸの作成/変更時</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:(なし)</xsl:text>
			</xsl:when>
			<!-- 「ﾀｽｸの開始」が「ﾕｰｻﾞｰ ｾｯｼｮﾝへの接続時」の場合、または -->
			<!-- 「ﾀｽｸの開始」が「ﾕｰｻﾞｰ ｾｯｼｮﾝからの切断時」の場合、または -->
			<!-- 「ﾀｽｸの開始」が「ﾜｰｸｽﾃｰｼｮﾝ ﾛｯｸ時」の場合、または -->
			<!-- 「ﾀｽｸの開始」が「ﾜｰｸｽﾃｰｼｮﾝ ｱﾝﾛｯｸ時」の場合 -->
			<xsl:when test="local-name($Trigger) = 'SessionStateChangeTrigger'">
				<xsl:variable name="StateChange" select="$Trigger/task:StateChange" />
				<xsl:choose>
					<!-- 「ﾀｽｸの開始」が「ﾕｰｻﾞｰ ｾｯｼｮﾝへの接続時」の場合 -->
					<xsl:when test="($StateChange = 'RemoteConnect') or
									($StateChange = 'ConsoleConnect')">
						<xsl:text>ﾕｰｻﾞｰ ｾｯｼｮﾝへの接続時</xsl:text>
					</xsl:when>
					<!-- 「ﾀｽｸの開始」が「ﾕｰｻﾞｰ ｾｯｼｮﾝからの切断時」の場合 -->
					<xsl:when test="($StateChange = 'RemoteDisconnect') or
									($StateChange = 'ConsoleDisconnect')">
						<xsl:text>ﾕｰｻﾞｰ ｾｯｼｮﾝからの切断時</xsl:text>
					</xsl:when>
					<!-- 「ﾀｽｸの開始」が「ﾜｰｸｽﾃｰｼｮﾝ ﾛｯｸ時」の場合 -->
					<xsl:when test="$StateChange = 'SessionLock'">
						<xsl:text>ﾜｰｸｽﾃｰｼｮﾝ ﾛｯｸ時</xsl:text>
					</xsl:when>
					<!-- 「ﾀｽｸの開始」が「ﾜｰｸｽﾃｰｼｮﾝ ｱﾝﾛｯｸ時」の場合 -->
					<xsl:when test="$StateChange = 'SessionUnlock'">
						<xsl:text>ﾜｰｸｽﾃｰｼｮﾝ ｱﾝﾛｯｸ時</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>-E StateChange=</xsl:text>
						<xsl:value-of select="$StateChange" />
					</xsl:otherwise>
				</xsl:choose>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:call-template name="UserId">
					<xsl:with-param name="UserId" select="$Trigger/task:UserId" />
				</xsl:call-template>
				<!-- 「ﾀｽｸの開始」が「ﾕｰｻﾞｰ ｾｯｼｮﾝへの接続時」の場合、または -->
				<!-- 「ﾀｽｸの開始」が「ﾕｰｻﾞｰ ｾｯｼｮﾝからの切断時」の場合 -->
				<xsl:if test="($StateChange = 'RemoteConnect') or
								($StateChange = 'ConsoleConnect') or
								($StateChange = 'RemoteDisconnect') or
								($StateChange = 'ConsoleDisconnect')">
					<!-- ～からの接続 -->
					<xsl:text> ～からの接続:</xsl:text>
					<xsl:choose>
						<!-- 「～からの接続」が「ﾘﾓｰﾄ ｺﾝﾋﾟｭｰﾀ」の場合 -->
						<xsl:when test="($StateChange = 'RemoteConnect') or
										($StateChange = 'RemoteDisconnect')">
							<xsl:text>ﾘﾓｰﾄ ｺﾝﾋﾟｭｰﾀ</xsl:text>
						</xsl:when>
						<!-- 「～からの接続」が「ﾛｰｶﾙ ｺﾝﾋﾟｭｰﾀ」の場合 -->
						<xsl:when test="($StateChange = 'ConsoleConnect') or
										($StateChange = 'ConsoleDisconnect')">
							<xsl:text>ﾛｰｶﾙ ｺﾝﾋﾟｭｰﾀ</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:when>
			<!-- 「ﾀｽｸの開始」が「ｶｽﾀﾑ ﾄﾘｶﾞｰ」の場合 -->
			<xsl:when test="local-name($Trigger) = 'WnfStateChangeTrigger'">
				<xsl:text>ｶｽﾀﾑ ﾄﾘｶﾞｰ</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:variable name="StateName" select="$Trigger/task:StateName" />
				<xsl:if test="$StateName">
					<xsl:text>StateName:</xsl:text>
					<xsl:value-of select="$StateName" />
				</xsl:if>
			</xsl:when>
			<!-- 「ﾀｽｸの開始」が未定義の場合 -->
			<xsl:when test="local-name($Trigger) = ''">
				<xsl:text>(未定義)</xsl:text>
			</xsl:when>
			<!-- 上記以外の場合 -->
			<xsl:otherwise>
				<xsl:text>-E Trigger=</xsl:text>
				<xsl:value-of select="local-name($Trigger)" />
			</xsl:otherwise>
		</xsl:choose>

		<!-- 詳細設定 -->
		<xsl:choose>
			<!-- 「ﾀｽｸの開始」が「ｽｹｼﾞｭｰﾙに従う」の場合 -->
			<xsl:when test="(local-name($Trigger) = 'TimeTrigger') or
							(local-name($Trigger) = 'CalendarTrigger')">
				<xsl:call-template name="Trigger_RandomDelay">
					<xsl:with-param name="Trigger" select="$Trigger" />
				</xsl:call-template>
			</xsl:when>
			<!-- 上記以外の場合 -->
			<xsl:otherwise>
				<xsl:call-template name="Trigger_Delay">
					<xsl:with-param name="Trigger" select="$Trigger" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="Trigger_Repetition">
			<xsl:with-param name="Trigger" select="$Trigger" />
		</xsl:call-template>
		<xsl:call-template name="Trigger_ExecutionTimeLimit">
			<xsl:with-param name="Trigger" select="$Trigger" />
		</xsl:call-template>
		<xsl:call-template name="Trigger_StartBoundary">
			<xsl:with-param name="Trigger" select="$Trigger" />
		</xsl:call-template>
		<xsl:call-template name="Trigger_EndBoundary">
			<xsl:with-param name="Trigger" select="$Trigger" />
		</xsl:call-template>
		<xsl:call-template name="Trigger_Enabled">
			<xsl:with-param name="Trigger" select="$Trigger" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="Trigger_RandomDelay">
		<xsl:param name="Trigger" />
		<!-- 遅延時間を指定する(ﾗﾝﾀﾞﾑ) -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="RandomDelay" select="$Trigger/task:RandomDelay" />
		<xsl:variable name="RandomDelay_bool">
			<xsl:choose>
				<xsl:when test="$RandomDelay">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$Trigger">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$RandomDelay_bool" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
		<!-- 遅延時間(ﾗﾝﾀﾞﾑ) -->
		<xsl:text>	</xsl:text>
		<xsl:if test="$RandomDelay_bool = 'true'">
			<xsl:call-template name="Time">
				<xsl:with-param name="Time" select="$RandomDelay" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Trigger_Delay">
		<xsl:param name="Trigger" />
		<!-- 遅延時間を指定する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Delay" select="$Trigger/task:Delay" />
		<xsl:variable name="Delay_bool">
			<xsl:choose>
				<xsl:when test="$Delay">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$Trigger">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$Delay_bool" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
		<!-- 遅延時間 -->
		<xsl:text>	</xsl:text>
		<xsl:if test="$Delay_bool = 'true'">
			<xsl:call-template name="Time">
				<xsl:with-param name="Time" select="$Delay" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Trigger_Repetition">
		<xsl:param name="Trigger" />
		<!-- 繰り返し間隔 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Repetition" select="$Trigger/task:Repetition" />
		<xsl:variable name="Repetition_bool">
			<xsl:choose>
				<xsl:when test="$Repetition">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$Trigger">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$Repetition_bool" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
		<!-- 繰り返し間隔 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Interval" select="$Repetition/task:Interval" />
		<xsl:if test="$Repetition_bool = 'true'">
			<xsl:call-template name="Time">
				<xsl:with-param name="Time" select="$Interval" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
		<!-- 継続時間 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Duration" select="$Repetition/task:Duration" />
		<xsl:if test="$Repetition_bool = 'true'">
			<xsl:call-template name="Time">
				<xsl:with-param name="Time" select="$Duration" />
				<xsl:with-param name="Default" select="'無期限'" />
			</xsl:call-template>
		</xsl:if>
		<!-- 繰り返し継続時間の最後に実行中のすべてのﾀｽｸを停止する -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="StopAtDurationEnd" select="$Repetition/task:StopAtDurationEnd" />
		<xsl:if test="$Repetition_bool = 'true'">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$StopAtDurationEnd" />
				<xsl:with-param name="Default" select="'□'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Trigger_ExecutionTimeLimit">
		<xsl:param name="Trigger" />
		<!-- 停止するまでの時間 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="ExecutionTimeLimit" select="$Trigger/task:ExecutionTimeLimit" />
		<xsl:variable name="ExecutionTimeLimit_bool">
			<xsl:choose>
				<xsl:when test="$ExecutionTimeLimit">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$Trigger">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$ExecutionTimeLimit_bool" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
		<!-- 停止するまでの時間 -->
		<xsl:text>	</xsl:text>
		<xsl:if test="$ExecutionTimeLimit_bool = 'true'">
			<xsl:call-template name="Time">
				<xsl:with-param name="Time" select="$ExecutionTimeLimit" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Trigger_StartBoundary">
		<xsl:param name="Trigger" />
		<!-- 開始/ｱｸﾃｨﾌﾞ化 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="StartBoundary" select="$Trigger/task:StartBoundary" />
		<xsl:variable name="StartBoundary_bool">
			<xsl:choose>
				<xsl:when test="$StartBoundary">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$Trigger">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$StartBoundary_bool" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
		<!-- 開始/ｱｸﾃｨﾌﾞ化 -->
		<xsl:text>	</xsl:text>
		<xsl:if test="$StartBoundary_bool = 'true'">
			<xsl:call-template name="DateTime">
				<xsl:with-param name="DateTime" select="$StartBoundary" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Trigger_EndBoundary">
		<xsl:param name="Trigger" />
		<!-- 有効期限 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="EndBoundary" select="$Trigger/task:EndBoundary" />
		<xsl:variable name="EndBoundary_bool">
			<xsl:choose>
				<xsl:when test="$EndBoundary">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$Trigger">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$EndBoundary_bool" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
		<!-- 有効期限 -->
		<xsl:text>	</xsl:text>
		<xsl:if test="$EndBoundary_bool = 'true'">
			<xsl:call-template name="DateTime">
				<xsl:with-param name="DateTime" select="$EndBoundary" />
				<!-- <xsl:with-param name="Default" select="" /> -->
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Trigger_Enabled">
		<xsl:param name="Trigger" />
		<!-- 有効 -->
		<xsl:text>	</xsl:text>
		<xsl:variable name="Enabled" select="$Trigger/task:Enabled" />
		<xsl:if test="$Trigger">
			<xsl:call-template name="Bool">
				<xsl:with-param name="Bool" select="$Enabled" />
				<xsl:with-param name="Default" select="'レ'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- ============================================================ -->
	<!-- 名前付きﾃﾝﾌﾟﾚｰﾄ (操作) -->
	<!-- ============================================================ -->
	<xsl:template name="Action_Main">
		<xsl:param name="Action" />
		<!-- 操作 -->
		<xsl:text>	操作:</xsl:text>
		<xsl:choose>
			<!-- 「操作」が「ﾌﾟﾛｸﾞﾗﾑの開始」の場合 -->
			<xsl:when test="local-name($Action) = 'Exec'">
				<xsl:text>ﾌﾟﾛｸﾞﾗﾑの開始</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:variable name="Command" select="$Action/task:Command" />
				<xsl:if test="$Command">
					<xsl:text>ﾌﾟﾛｸﾞﾗﾑ/ｽｸﾘﾌﾟﾄ:</xsl:text>
					<xsl:value-of select="$Command" />
				</xsl:if>
				<xsl:variable name="Arguments" select="$Action/task:Arguments" />
				<xsl:if test="$Arguments">
					<xsl:text> 引数の追加:</xsl:text>
					<xsl:value-of select="$Arguments" />
				</xsl:if>
				<xsl:variable name="WorkingDirectory" select="$Action/task:WorkingDirectory" />
				<xsl:if test="$WorkingDirectory">
					<xsl:text> 開始:</xsl:text>
					<xsl:value-of select="$WorkingDirectory" />
				</xsl:if>
			</xsl:when>
			<!-- 「操作」が「電子ﾒｰﾙの送信 (非推奨)」の場合 -->
			<xsl:when test="local-name($Action) = 'SendEmail'">
				<xsl:text>電子ﾒｰﾙの送信 (非推奨)</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:variable name="From" select="$Action/task:From" />
				<xsl:if test="$From">
					<xsl:text>差出人:</xsl:text>
					<xsl:value-of select="$From" />
				</xsl:if>
				<xsl:variable name="To" select="$Action/task:To" />
				<xsl:if test="$To">
					<xsl:text> 送信先:</xsl:text>
					<xsl:value-of select="$To" />
				</xsl:if>
				<xsl:variable name="Subject" select="$Action/task:Subject" />
				<xsl:if test="$Subject">
					<xsl:text> 件名:</xsl:text>
					<xsl:value-of select="$Subject" />
				</xsl:if>
				<xsl:variable name="HeaderFields" select="$Action/task:HeaderFields" />
				<xsl:if test="$HeaderFields">
					<xsl:text> ﾍｯﾀﾞｰ ﾌｨｰﾙﾄﾞ:</xsl:text>
					<xsl:variable name="HeaderFields_tree">
						<xsl:for-each select="$HeaderFields/task:HeaderField">
							<xsl:text>,"</xsl:text>
							<xsl:value-of select="task:Name" />
							<xsl:text>: </xsl:text>
							<xsl:value-of select="task:Value" />
							<xsl:text>"</xsl:text>
						</xsl:for-each>
					</xsl:variable>
					<!-- 先頭1文字の「,」を除去 -->
					<xsl:value-of select="substring-after($HeaderFields_tree, ',')" />
				</xsl:if>
				<xsl:variable name="Body" select="$Action/task:Body" />
				<xsl:if test="$Body">
					<xsl:text> ﾃｷｽﾄ:</xsl:text>
					<xsl:value-of select="$Body" />
				</xsl:if>
				<xsl:variable name="Attachments" select="$Action/task:Attachments" />
				<xsl:if test="$Attachments">
					<xsl:text> 添付ﾌｧｲﾙ:</xsl:text>
					<xsl:variable name="Attachments_tree">
						<xsl:for-each select="$Attachments/task:File">
							<xsl:text>,</xsl:text>
							<xsl:value-of select="." />
						</xsl:for-each>
					</xsl:variable>
					<!-- 先頭1文字の「,」を除去 -->
					<xsl:value-of select="substring-after($Attachments_tree, ',')" />
				</xsl:if>
				<xsl:variable name="Server" select="$Action/task:Server" />
				<xsl:if test="$Server">
					<xsl:text> SMTPｻｰﾊﾞ:</xsl:text>
					<xsl:value-of select="$Server" />
				</xsl:if>
			</xsl:when>
			<!-- 「操作」が「ﾒｯｾｰｼﾞの表示 (非推奨)」の場合 -->
			<xsl:when test="local-name($Action) = 'ShowMessage'">
				<xsl:text>ﾒｯｾｰｼﾞの表示 (非推奨)</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:variable name="Title" select="$Action/task:Title" />
				<xsl:if test="$Title">
					<xsl:text>ﾀｲﾄﾙ:</xsl:text>
					<xsl:value-of select="$Title" />
				</xsl:if>
				<xsl:variable name="Body" select="$Action/task:Body" />
				<xsl:if test="$Body">
					<xsl:text> ﾒｯｾｰｼﾞ:</xsl:text>
					<xsl:value-of select="$Body" />
				</xsl:if>
			</xsl:when>
			<!-- 「操作」が「ｶｽﾀﾑ ﾊﾝﾄﾞﾗｰ」の場合 -->
			<xsl:when test="local-name($Action) = 'ComHandler'">
				<xsl:text>ｶｽﾀﾑ ﾊﾝﾄﾞﾗｰ</xsl:text>
				<!-- 設定 -->
				<xsl:text> 設定:</xsl:text>
				<xsl:variable name="ClassId" select="$Action/task:ClassId" />
				<xsl:if test="$ClassId">
					<xsl:text>ClassId:</xsl:text>
					<xsl:value-of select="$ClassId" />
				</xsl:if>
				<xsl:variable name="Data" select="$Action/task:Data" />
				<xsl:if test="$Data">
					<xsl:text> Data:</xsl:text>
					<xsl:value-of select="$Data" />
				</xsl:if>
			</xsl:when>
			<!-- 「操作」が未定義の場合 -->
			<xsl:when test="local-name($Action) = ''">
				<xsl:text>(未定義)</xsl:text>
			</xsl:when>
			<!-- 上記以外の場合 -->
			<xsl:otherwise>
				<xsl:text>-E Action=</xsl:text>
				<xsl:value-of select="local-name($Action)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
