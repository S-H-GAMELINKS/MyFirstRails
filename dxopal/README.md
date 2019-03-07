# DXOpalの実行環境！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`DXOpal`](https://github.com/yhara/dxopal)を使用した`DXOpal`の実行環境構築チュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new dxopal
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd dxopal
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

### ScaffoldでCRUDのひな型作成

`rails g scaffold`を使い、`DXOpal`のソースコードを管理する`Model`などを作成します

```shell
rails g scaffold code title:string content:string
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate
```

### ace-editorの導入

[`ace-rails-ap`](https://github.com/codykrieger/ace-rails-ap)という`gem`を使い、Aceエディターを使用します

まず`Gemfile`に必要な`gem`を追加します

```ruby:Gemfile
gem 'ace-rails-ap'
gem 'jquery-rails'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`app/assets/javascripts/application.js`に以下の4行を追加します

```js:app/assets/javascripts/application.js
//= require jquery
//= require ace-rails-ap
//= require ace/theme-monokai
//= require ace/mode-ruby
```

次に、`app/views/codes/_form.html.erb`でエディターを使用したいところを以下のようにします

```erb:_form.html.erb
  <div class="field">
    <%= form.label :content %>
    <%= form.text_area :content, id: 'ruby_code' %>
    <div id="editor" class="inner"></div>
  </div>
```

その後、`app/assets/javascripts/codes.coffee`でエディターを表示し、その内容を`text_area`に格納できるようにします

```coffee:app/assets/javascripts/codes.coffee
$(document).on 'turbolinks:load', ->
  if !($('#editor').length) then return false
  editor = ace.edit('editor')
  textarea = $('#ruby_code').hide()
  editor.setTheme('ace/theme/monokai')
  editor.getSession().setMode('ace/mode/ruby')
  editor.getSession().setValue(textarea.val())
  editor.getSession().on('change', -> 
    textarea.val(editor.getSession().getValue()))
```

これでOKと行きたいところですが、このままだとエディターの高さがなく、エディターがブラウザ上で表示されません

そこで、`CSS`の`.inner`を`app/assets/stylesheets/codes.scss`を以下のように変更します

```scss:app/assets/stylesheets/codes.scss
.inner {
    height:300px;
    padding-right:0;
    padding-left: 0;
    background-color: #ccc;
  }
```

これでエディターを使用することができます！

### DXOpalの導入

さて、最後に[`DXOpal`](https://github.com/yhara/dxopal)を導入します

[`こちら`](https://github.com/yhara/dxopal/blob/master/build/dxopal.min.js)から`dxopal.min.js`をダウンロードします

ダウンロードした`dxopal.min.js`を`app/assets/javascripts`フォルダ内に移動します

その後、`app/assets/javascripts/application.js`に以下の一行を追加します

```js:app/assets/javascripts/application.js
//= require dxopal.min
```

その後、`Gemfile`に以下の二行を追加し、`bundle update`と`bundle install`を実行します

```ruby:Gemfile
gem 'dxopal'
gem 'thor', '>= 0.19.1'
```

```shell
bundle update
bundle install
```

次に、`app/views/codes/show.html.erb`に以下の内容を追加します

```erb:app/views/codes/show.html.erb
<script type="text/ruby">
  require 'native'
  DXOpal.dump_error{ require_remote String($$.location.pathname) + "/code" }
</script>

<canvas id="dxopal-canvas"></canvas>
<div id="dxopal-errors"></div>
<input type='button' id='pause' value='Pause/Resume'>
```

最後に、`config/routes.rb`に`/codes/:id/code`へのルーティングを追加し、`app/controllers/codes_controller.rb`に`code`アクションを作成します

```ruby:config/routes.rb
get '/codes/:id/code', to: 'codes#code'
```

```ruby:app/controllers/codes_controller.rb
def code
    render json: @code.content
end
```

これで`DXOpal`でのオンライン実行環境がRailsで構築できました！