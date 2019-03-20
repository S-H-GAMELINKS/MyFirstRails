# Himlの導入！
## 概要

Railsに初めて触れる方を対象にしたチュートリアルです

[`himl`](https://github.com/amatsuda/himl)というテンプレートを導入するチュートリアルです

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

### 静的なぺーじを作成

次に、静的なページ作成します

```shell
rails g controller web index
```

次に、`config/routes.rb`にてルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
end
```

### Himlの導入

[`himl`](https://github.com/amatsuda/himl)を導入していきます！

`Gemfile`に`gem 'himl', '0.1.0'`を追加します

```ruby:Gemfile
gem 'himl', '0.1.0'
```

その後、`bundle install`を実行します

```shell
bundle install
```

あとは、`app/views/web/index.html.erb`を`app/views/web/index.html.himl`にリネームして以下のように修正します

```himl:app/views/web/index.html.himl
<h1>
    Web#index
<p>
    Find me in app/views/web/index.html.erb
```

これで`himl`の導入は完了です！
