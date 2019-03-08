# SweetAlert導入サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`sweetalert-rails`](https://github.com/sharshenov/sweetalert-rails)という綺麗な`alert`を表示してくれる`gem`を導入するチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new sweetalert
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd sweetalert
```

### SQLite3のバージョンを修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを修正します

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```

これでOKです！

### Viewの作成

`rails g controller`コマンドを使用して、`View`を作成します

```shell
rails g controller web index
```

その後、`config/routes.rb`を編集します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  get 'web/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

`View`の作成はこれでOKです！

### SweetAlertの導入

それでは`SweetAlert`を導入していきたいと思います

まず、`Gemfile`に`gem 'sweetalert-rails'`を追加します

```ruby:Gemfile
gem 'sweetalert-rails'
```

その後、`bundle install`を実行します

そして、`app/assets/javascripts/application.js`に以下のコードを追加します

```js:app/assets/javascripts/application.js
//= require sweetalert
```

次に、`app/assets/stylesheets/application.css`に以下のコードを追加します

```css:app/assets/stylesheets/application.css
*= require sweetalert
```

これで`SweetAlert`を使えるようになりました！

最後に、`app/views/web/index.html.erb`に以下のコードを追加します

```erb:app/views/web/index.html.erb
<script type="text/javascript">
    sweetAlert("Hello Ruby on Rails!")
</script>
```

あとは、`rails s`を実行し、`localhost:3000`にアクセスしてください

画面に`Hello Ruby on Rails!`と表示されていればOkです！