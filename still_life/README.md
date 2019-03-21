# still_lifeの導入
## 概要

Railsに初めて触れる方を対象にしたチュートリアルです

[`still_life`](https://github.com/amatsuda/still_life)というsystemテスト実行時に表示されたHTMLをログとして保存できる`gem`を導入するチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new still_life
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd still_life
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

### still_lifeの導入

それでは`still_life`を導入したいと思います！

まず、`Gemfile`に`gem 'still_life'`を追加します

```ruby:Gemfile
gem 'still_life'
```

次に、`chromedriver-helper`のバージョンを指定します

```ruby:Gemfile
gem 'chromedriver-helper', '1.2.0'
```

その後、`bundle install`を実行します

```shell
bundle intall
```

あとは、以下のコマンドを実行します

```shell
rails test:system test STILL_LIFE=rails52
```

`tmp/rails52/test`ディレクトリ以下にテスト時のHTMLがログとして保存されています

また、コードの変更も差分として残してくれるのでテスト時の画面を確認するのに重宝します！