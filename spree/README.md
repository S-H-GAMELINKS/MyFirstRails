# SpreeでのECサイト作成！
## 概要

Railsｍにこれから初めて触れる方を対象としたチュートリアルです

今回は、[`Spree`](https://github.com/spree/spree)を使用したECサイト構築のチュートリアルになります

## チュートリアル
### Railsのひな型を作成する

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new spree
```

次に、作成した`spree`ディレクトリへと移動します

```shell
cd spree
```

### SQLite3のバージョン修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを指定してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

### Spreeの導入

まず、`Gemfile`に必要な`gem`を追加します

```ruby:Gemfile
gem 'spree', '~> 3.7.0'
gem 'spree_auth_devise', '~> 3.5'
gem 'spree_gateway', '~> 3.4'
```

その後、`bundle install`を実行します

```shell
bundle install
```

`bundle install`後、`Spree`のインストールコマンドをを実行します

```shell
rails g spree:install --user_class=Spree::User
rails g spree:auth:install
rails g spree_gateway:install
```

このコマンドを実行している際に、メールアドレスとパスワードの入力を求められます
`ENTER`キーを押した場合は、以下のメールアドレスとパスワードが使用されます

```
ID：spree@example.com
PW：spree123
```

あとは、`rails s`でローカルサーバを起動するだけです

### 日本語化

`localhost:3000/admin`にアクセスします

先ほど設定したメールアドレスとパスワードを入力してログインします

メニューの`CONFIGURATIONS`内にある`General Settings`をクリックし、`Localization Settings`の`AVAILABLE LOCALES`で`日本語`を選択します

これで日本語化が完了です！

また、日本円対応もしたいと思います

`CONFIGURATIONS`内にある`General Settings`をクリックし、`Currency Settings`の`CHOOSE CURRENCY`で`Japanease Yen`を選択します

これで日本円対応も完了です！

