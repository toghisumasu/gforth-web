# gforth-web — forth32.cgi の gforth / Ruby 移植

2004 年の `forth32.cgi`（Perl + Windows の forth32l.exe）を、
**gforth + 標準出力キャプチャ** に置き換えたもの。GUI 窓に依存しないため
ヘッドレスな EC2 でそのまま動く。

## ファイル構成

| ファイル        | 役割 |
|-----------------|------|
| `run.fs`        | testhtml.blk の block1 を `load` する gforth ローダ |
| `forth_test.sh` | ステップ1-2：gforth 単体確認（Ruby 不要） |
| `app.rb`        | Sinatra 版本体（Perl CGI の移植） |
| `Gemfile`       | sinatra / puma / rackup |

## 前提

- gforth（Ubuntu: `sudo apt install gforth` / Amazon Linux: EPEL かソースビルド）
- Ruby 3.1.x + bundler
- `timeout`（coreutils。通常は同梱）

---

## ステップ1-2：まず gforth を動かす（最初の目標）

Ruby を被せる前に、これを必ず通す。

```bash
chmod +x forth_test.sh
./forth_test.sh
```

期待出力：

```
== ステップ1 ==
hello from gforth
5
== ステップ2 ==
factorial 5 = 120
```

ここまで通れば「gforth が Web 経由で結果を返す」土台は完成。

## ステップ3：Sinatra 版を被せる

```bash
bundle install --path vendor/bundle
bundle exec ruby app.rb
```

`http://127.0.0.1:4567/` でフォームが開く。

### EC2 でのアクセス方法（重要）

このツールは **訪問者の任意 Forth コードをサーバ上で実行する**。
gforth は `system` やファイル語にフルアクセスできるため、実質リモートシェル。
よって `app.rb` は **localhost のみにバインド**してある。外部公開は禁物。

手元の Mac / iPad からは SSH トンネルか Tailscale 経由で繋ぐ：

```bash
# SSH ポートフォワード（Termius でも同様の設定で可）
ssh -L 4567:127.0.0.1:4567 ec2-user@<EC2のIP>
# → ブラウザで http://127.0.0.1:4567/
```

さらに堅くするなら：専用の非特権ユーザで起動、コンテナ/jail に隔離、
`ulimit` でメモリ・プロセス数制限、ネットワーク遮断。

---

## Forth ファンへのメモ（blk の 64 桁規約）

ソースは block1（1024 バイト = 16 行 × 64 桁のスクリーン）として読まれる。
gforth は 64 桁ごとを 1 行として扱うため、`Starting Forth` 流の
「1 スクリーン＝16×64」感覚でそのまま書ける。トークンが 64 桁境界を
またぐと崩れる点だけ注意。

### blk をやめて素の .fs にしたい場合

gforth は普通のテキストも読める。ブロック規約が煩わしければ、
`app.rb` の `run_forth` を以下に差し替えるだけ：

```ruby
def run_forth(source)
  src = File.join(APP_DIR, "user.fs")
  File.write(src, source.to_s)
  out, _ = Open3.capture2e("timeout", TIMEOUT, "gforth", src, chdir: APP_DIR)
  out
rescue Errno::ENOENT
  "gforth または timeout が見つかりません。"
end
```

64 桁・パディングの制約から解放されるが、blk の趣は失われる。
評価者が Forth ファンなら、まずは blk 版で見せるのがおすすめ。

---

## 参考文献・謝辞

このプロジェクトは以下の論文を参考に、gforth + Ruby へ移植・改造したものです。

**[元論文]**
- Ichiya SADAKATA, "32-bit FORTH in a Web Server",  
  *北海道医療大学看護福祉学部紀要* No.11, pp.59-65, 2004.

### 主な設計変更

| 項目 | 元版（2004） | 本版（移植） |
|------|------------|-----------|
| FORTH処理系 | forth32l.exe (Windows) | gforth (Linux/macOS) |
| 制御言語 | Perl CGI | Ruby/Sinatra |
| 出力方式 | GUI窓 | stdout キャプチャ |
| デプロイ | Apache CGI-BIN | Git + systemd + Nginx |
| セキュリティ | 学内イントラ想定 | SSH/Tailscale トンネル必須 |

元論文の block file 設計（1024バイト境界、16×64桁スクリーン）は  
そのまま踏襲し、gforth の標準 block wordset と互換性を保ちました。

詳細は [ATTRIBUTION.md](./ATTRIBUTION.md) を参照。
