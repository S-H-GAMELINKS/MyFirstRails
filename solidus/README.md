# SolidusでのECサイト作成！
## 概要

Railsにこれから初めて触れる方を対象としたチュートリアルです

今回は、[`Solidus`](https://github.com/solidusio/solidus)を使用したECサイト構築のチュートリアルになります

## チュートリアル
### Railsのひな型を作成する

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new solidus
```

次に、作成した`solidus`ディレクトリへと移動します

```shell
cd solidus
```

### SQLite3のバージョンを修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを指定してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```

### Solidusの導入

まず、`Gemfile`に`gem 'solidus'`と`gem 'solidus_auth_devise'`を追加します

```ruby:Gemfile
gem 'solidus'
gem 'solidus_auth_devise'
```

また、`gem 'duktape'`をコメントアウトします

```ruby:Gemfile
# gem 'duktape'
```

コメントアウト後、`bundle install`を実行します

```shell
bundle install
```

その後、以下のコマンドを実行します

```shell
bundle exec rails g spree:install
bundle exec rails g solidus:auth:install
bundle exec rake railties:install:migrations
```

`Solidus`でのECサイト構築はこれで完了です！

あとは、`rails s`でローカルサーバを起動します
`localhost:3000`にアクセスし、ECサイトが表示されていればOKです！
