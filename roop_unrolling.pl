#!/usr/local/bin/perl

use strict;
use warnings;
use utf8;
use open ":utf8";
binmode STDIN, ':encoding(utf8)';
binmode STDOUT, ':encoding(utf8)';
binmode STDERR, ':encoding(utf8)';

#print "<<type the program's name>>\n"; 
#標準入力からファイル名を入力
#my $file = <STDIN>;
#今は実験的にlist4-2.cに固定
my $file = "list4-2.c";
utf8::decode($file);
chomp($file);

#ファイルを読み込みモードで読み込む(ORIGINAL_PROGRAM)
open (ORIGINAL_PROGRAM, "<:utf8", "$file") or die "Error:$!";
#open (ORIGINAL_PROGRAM, "<:utf8", "<", "$file") or die "Error:$!";

#プログラムを格納する配列の作成
my @original;
#格納配列の0番目を作成
push(@original, " ");

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
			print "$counter\n"; 
		}
	}

	#行頭が//で始まるコメント行を削除する処理
	elsif($original[$count] =~ m|^//|){
		print COMMENT_DELETED "\n"
	}
	#行の途中から//のコメントを削除する処理
	elsif($original[$count] =~ m|//|){
		my @comment1 = split(m|//|,$original[$count]);
		print COMMENT_DELETED "$comment1[0]\n";
	}
	#/*hogehoge*/のように一行でコメントが完結している場合(行頭、行中、行末の全てにおいて) 今のところうまく動いていない！！
	elsif($original[$count] =~ m|/\*|){
		my @comment2 = split(m|/\*|,$original[$count]); # /* の前後で分割したリスト
		if($comment2[1] =~ m|\*/|){ #
			my @comment3 = split(m|/\*|,$comment2[1]);  
			print COMMENT_DELETED "$comment2[0]\n"; #さすがに行中にコメントを記述するようなコードはないと仮定(コメントを取り除いた前or後の行を出力
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
	}
}
#オリジナルプログラムはこれ以上使わないのでクローズ
close ORIGINAL_PROGRAM;
close COMMENT_DELETED;