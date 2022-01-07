
# 概要

SSL証明書を利用したいと考えて、以下の記事を拝見しました。

数分でできる！mkcertでローカル環境へのSSL証明書設定
https://www.hivelocity.co.jp/blog/46149/

この記事の内容を自分で試した記事となります。

# mkcert インストール

```sh
# Mac の場合 Homebrew でインストールできます。
brew install mkcert
# ローカル環境に認証局を作成します。
mkcert -install
```

# certs ディレクトリ以下に証明書を作成する

certs ディレクトリ以下に "*.dev01.dev" の証明書を作成します。

```sh
mkdir -p certs

cd certs
# ワイルドカードを指定する場合、ダブルクォーテーション（“”）で囲む必要がある
mkcert "*.dev01.dev" dev01.dev

# _wildcard.dev01.dev+1.pem と _wildcard.dev01.dev+1-key.pem が作成される
# ”+1″ はその他1つのドメインが指定されているという意味
```

リポジトリでは create-certs.sh で対応しています。

# docker-compose による nginx サーバを立てる

証明書を確認するためサーバ名 sample.dev01.dev で https アクセスを受け付ける nginx サーバを立てます。
リポジトリの conf/default.conf に設定を記載しています。

```sh
$ cat conf/default.conf
server {
    listen       443 ssl http2;
    server_name  sample.dev01.dev;
    ssl  on;

    ssl_certificate     /etc/nginx/ssl/_wildcard.dev01.dev+1.pem;
    ssl_certificate_key /etc/nginx/ssl/_wildcard.dev01.dev+1-key.pem;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
}

$ cat docker-compose.yml
version: '3'
services:
  nginx:
    image: nginx
    ports:
      - 8080:443
    volumes:
      - ./certs:/etc/nginx/ssl
      - ./conf/default.conf:/etc/nginx/conf.d/default.conf

$ docker compose up
```

# 動作確認

curl でアクセスをテストする。名前解決は curl の resolve オプションを利用している。

```sh
$ curl --resolve sample.dev01.dev:8080:127.0.0.1 https://sample.dev01.dev:8080/
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.21.5</center>
</body>
</html>
```

https でアクセスできていることが確認できました。
404 なのは nginx の location 設定がないためです。今回の主目的ではないので意図している挙動です。

ブラウザからアクセスを試す場合は hosts ファイルを編集してください。
