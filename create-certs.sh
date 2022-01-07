#!/bin/bash -xe
# certs ディレクトリ以下に証明書を作成する

# ローカル環境に認証局を作成済みとする
# mkcert -install

cd $(dirname $0)

rm -rf certs
mkdir -p certs

cd certs
# ワイルドカードを指定する場合、ダブルクォーテーション（“”）で囲む必要がある
mkcert "*.dev01.dev" dev01.dev

# _wildcard.dev01.dev+1.pem と _wildcard.dev01.dev+1-key.pem が作成される
# ”+1″ はその他1つのドメインが指定されているという意味
