#!/usr/local/bin/perl

use strict;
use warnings;
use utf8;
use open ":utf8";
binmode STDIN, ':encoding(utf8)';
binmode STDOUT, ':encoding(utf8)';
binmode STDERR, ':encoding(utf8)';

my @program; #プログラム格納用リスト

print "<<type the program's name>>\n"; 
#標準入力からファイル名を入力
my $file = <STDIN>;
#my $file = "sample.c";
utf8::decode($file);
chomp($file);

#ファイルを読み込みモードで読み込む(ORIGINAL_PROGRAM)
open (ORIGINAL_PROGRAM, "<:utf8", "$file") or die "Error:$!";

#プログラムを格納する配列の作成
my @original;
#格納配列の0番目を作成
push(@original, " ");
push(@program, " ");

#コードを配列に格納
while(my $line = readline ORIGINAL_PROGRAM){
	chomp $line;
	push(@original, $line); # myを追加しなきゃだめ
	
}

#配列にコードが格納されたことを確認するコード
my $num = @original;
print "この配列の要素は", $num, "個あります\n";



#comment_deleted.cを書き込みモードでオープン
open (COMMENT_DELETED, ">", "comment_deleted.c") or die("Error:$!");

#プログラムを書き込む処理
my $count; #行数のカウンタ
my $counter = 0; #複数行に渡るコメントのカウンタ
for($count = 1; $count < $num; $count++){

	if($counter eq 1){
		print COMMENT_DELETED "\n";
		if($original[$count] =~ m|\*/|){
			$counter = 0;
		}
	}

	#行頭が//で始まるコメント行を削除する処理
	elsif($original[$count] =~ m|^//|){
		print COMMENT_DELETED "\n";
		push(@program, "\n");
	}
	#行の途中から//のコメントを削除する処理
	elsif($original[$count] =~ m|//|){
		my @comment1 = split(m|//|,$original[$count]);
		print COMMENT_DELETED "$comment1[0]\n";
		push(@program, "$comment1[0]\n");
	}
	elsif($original[$count] =~ m|/\*|){
		my @comment2 = split(m|/\*|,$original[$count]); # /* の前後で分割したリスト
		if($comment2[1] =~ m|\*/|){ #
			my @comment3 = split(m|/\*|,$comment2[1]);  
			print COMMENT_DELETED "$comment2[0]\n"; #さすがに行中にコメントを記述するようなコードはないと仮定(コメントを取り除いた前or後の行を出力
			push(@program, "$comment2[0]\n");
		}
		else{
			print "$counter\n";
			$counter = 1;
		}
		#print COMMENT_DELETED "$comment2[0]\n"; #さすがに行中にコメントを記述するようなコードはないと仮定(コメントを取り除いた前or後の行を出力　
	}


	#コメントを意識しなくていい場合
	else{
	print COMMENT_DELETED "$original[$count]\n";
	push(@program, "$original[$count]\n");
	}
}
#オリジナルプログラムはこれ以上使わないのでクローズ
close ORIGINAL_PROGRAM;
close COMMENT_DELETED;

foreach my $a (@program){
	print "$a";
}


my $n_of_lines; #読み込んだ行数のカウンタ
my @unrolled_name; #展開した配列名(CREST関数化に使用)
my @unroll_time; #配列展開回数
my @if_start; #ループ展開の開始行数ポインタ
my @if_end; #ループ展開の終了行数ポインタ
my $start = 0;
my $end = 0; #上記に使うカウンタ
my $unrolled = 1;
my $k = 0;
my $l; #汎用カウンタ
my $for_count = 0; #for文の箇所特定のためのカウンタ
my $flag = 0;
my @roop_num; #ループ展開をした回数を保持する配列
my $unroll_val; #ループ展開用変数保持変数
my $for_roop; #for文を展開するときに使うカウンタ
my $num_of_program; #生成プログラムの番号(ネストの深さで変わる)
my @roop_line; #なんか使ってるっぽい
my @variable; #ループ展開した変数保持配列
my @unrolled_line; #ループ展開したfor文の行数保持配列
my $v = 0; #上記の汎用カウンタ
my $q;
my $roop_flag; #同じfor文を判定するのに用いるフラグ
my $num_of_counter = 0; #ループ展開数を入れる
my $counter_flag; #ループ回数をプログラム中から読み込めているかのフラグ
my $tmp; #ループ回数を入れる変数
my @strlist1;
my @strlist2;
my @strlist3; #split用配列
my $can_unrolling; #ループ展開可能かを判別するフラグ 
my @for_tmp; #forループ一時保存配列
my $for_num; #上記のカウンタ
my $u;
my $program_temp; #ループ展開if文一時保存変数
my $blank_num; #for文の前処理(一番目)がない場合のループ開始変数
my $blank_flag; #上記のフラグ
my $decrement_flag = 0; #デクリメントのフラグ
my $and_or_flag = 0; #論理演算子を特定するフラグ
print "type your new file name\n";
$file = <STDIN>;
utf8::decode($file);
chomp($file);
open(UNROLLED, ">", "$file") or die("Error:$!");

open(VARIABLE, "> crest_variable.c");
&for_check();
close(VARIABLE, "> crest_variable.c");

#ネストされたfor分を検出、処理する関数

sub for_check{
	for($n_of_lines = 1; $n_of_lines < $num; $n_of_lines++){
		#$blank_flag = 0; #これを入れるかどうかで動作が変化する
		print "現在", $n_of_lines, "行目\n";
		#ループ展開ができるfor文なのかを判定する

		if($program[$n_of_lines] =~ /for\s*\(/){
			print $n_of_lines,"行目にfor文を検出しました。\n";
			print "$program[$n_of_lines]\n";
			my $val = $program[$n_of_lines]; #対象行の一次保存


			@strlist1 = split(/\(/, $val);
			#print "$strlist1[1]";
			
			@strlist2 = split(/;/, $strlist1[1]);
			#print "$strlist2[0]";
			@strlist3 = split(/=/, $strlist2[0]);
			$strlist3[0] =~ s/\s+//g; #スペースを削除する処理 
			if($strlist3[0]){
				print "展開の必要な可能性のある変数は", $strlist3[0], "です\n";
				$unroll_val = $strlist3[0];
				$for_num = 0; #forループ一時保存配列の初期化
				&roop_unrolling();
			}
			elsif($strlist2[1]){ #二番目の式(制御式)が存在する
				if($strlist2[1] =~ /&&|\|\|/){ #制御式に論理演算が含まれている
					print "初期値なしで論理演算が含まれています\n";
				} 
				
				my @list = split(/<=|>=|==|<|>|!=/,$strlist2[1]);
				print "$list[0]\n";

				$list[0] =~ s/\s+//g; #スペースを削除する処理 
				print "$strlist2[2]\n";
				if($strlist2[2]){ #すべての要素がnullでない(無限ループとなっていない)
					$unroll_val = $list[0];
					$for_num = 0; #forループ一時保存配列の初期化
					$blank_flag = 1;
					&roop_unrolling();


				#ループ展開数を読み込む処理
				}
			}

			else{
				print UNROLLED "$program[$n_of_lines]";
			}
		}	
		else{
			#for文が検出されなかった場合はそのまま書き込む
			#print "for文が検出されなかったので、そのまま書き込む\n";
			print UNROLLED "$program[$n_of_lines]";
		}
	}
	print "ループ展開プログラム終了\n";	
}



sub roop_number{ #ループ展開を行うfor文の展開回数の特定

	$decrement_flag = 0;
	if($program[$n_of_lines] =~ /&&|\|\|/ ){ #論理演算が入っているかをチェック
		print $program[$n_of_lines], "　は論理演算を含んでいます\n";
		print "ループ展開数を指定してください\n";
		$tmp = <STDIN>;
		chomp($tmp);
		$counter_flag = 1;

	}

	elsif($program[$n_of_lines] =~ /(;.*;)/ ){
		$tmp = $1;
		#print "スプリットした文字列は", $tmp, "です\n";
		if($tmp =~ /(<.*;)/) {
			$tmp = $1;
			#print "さらにスプリットした文字列は", $tmp, "です\n";
			if($tmp =~ /([0-9]+)/){
				$tmp = $1;
				print "ループ回数は", $tmp, "です\n";
				$counter_flag = 1;
			}
		}
		elsif($tmp =~ /(!.*\[.*\];)/){ #否定演算子があった場合
			print $tmp,"ループ展開数を指定してください\n";
			$tmp = <STDIN>;
			chomp($tmp);
			$counter_flag = 1;
		}
	}
}
sub roop_unrolling{
	$for_tmp[$for_num] = $program[$n_of_lines]; #for文の１文を一時保存
	$for_num++;
	$counter_flag = 0;
	#ループ展開する回数をfor( ~ ; i < 60; ~ )から抽出する処理
	&roop_number();
	
		#for文の後ろに{がない場合
		#1回目は下に{がないか調べるためにスキップする。
	if($program[$n_of_lines] !~ /{/){
		$n_of_lines++; 
		}
		#2回目は{がないかをさらに調べ、なかったら{がないfor文のループ展開を行う
	if($program[$n_of_lines] !~ /{/){
		if($program[$n_of_lines] =~ /if/){
			if($program[$n_of_lines] =~ /\[$unroll_val\]/){
				print "かっこのないforとifのループを検出しました\n";
				&roop_number();
				
				print "何回ループ展開をしますか?\n"; 
				my $time = <STDIN>;
				chomp($time);

				#$unroll_time[$n_of_lines] = <STDIN>;

				#デクリメントのフラグで動作を変更
				for($u = 0; $u < $time; $u++){
					#ループ展開の命令を書く
					print $u, "回目の展開\n";
					$program_temp = $program[$n_of_lines];
					$program_temp =~ s/\[$unroll_val\]/\[$u\]/m;
					print "$program_temp\n";
					print UNROLLED "$program_temp";
					print UNROLLED "$program[$n_of_lines+1]";
					my @string1 = split(/\(/, $program_temp); #crest変数の宣言用に
					my @string2 = split(/<=|>=|==|<|>|!=/,$string1[1]);
					print VARIABLE "$string2[0]\n";
				}


				$for_tmp[$for_num] = $program[$n_of_lines];
				$for_num++;
				$n_of_lines++;
			}
			else{
				$for_tmp[$for_num] = $program[$n_of_lines-1];
				print UNROLLED "$for_tmp[$for_num]";
				$for_tmp[$for_num] = $program[$n_of_lines];
				print UNROLLED "$for_tmp[$for_num]";
				$for_num++;
				$n_of_lines++;
				$for_tmp[$for_num] = $program[$n_of_lines];
				print UNROLLED "$for_tmp[$for_num]";
				$for_num++;
			}
		}
		else{
			$for_tmp[$for_num] = $program[$n_of_lines-1];
				print UNROLLED "$for_tmp[$for_num]";
			$for_tmp[$for_num] = $program[$n_of_lines];
			print UNROLLED "$for_tmp[$for_num]";
			$for_num++;
			$n_of_lines++;
			$for_tmp[$for_num] = $program[$n_of_lines];
			print UNROLLED "$for_tmp[$for_num]";
			$for_num++;

		}
	}
	#for文の1行下に{がある
	else{
			&main();
	}	
}

sub main{ #かっこがあるパターンのループ展開の処理
	$if_start[$start] = $n_of_lines + 1; #次の行からforループの処理が始まる
	$roop_line[$k] = 1;
	$flag = 0;

	$for_tmp[$for_num] = $program[$n_of_lines];
	$for_num++;

	for ($for_count = $n_of_lines + 1; $roop_line[$k] > 0; $for_count++){
		#forループの中にif文の条件式にループ展開が必要な変数が存在するのかを判定する
		$for_tmp[$for_num] = $program[$for_count];
		$for_num++;
		if($program[$for_count] =~ /if.*\[$unroll_val\].*/){
			print $unroll_val;
			print $program[$for_count],"行目にループ展開が必要なif文を発見しました\n";
			#ループ展開が必要な変数があれば、フラグを立てる
			$variable[$v] = $unroll_val;
			$flag = 1;
		}

		if($program[$for_count] =~ /switch.*\[$unroll_val\].*/){
			#ループ展開が必要な変数があれば、フラグを立てる
			$variable[$v] = $unroll_val;
			$flag = 1;
		}					
					

		if($program[$for_count] =~ /{/){ #カッコがあるか判定
			$roop_line[$k]++;
		}
		elsif($program[$for_count] =~ /}/){ #同上
			$roop_line[$k]--;
		}

		if($roop_line[$k] == 0){ #ループの終了だったら
			#print "ループ解析終了\n";
			$if_end[$k] = $for_count; #ループの終了行数を記録
			$n_of_lines = $for_count;
			$k++; #次の配列にループの開始と終了を記録するためのインクリメント
			$unrolled_line[$v] = $n_of_lines - $if_start[$start];
			$v++;
		}
	}	
	#展開の必要な配列を含む条件文(if文)がなかった場合
	if($flag == 0){
		for(my $p = 0; $p < $for_num; $p++){
			print UNROLLED "$for_tmp[$p]";
			#上記の処理
		}

	}


	#以前に同じfor文を展開していないかをチェックする処理
	$roop_flag = 0;
	for($q = 0; $q < $v-1  ; $q++){
		if($variable[$q] eq $variable[$v-1] and $unrolled_line[$q] == $unrolled_line[$v-1]){
			$roop_flag = 1;
			print "以前ループ展開されたfor文が含まれています\n";
			$unroll_time[$n_of_lines] = $roop_num[$q]; #以前使われたループ展開数を利用
			last;
			#ループ展開数の入力をスキップする処理を書く
		}
	}

	if($roop_flag == 0 and $flag == 1){
		if($counter_flag == 0){
			print "何回ループ展開をしますか?\n"; 
			$unroll_time[$n_of_lines] = <STDIN>;
		}
		else{
			$unroll_time[$n_of_lines] = $tmp;
		}
		$roop_num[$num_of_counter] = $unroll_time[$n_of_lines];
	}
	#上記のif文の外に以下の1行を出すとうまいこといく
	$num_of_counter++;

	#ここから実際にループ展開をしていく
	my $roop_time = 0; #ループ回数を記録するカウンタ
	if($flag == 1){
		#指定された回数だけループ展開を行う
		if($blank_flag == 1){
			print "変数の初期値を入力してください\n";
			$l = <STDIN>;
			chomp($l);
			$blank_flag = 0;
		}
		else{
			$l = 0;
		}
		for(; $l < $unroll_time[$n_of_lines]; $l++){
			#for文の中の処理のみ繰り返して出力する
			for($for_roop = $if_start[$start]; $for_roop < $for_count -1; $for_roop++){ 
				#対象の配列が含まれていたら

				#デクリメントで動作を変更させるように変更

				if($program[$for_roop] =~ /\[.*?$unroll_val.*?\]/){ #最短マッチで対象変数を要素として含む配列かを判別(この時点では)
				 	$program_temp = $program[$for_roop]; #一時的に保存
				 	$program_temp=~ s/\s+//g; #スペースを削除
				 	if($program_temp =~ /[^a-zA-Z0-9]*?$unroll_val[^a-zA-Z0-9]*?/){
				 		$program_temp = $program[$for_roop];
						$program_temp =~ s/$unroll_val/$roop_time/m;
						#print "ループ展開回数 =", "$roop_time\n";
						print UNROLLED "$program_temp";
						print "展開した後の変数は","$program_temp";
						my @string1 = split(/\(/, $program_temp); #crest変数の宣言用に
						my @string2 = split(/<=|>=|==|<|>|!=/,$string1[1]);
						#print "展開した後の変数は","$string2[0]\n";
						if($string2[0] !~ /\)/){
							print VARIABLE "$string2[0]\n";
						}
					}
					else{
						print UNROLLED "$program[$for_roop]";
					}
				}

				#対象の配列が含まれていなかったら
				else{
					print UNROLLED "$program[$for_roop]";
				}
			}
			$roop_time++;
			#print "ループ展開がここで終わりました。\n";
		}
	}

}
