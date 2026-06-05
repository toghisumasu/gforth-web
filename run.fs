\ run.fs - testhtml.blk の block1 を読み込んで実行する
\ gforth は offset=0 なので、block1 = ファイル先頭から 1024 バイト目。
\ これは Perl/Ruby 側がソースを書き込む位置と一致する。

s" testhtml.blk" open-blocks
1 load
bye
