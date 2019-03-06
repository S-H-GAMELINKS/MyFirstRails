# DXOpalの実行環境！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`DXOpal`](https://github.com/activerecord-hackery/ransack)を使用した`DXOpal`の実行環境構築チュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new dxopal
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd dxopal
```

### SQLite3のバージョン修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを指定してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```
