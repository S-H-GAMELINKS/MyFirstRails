# Gonの導入
## 概要

Railsに初めて触れる方を対象にしたチュートリアルです

[`gon`](https://github.com/gazay/gon)というRubyのコードからJavaScriptへと変数を簡単に渡せる`gem`を導入するチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new gon_sample
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd gon_sample
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

### Viewの作成

`rails g controller`コマンドを使用して、`View`を作成します

```shell
rails g controller web index
```

その後、`config/routes.rb`を編集します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

`View`の作成はこれでOKです！

### gonの導入

まず、`Gemfile`に`gem 'gon'`を追加します

```ruby:Gemfile
gem 'gon'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`app/views/layouts/application.html.erb`の`<head>`タグ内に以下のコードを追加します

```erb:app/views/layouts/application.html.erb
<%= include_gon %>
```

その後、`app/controllers/web_controller.rb`の`index`アクションを以下のようにします


```ruby:app/controllers/web_controller.rb
def index
    gon.hogehoge = "hogehoge"
end
```

最後に、`app/assets/javascripts/application.js`に以下のコードを追加します

```js:app/assets/javascripts/application.js
alert(gon.hogehoge);
```

あとは、`rails s`を実行して、ローカルサーバを起動します

```shell
rails s
```

`localhost:3000`にアクセスし、ポップアップで`hogehoge`と表示されていれば`gon`の導入はOKです！