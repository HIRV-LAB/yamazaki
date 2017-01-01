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
	#/*hogehoge*/のように一行でコメントが完結している場合(行頭、行中、行末の全てにおいて) 今のところうまく動いていない！！
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

print "type your new file name\n";
$file = <STDIN>;
utf8::decode($file);
chomp($file);
open(UNROLLED, ">", "$file") or die("Error:$!");

&roop_unrolling();


#ネストされたfor分を検出、処理する関数

sub roop_unrolling{
	for($n_of_lines = 1; $n_of_lines < $num; $n_of_lines++){

		#print "現在", $n_of_lines, "行目\n";
		if($program[$n_of_lines] =~ /for/){
			my $val = $program[$n_of_lines]; #対象行の一次保存
			$val =~ /\((.+)\s=/; #ループ展開が必要な可能性がある変数の特定 for(i=0; ~)の i等 (から" "=にマッチする文字列を抽出
			print "展開の必要な可能性のある変数は", $1, "です\n";
			$unroll_val = $1;

			$counter_flag = 0;
			#ループ展開する回数をfor( ~ ; i < 60; ~ )から抽出する処理
			if($program[$n_of_lines] =~ /(;.*;)/ ){
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
			}

			while(1){
				if($program[$n_of_lines] !~ /{/){
					$n_of_lines++;
				}
				else{
					last;
				}
			}
			#$1にはfor文から抽出した変数が存在している　
			#とりあえずどこまでがforループの処理なのかを特定し、

				#ここのforループの処理のみサブルーチン化する
				$if_start[$start] = $n_of_lines + 1; #次の行からforループの処理が始まる
				$roop_line[$k] = 1;
				for ($for_count = $n_of_lines + 1; $roop_line[$k] > 0; $for_count++){
					#forループの中にif文の条件式にループ展開が必要な変数が存在するのかを判定する
					if($program[$for_count] =~ /if.*[$unroll_val].*/){
						#ループ展開が必要な変数があれば、フラグを立てる
						$variable[$v] = $unroll_val;
						$flag = 1;
					}

					if($program[$for_count] =~ /switch.*[$unroll_val].*/){
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
				#forループの検出処理が終わったら、そこの行数はスキップする処理
			#}

			#{がなかった場合の処理を書く	

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

			if($roop_flag == 0){
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

			#指定された回数だけループ展開を行う
			for($l = 0; $l < $unroll_time[$n_of_lines]; $l++){
				#for文の中の処理のみ繰り返して出力する
				#内部でのループカウンタ(なぜかうまいこと$lが動いていないため)
				for($for_roop = $if_start[$start]; $for_roop < $for_count -1; $for_roop++){ 
					#対象の配列が含まれていたら
					if($program[$for_roop] =~ /$unroll_val/){

						my $program_temp = $program[$for_roop];
						$program_temp =~ s/\[$unroll_val\]/\[$roop_time\]/m;
						#print "ループ展開回数 =", "$roop_time\n";
						print UNROLLED "$program_temp";
						#$roop_time++;
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

		else{
			#for文が検出されなかった場合はそのまま書き込む
			#print "for文が検出されなかったので、そのまま書き込む\n";
			print UNROLLED "$program[$n_of_lines]";
		}
	}	
}
