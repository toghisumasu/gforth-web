# frozen_string_literal: true
# forth32.cgi（Perl）の Ruby/Sinatra 移植版。
# 2004年版が forth32l.exe の GUI 窓に出していた結果を、gforth の標準出力で受け取る。

require "sinatra"
require "open3"

APP_DIR  = __dir__
DATAFILE = File.join(APP_DIR, "testhtml.blk")
LOADER   = File.join(APP_DIR, "run.fs")
BLOCK    = 1024
TIMEOUT  = "5" # 秒。任意コード実行のため必須。

# 安全策：外部公開せず localhost のみ。EC2 では SSH トンネル / Tailscale 経由で使う。
set :bind, "127.0.0.1"
set :port, 4567

# ソースを blk 構造（block0=空白 / block1=ソース）に整形して書き込む。
# バイト列(.b)で扱い、日本語コメント混在でも 1024 バイト境界を保つ。
def write_blk(source)
  src    = source.to_s.gsub(/\r\n|\r|\t/, " ").b
  block1 = src[0, BLOCK].to_s.ljust(BLOCK, " ".b)
  File.binwrite(DATAFILE, (" ".b * BLOCK) + block1)
end

# gforth で block1 を load し、標準出力＋標準エラーをまとめて取得。
def run_forth(source)
  write_blk(source)
  out, _status = Open3.capture2e("timeout", TIMEOUT, "gforth", LOADER, chdir: APP_DIR)
  out
rescue Errno::ENOENT
  "gforth または timeout コマンドが見つかりません。インストールを確認してください。"
end

get "/" do
  erb :form, locals: { result: nil }
end

post "/" do
  erb :form, locals: { result: run_forth(params["source"]) }
end

__END__

@@ form
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <title>FORTH on gforth</title>
  <style>
    body { background:#008080; color:#000; font-family:monospace; }
    h1 { text-align:center; color:#fff; }
    .center { text-align:center; }
    textarea { font-family:monospace; }
    pre { background:#fff; padding:1em; max-width:64ch; margin:1em auto;
          white-space:pre-wrap; word-break:break-all; }
  </style>
</head>
<body>
  <h1>FORTH on gforth</h1>
  <form method="post" action="/">
    <div class="center">
      <textarea name="source" cols="64" rows="20"
                placeholder='例:  ." hello" cr  2 3 + . cr'></textarea><br>
      <input type="submit" value="Run">
      <input type="reset"  value="Clear">
    </div>
  </form>
  <% if result %>
    <pre>SCR #1 結果:
<%= Rack::Utils.escape_html(result) %></pre>
  <% end %>
</body>
</html>
