# DXOpalの実行環境！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`DXOpal`](https://github.com/activerecord-hackery/ransack)を使用した`DXOpal`の実行環境構築チュートリアルになります

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
