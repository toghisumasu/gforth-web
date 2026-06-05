#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "== ステップ1: gforth 起動確認（標準出力が取れるか） =="
gforth -e '." hello from gforth" cr 2 3 + . cr bye'

echo
echo "== ステップ2: blk 構造（block0=空白 / block1=ソース）で実行 =="
printf '%-1024s' '' > testhtml.blk
printf '%-1024s' ': fact5 1 6 1 do i * loop ; ." factorial 5 = " fact5 . cr' >> testhtml.blk

timeout 5 gforth run.fs

echo
echo "OK: ここまで通れば、Sinatra 版（app.rb）に進めます。"
