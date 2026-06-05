# Attribution & Acknowledgments

## 元論文

このプロジェクトは以下の学術論文を基礎としています：

```
Ichiya SADAKATA
"32-bit FORTH in a Web Server"
北海道医療大学看護福祉学部紀要, No.11, pp.59-65, 2004年
```

### 論文への敬意

元論文は 2004 年に発表された、当時の Windows 環境での FORTH Web サーバの実装報告です。
本プロジェクトは：

1. **論文の設計思想を継承** — block file を 1024 バイト / 16×64 桁の構造で管理する設計
2. **モダン環境へ移植** — Windows + Perl から gforth + Ruby + Git へ
3. **セキュリティモデルの刷新** — 学内イントラ想定から SSH/Tailscale による接続制限へ

---

## 移植上の判断と変更点

### 継承した設計

- **Block file format** (1024バイト / スクリーン)
- **gforth の block wordset** との互換性
- **ユーザーインターフェース** の基本構造（textarea + Run ボタン）

### 置き換えた部分

| 元版（Perl/Windows） | 本版（Ruby/Linux） | 理由 |
|---|---|---|
| forth32l.exe | gforth | オープンソース・ヘッドレス対応 |
| Perl + jcode.pl | Ruby 3.1 + UTF-8 | 現代的言語・依存管理 |
| GUI 窓出力 | stdout キャプチャ | サーバ環境での実装可能性 |
| Apache CGI | Sinatra + systemd | 標準化・メンテナンス性 |
| ハードコードパス | 相対パス + Git | デプロイの可搬性 |

### セキュリティの強化

元論文は学内イントラネット想定でしたが、本版は：

- **localhost のみ** にバインド（外部公開禁止）
- **SSH トンネル / Tailscale** 経由でのアクセス
- **タイムアウト設定** (5秒)
- **非特権ユーザ** での実行推奨
- **ulimit 制限** 推奨

---

## 謝辞

1. **Ichiya SADAKATA 氏** — 元論文の執筆と、FORTH Web サーバの実装報告
2. **gforth コミュニティ** — オープンソースの FORTH 実装
3. **Ruby / Sinatra コミュニティ** — シンプルで堅牢な Web フレームワーク

---

## ライセンス

このプロジェクト（コード部分）は MIT License の下で公開されています。  
ただし元論文との関連性を明記する必要があります（詳細は LICENSE を参照）。

研究・学習目的での利用を歓迎します。  
商用利用や派生版の公開時は、元論文の著者への通知をお願いします。
