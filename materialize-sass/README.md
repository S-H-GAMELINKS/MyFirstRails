# Materialize導入サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`Materialize`](https://materializecss.com/)というCSSフレームワークを導入するチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new materialize-sass
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd materialize-sass
```

## SQLite3のバージョンを修正

先ほどのrails newでsqlite3のインストールがエラーになっている場合は、以下のようにバージョンを修正します

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、bundle installを実行します

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

### Materializeの導入

それでは、`Materialize`を導入します

今回は`gem`でインストールするので、[`materialize-sass`](https://github.com/mkhairi/materialize-sass)を使用します

まず、`Gemfile`に追加します

```ruby:Gemfile
# Using materialize-sass
gem 'materialize-sass', '~> 1.0.0'
gem 'jquery-rails
```

`jquery-rails`を追加しているのは、後々でJqueryを使うためです

また、この時`gem 'duktape'`をコメントアウトします

`gem 'duktape'`の影響でエラーが起きてしまうためです

```ruby:Gemfile
gem 'duktape'
```

その後、`bundle install`を実行します

```shell
bundle install
```

その後、`app/assets/javascripts/application.js`に以下のコードを追加します

```js:app/assets/javascripts/application.js
//= require jquery
//= require materialize
```

次に、`app/assets/stylesheets/application.css`を`app/assets/stylesheets/application.scss`にリネームします

リネーム後、以下のコードを追加します

```scss:app/assets/stylesheets/application.css
@import "materialize";
```

最後に、`app/views/web/index.html.erb`に以下のコードを追加してください

```erb:app/views/web/index.html.erb
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"> 
<a onclick="M.toast({html: 'I am a toast'})" class="btn">Toast!</a>

<ul class="collapsible">
<li>
  <div class="collapsible-header"><i class="material-icons">filter_drama</i>First</div>
  <div class="collapsible-body"><span>Lorem ipsum dolor sit amet.</span></div>
</li>
<li>
  <div class="collapsible-header"><i class="material-icons">place</i>Second</div>
  <div class="collapsible-body"><span>Lorem ipsum dolor sit amet.</span></div>
</li>
<li>
  <div class="collapsible-header"><i class="material-icons">whatshot</i>Third</div>
  <div class="collapsible-body"><span>Lorem ipsum dolor sit amet.</span></div>
</li>
</ul>
```

あとは、`rails s`を実行して`localhost:3000`にアクセスしてみてください

これで`Materialize`の導入は完了です！