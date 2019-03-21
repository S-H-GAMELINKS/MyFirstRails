# PWA
## 概要

Railsに初めて触れる方を対象にしたチュートリアルです

`PWA`というWebアプリをスマホやPCへインストールできるようにする機能をRailsに導入するチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new himl
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd himl
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

### ScaffoldでCRUDを作成

`rails g scaffold` コマンドを使い、CRUDを作成します

```shell
rails g scaffold post title:string content:text
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

### PWA化

まず、`serviceworker-rails`を`Gemfile`に追加します

```ruby:Gemfile
gem 'serviceworker-rails'
```

その後、`bundle install`を実行します

```shell
bundle install
```

最後に、以下のコマンドを実行すればPWA化は完了です！

```shell
rails g serviceworker:install
```

