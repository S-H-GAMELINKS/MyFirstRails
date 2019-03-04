# Active Admin での管理画面作成！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[activeadmin](https://github.com/activeadmin/activeadmin)を使用した管理画面作成チュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new activeadmin
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd activeadmin
```
### SQLite3のバージョン修正

先ほどのrails newでsqlite3のインストールがエラーになっている場合は、以下のようにバージョンを指定してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、bundle installを実行します

```shell
bundle install
```

### Scaffoldで管理するモデルとCRUDを作成

`rails g scaffold`を使用し、`Active Admin`で管理する`Model`などを作成します

```shell
rails g scaffold post title:string content:text
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

### ActiveAdminの導入

`Gemfile`に以下の`gem`を追加していきます

```ruby:Gemfile
gem 'activeadmin'

# Plus integrations with:
gem 'devise'
gem 'cancancan'
gem 'draper'
gem 'pundit'
```

その後、`bundle install`を実行します

```shell
bundle install
```

あとは、以下のコマンドを実行するだけです

```shell
rails g active_admin:install
rails db:migrate
rails db:seed
```

最後に、`localhost:3000/admin`にアクセスします

まず、`rails s`でローカルサーバを起動します

```shell
rails s
```

その後、`localhost:3000/admin`にアクセスして以下のアドレスとパスワードを入力します

```
- User: admin@example.com
- Password: password
```

これで`ActiveAdmin`が使えるようになりました！