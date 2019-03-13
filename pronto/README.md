# prontoでの自動コードレビュー導入
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`pronto`])()を使用しての自動コードレビュー機能の導入チュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new pronto
```

次に作成したRailsアプリのディレクトリへと移動します

```shell
cd pronto
```

### SQLite3のバージョンを修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを変更します

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```

これでOKです！

### prontoの導入

それでは[`pronto`](https://github.com/prontolabs/pronto)を導入します

`Gemfile`に`pronto`用の`gem`を追加していきます

```ruby:Gemfile
# Using pronto
gem 'pronto'
gem 'pronto-rubocop', require: false
gem 'pronto-flay', require: false
gem 'thor', '<= 2.0'
gem 'rugged', '0.27.7'
```

その後、`bundle install`を実行します

```shell
bundle install
```

最後に、ターミナルで`pronto`を使用します

```shell
bundle exec pronto run
```

これで重複しているコードや似ているコードなどを自動的に読み取ってくれます

