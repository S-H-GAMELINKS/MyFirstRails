# 小説投稿サイト サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

ログイン機能もある小説投稿サイトを作成するチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsのひな型を作成します

```shell
rails new novel_post --webpack=stimulus
```

`--webpack`はRailsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用するというオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回は[`Stimulus`](https://github.com/stimulusjs/stimulus)を使用するので`--webpack=stimulus`としています
ちなみに、`Stimulus`はRailsの生みの親であるDHH氏がCTOを務める[`Basecamp`](https://basecamp.com/)が開発したJavaScriptフレームワークです
非常にシンプルで動きのあるWebを実現できます

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd novel_post
```

### Foremanを使う

[`Webpacker`](https://github.com/rails/webpacker)を使う場合、`ruby ./bin/webpack-dev-server`というコマンドを実行しつつ、`rails s`でローカルサーバーを起動する必要があります

その為、現状のままではターミナルを複数開いておく必要があり、少々面倒です

そこで、複数のコマンドを並列して実行できる[`foreman`](https://github.com/ddollar/foreman)を使用します

まず、`Gemfile`に`gem 'foreman'`を追記します

```ruby:Gemfile
gem 'foreman'
```

その後、`bundle install`

```shell
bundle install
```

次に、`foreman`で使用する`Procfile.dev`を作成します

```Procfile.dev
web: bundle exec rails s
webpacker: ruby ./bin/webpack-dev-server
```

あとは、`foreman start -f Procfile.dev`をターミナルで実行するだけです

```shell
foreman start -f Procfile.dev
```

`localhost:5000`にアクセスできればOkです(`foreman`を使用する場合、使用するポートが5000へと変更されています)

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

### ScaffoldでCRUDを作成

`rails g scaffold` コマンドを使い、質問投稿のひな型を作成します

```shell
rails g scaffold novel title:string content:text
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

`config/routes.rb`を修正し、`root`へのルーティングを作成します

```ruby:config/routes.rb

Rails.application.routes.draw do
  root 'novels#index'
  resources :novels
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

あとは`foreman start -f Procfile.dev`を実行して、`localhost:5000`にアクセスします
ページが表示されていればOKです

### コメント機能の作成

質問投稿サイトですので、コメントを投稿できるようにしたいと思います

まず、コメントを取り扱う`Comment`モデルを作成します。

```shell
rails g model comment content:text novel:references
```

マイグレーションを行います

```shell
rails db:migrate
```

`app/models/novel.rb`に`Comment`との関連付けを記述します

```ruby:app/models/novel.rb
class Novel < ApplicationRecord
    has_many :comments
end
```

そして、`config/routes.rb` にてルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
　root 'novels#index'
  resources :novels do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

次に、各質問へのコメントフォームを作成していきます。

まずは下記のように`app/views/novels/show.html.erb`を変更します

```erb:app/views/novels/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @novel.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= @novel.content %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @novel.comments %>
  </div>

<%= render 'comments/new', novel: @novel %> 

<%= link_to 'Edit', edit_novel_path(@novel) %> |
<%= link_to 'Back', novels_path %>
```

変更箇所としてはこの部分になります

```erb
<h2>Comments</h2>
  <div id="comments">
    <%= render @novel.comments %>
  </div>

<%= render 'comments/new', novel: @novel %> 
```

`<%= render @novel.comments %>` の部分でコメントを一覧できるviewファイルをパーシャルとして呼び出しています

また、`<%= render 'comments/new', novel: @novel %> `の部分では新規作成するコメントのviewファイルをパーシャルとして呼び出しています

パーシャルとして呼び出している部分をそれぞれ作っていきます

まず、`app/views/comments/_comment.html.erb` を作成し、下記のようにします。

```erb:app/views/comments/_comment.html.erb
<p><%= comment.content %></p>
<p><%= link_to "Delete", [@novel, comment], method: :delete, data: { confirm: 'Are you sure?' } %>
```

次に、`app/views/comments/_new.html.erb`を作成します

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @novel, Comment.new ], remote: true) do |form| %>
    Your Comment:<br>
    <%= form.text_area :content, size: '50x20' %><br>
    <%= form.submit %>
<% end %>  
```

これで、コメントの入力フォームが表示されるようになっているはずです

次に、コメントの作成と削除を行うアクションを作成します

`app/controllers/comments_controller.rb`を作成します

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_novel

    def create
        @post.comments.create! comments_params
        redirect_to @novel
    end

    def destroy
        @post.comments.destroy params[:id]
        redirect_to @novel
    end

     private
        def set_novel
            @post = Novel.find(params[:novel_id])
        end

         def comments_params
            params.required(:comment).permit(:content)
        end
end
```

`foreman start -f Procfile.dev` でローカルサーバを建てて、実際にコメントが作成&削除できていればOKです。

### Stimulusでリアルタイムプレビューを実装

まず、`app/javascript/controllers/novel_controller.js`を作成します

```js:app/javascript/controllers/novel_controller.js
import { Controller } from "stimulus"

 export default class extends Controller {
    static targets = ["content", "preview"]

     content() {
        this.previewTarget.innerHTML = this.contentTarget.value
    }
} 
```

次に、`app/views/novels/_form.html.erb`を以下のように編集します

```erb:app/views/novels/_form.html.erb
<div  data-controller="novel">
  <div class="form-left">
    <%= form_with(model: novel, local: true) do |form| %>
      <% if novel.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(novel.errors.count, "error") %> prohibited this novel from being saved:</h2>

          <ul>
            <% novel.errors.full_messages.each do |message| %>
              <li><%= message %></li>
            <% end %>
          </ul>
        </div>
      <% end %>

      <div class="field">
        <%= form.label :title %>
        <%= form.text_field :title %>
      </div>

      <div class="field">
        <%= form.label :content %>
        <%= form.text_area :content, 'data-target': 'novel.content', 'data-action': 'input->novel#content'  %>
      </div>

      <div class="actions">
        <%= form.submit %>
      </div>
    <% end %>
  </div>

  <div class="form-right">
    <h1>Content</h1>
    <div data-target="novel.preview"></div>
  </div>
</div>
  
<%= javascript_pack_tag 'application.js' %>
```

最後に、`app/assets/stylesheets/novels.scss`を以下のように修正します

```app/assets/stylesheets/questions.scss
// Place all the styles related to the posts controller here.
// They will automatically be included in application.css.
// You can use Sass (SCSS) here: http://sass-lang.com/

.form-left{
    width: 50%;
    float: left;
}

.form-right{
    width: 50%;
    float: right;
}
```

これでリアルタイムプレビュー機能が実装できました！

### Trixでリッチなテキストエディターを使う

`trix`を`Gemfile`に追加します

```ruby:Gemfile
gem 'trix'
```

その後、`bundle install` を実行します

```shell
bundle install
```

`bundle install`した後、`app/assets/javascripts/application.js`に`//= require trix`を追加します

```js:app/assets/javascripts/application.js
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require trix
//= require turbolinks
//= require_tree .
```

次に、`app/assets/javascripts/application.css`を`app/assets/javascripts/application.scss`にリネームして以下のように変更します

```scss:app/assets/javascripts/application.scss
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, or any plugin's
 * vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS/SCSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 *= require_tree .
 *= require_self
 */
 @import "trix";
```

` @import "trix";` を追加しただけですね

最後に、`app/views/novels/_form.html.erb`、`app/views/novels/index.html.erb`、
`app/views/novels/show.html.erb`、`app/views/comments/_new.html.erb`、`app/views/comments/_comment.html.erb`を以下のように変更します。

```erb:app/views/novels/_form.html.erb
<div  data-controller="novel">
  <div class="form-left">
    <%= form_with(model: novel, local: true) do |form| %>
      <% if novel.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(novel.errors.count, "error") %> prohibited this novel from being saved:</h2>

          <ul>
            <% novel.errors.full_messages.each do |message| %>
              <li><%= message %></li>
            <% end %>
          </ul>
        </div>
      <% end %>

      <div class="field">
        <%= form.label :title %>
        <%= form.text_field :title %>
      </div>

      <div class="field">
        <%= form.label :content %>
        <%= form.hidden_field :content, id: :novel_content %>
        <trix-editor input="novel_content" data-target="novel.content" data-action="input->novel#content"></trix-editor>
      </div>

      <div class="actions">
        <%= form.submit %>
      </div>
    <% end %>
  </div>

  <div class="form-right">
    <h1>Content</h1>
    <div data-target="novel.preview"></div>
  </div>
</div>
  
<%= javascript_pack_tag 'application.js' %>
```

```erb:app/views/questions/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Novels</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @novels.each do |novel| %>
      <tr>
        <td><%= novel.title %></td>
        <td><%= link_to 'Show', novel %></td>
        <td><%= link_to 'Edit', edit_novel_path(novel) %></td>
        <td><%= link_to 'Destroy', novel, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Novel', new_novel_path %>
```

```erb:app/views/questions/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @novel.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @novel.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @novel.comments %>
  </div>

<%= render 'comments/new', novel: @novel %> 

<%= link_to 'Edit', edit_novel_path(@novel) %> |
<%= link_to 'Back', novels_path %>
```

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @novel, Comment.new ], remote: true) do |form| %>
    Your Comment:<br>
    <%= form.hidden_field :content, id: :novel_comments %>
    <trix-editor input="novel_comments"></trix-editor>
    <%= form.submit %>
<% end %> 
```

```erb:app/views/comments/_comment.html.erb
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<p><%= link_to "Delete", "#{comment.novel_id}/comments/#{comment.id}", method: :delete, data: { confirm: 'Are you sure?' } %> 
```

これで、リッチなテキストエディタが使用できるようになります。

### Bootstrap4の適用

このままではデザインなどが簡素すぎるので`Bootstrap`を使いたいと思います。

まず、`Gemfile`に`gem 'bootstrap', '~> 4.2.1'`と`gem 'jquery-rails'`を追加し、`bundle install`します。

```ruby:Gemfile
gem 'bootstrap', '~> 4.2.1'
gem 'jquery-rails'
```

```shell
bundle install
```

もし、`gem`の依存関係でうまくいかない場合は、`bundle update`を実行してから`bundle install`を実行してください

```shell
bundle update
bundle install
```

その後、`app/assets/javascripts/application.js`と`app/assets/stylesheets/application.scss`を下記のように変更します

```js:app/assets/javascripts/application.js
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require trix
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .
```

```scss:app/assets/stylesheets/application.scss
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, or any plugin's
 * vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS/SCSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 *= require_tree .
 *= require_self
 */
 @import "trix";
 @import "bootstrap";
```

その後、`config/boot.rb`を以下のように修正します

```ruby:config/boot.rb
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

ENV['EXECJS_RUNTIME'] = 'Node'

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
```

これで`Bootstrap`が使用できるようになりました。

最後に、`app/views/layouts/_header.html.erb`を作成し、`app/views/layouts/application.html.erb`でパーシャルとして呼び出します。

```erb:app/views/layouts/_header.html.erb
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <%= link_to "Novel Post", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      Menu
    </button>
    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
      <%= link_to 'Novels', novels_path, class: "dropdown-item" %>
    </div>
  </div>
</nav>
```

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>NovelPost</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= render 'layouts/header'%>
    <div class="container">
      <%= yield %>
    </div>
  </body>
</html>
```

`foreman start -f Procfile.dev`でサーバを起動し、ナビゲーションバーが表示されていればOKです。

### ratyでの小説の評価機能

小説の投稿サイトですので小説の出来に対して評価がつけれるようにしたいと思います

実装には[`raty`](https://github.com/wbotelhos/raty)を使用します

まず、`Comment`モデルに`score`を追加します

```shell
rails g migration AddScoreToComment score:integer
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate
```

次に、`yarn`を使って`raty-js`をインストールします

```shell
yarn add raty-js
```

`app/assets/javascripts/application.js`と`app/assets/stylesheets/application.scss`で`raty-js`を読み込みます

```js:app/assets/javascripts/application.js
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require trix
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require raty-js
//= require turbolinks
//= require_tree .
```

```scss:app/assets/stylesheets/application.scss
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, or any plugin's
 * vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS/SCSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 *= require raty-js/lib/jquery.raty.css
 *= require_tree .
 *= require_self
 */
 @import "trix";
 @import "bootstrap";
```

次に、`app/assets/javascripts/application.js`、`app/controllers/comments_controller.rb`、`app/views/comments/_comment.html.erb`、
`app/views/comments/_new.html.erb`を以下のように変更します

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_novel

    def create
        @comment = @novel.comments.create! comments_params
        @comment.update(:score => params[:score])
        redirect_to @novel
    end

    def destroy
        @novel.comments.destroy params[:id]
        redirect_to @novel
    end

     private
        def set_novel
            @novel = Novel.find(params[:novel_id])
        end

         def comments_params
            params.required(:comment).permit(:content)
        end
end
```

```erb:app/views/comments/_comment.html.erb
<p><%= tag.div('', class: 'score', data: {score: comment.score}) %></p>
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<p><%= link_to "Delete", "#{comment.novel_id}/comments/#{comment.id}", method: :delete, data: { confirm: 'Are you sure?' } %> 

<script>
$(function() {
    $('.score').raty({
        readOnly: true,
        score: $('.score').data('score'),
        starType: 'i'
    })
})
</script>
```

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @novel, Comment.new ], remote: true) do |form| %>
    <div class="novel_rate"></div>
    Your Comment:<br>
    <%= form.hidden_field :content, id: :novel_comments %>
    <trix-editor input="novel_comments"></trix-editor>
    <%= form.submit %>
<% end %>

<script>
$(function() {
    $('.novel_rate').raty({
        score: 5, 
        starType: 'i',
    })
})
</script>
````

これで評価機能が実装できました！

### Deviseでのログイン機能

Railsには[`Devise`](https://github.com/plataformatec/devise)というログイン機能などを簡単に実装できる`gem`があります
今回は`Devise`を使用してログイン機能を実装します

まず、`Gemfile`に`gem devise`を追加します

```ruby:Gemfile
gem 'devise'
```

`Gemfile`に追加後、`bundle install`を実行します

```shell
bundle install
```

`bundle install`実行後、`Devise`のインストールを行います

```shell
rails g devise:install
rails g devise:views
rails g devise users
```

上記のコマンドを簡単に説明すると
- `rails g devise:install`にて`Devise`のインストールを実行しています
- `rails g devise:views`にて`Devise`で使用するViewを作成しています
- `rails g devise users`にて`Devise`で使用するModelを作成しています

Userモデルを作成しましたので、`rails db:migrate`を実行します

```shell
rails db:migrate
```

次に、ナビゲーションバーにログイン画面などへのリンクを追加します

```erb:app/views/layouts/_header.html.erb
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <%= link_to "Novel Post", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Menu
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <%= link_to 'Novels', novels_path, class: "dropdown-item" %>
    <% if user_signed_in? %>
    <%= link_to 'Sign Out', destroy_user_session_path, class: "dropdown-item", method: :delete %>
    <% else %>
    <%= link_to 'Sign Up', new_user_registration_path, class: "dropdown-item" %>
    <%= link_to 'Sign In', new_user_session_path, class: "dropdown-item" %>
    <% end %>
  </div>
</nav>
```

`user_signed_in?`は`Devise`を導入したことでしようできるヘルパーメソッドになります
これだけでユーザーがログインしているかどうかをチェックできます

`<% if user_signed_in? %>`ではユーザーがログインしている状態に表示する内容を記述しています。
`<% else %>`以降はログインしていない場合に表示する内容になります

これでログイン画面へのリンクなどが作成できました

### 本人しか投稿やコメントを削除できないようにしたい

次に、`Novel`や`Comment`と`User`と紐づけて、投稿した本人しか削除できないようにします

`rails g migration`コマンドを使用して新しいカラムを`Novel`と`Comment`に追加します

```shell
rails g migration AddUserToNovel user:references
rails g migration AddUserToComment user:references
```

モデルに新しいカラムを追加したので、`rails db:migrate`でマイグレーションを実行します

```shell
rails db:migrate
```

そして、`app/controllers/novels_controller.rb`、`app/controllers/comments_controller.rb`を下記のように変更します
`app/controllers/novels_controller.rb`、`app/controllers/comments_controller.rb`の`create`アクションで現在ログインしているユーザーの`ID`を保存するようにしています

また、`before_action`で`check_login`を呼び出してログイン状態と投稿者本人かどうかを判定しています
ログインしていない又は投稿者本人でない場合は、`localhost:5000/novels/1/edit`などにアクセスしても`localhost:5000`へとリダイレクトされます

```ruby:app/controllers/novels_controller.rb
class NovelsController < ApplicationController
  before_action :set_novel, only: [:show, :edit, :update, :destroy]
  before_action :check_login, only: [:new, :edit, :create, :update, :destroy]

  # GET /novels
  # GET /novels.json
  def index
    @novels = Novel.all
  end

  # GET /novels/1
  # GET /novels/1.json
  def show
  end

  # GET /novels/new
  def new
    @novel = Novel.new
  end

  # GET /novels/1/edit
  def edit
  end

  # POST /novels
  # POST /novels.json
  def create
    @novel = Novel.new(novel_params)
    @novel.user_id = current_user.id

    respond_to do |format|
      if @novel.save
        format.html { redirect_to @novel, notice: 'Novel was successfully created.' }
        format.json { render :show, status: :created, location: @novel }
      else
        format.html { render :new }
        format.json { render json: @novel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /novels/1
  # PATCH/PUT /novels/1.json
  def update
    respond_to do |format|
      if @novel.update(novel_params)
        format.html { redirect_to @novel, notice: 'Novel was successfully updated.' }
        format.json { render :show, status: :ok, location: @novel }
      else
        format.html { render :edit }
        format.json { render json: @novel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /novels/1
  # DELETE /novels/1.json
  def destroy
    @novel.destroy
    respond_to do |format|
      format.html { redirect_to novels_url, notice: 'Novel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_novel
      @novel = Novel.find(params[:id])
    end

    def check_login
      redirect_to :root if current_user == nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def novel_params
      params.require(:novel).permit(:title, :content)
    end
end
```

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_novel
    before_action :check_login, only: [:edit, :create, :update, :destroy]

    def create
        @comment = @novel.comments.create! comments_params
        @comment.update(:user_id => current_user.id, :score => params[:score])
        redirect_to @novel
    end

    def destroy
        @novel.comments.destroy params[:id]
        redirect_to @novel
    end

     private
        def set_novel
            @novel = Novel.find(params[:novel_id])
        end

        def check_login
            redirect_to :root if current_user == nil
        end

        def comments_params
            params.required(:comment).permit(:content)
        end
end
```


あとは、`app/views/novels/index.html.erb`、`app/views/novels/show.html.erb`、`app/views/comments/_comment.hmtl.erb`、を以下のように変更することで実装は完了です！

`Devise`のヘルパーメソッドの`user_signed_in?`を使うことでログインしているかを判定しています
また`@question.user_id == current_user.id`とすることで投稿した本人かどうかを判定しています

```erb:app/views/novels/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Novels</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @novels.each do |novel| %>
      <tr>
        <td><%= novel.title %></td>
        <td><%= link_to 'Show', novel %></td>
        <% if user_signed_in? && novel.user_id == current_user.id %>
        <td><%= link_to 'Edit', edit_novel_path(novel) %></td>
        <td><%= link_to 'Destroy', novel, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<% if user_signed_in? %>
<%= link_to 'New Novel', new_novel_path %>
<% end %>
```

```erb:app/views/novels/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @novel.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @novel.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @novel.comments %>
  </div>

<% if user_signed_in? %>
<%= render 'comments/new', novel: @novel %> 
<% end %>

<% if user_signed_in? && @novel.user_id == current_user.id %>
<%= link_to 'Edit', edit_novel_path(@novel) %> |
<% end %>
<%= link_to 'Back', novels_path %>
```

```erb:app/views/comments/_comment.hmtl.erb
<p><%= tag.div('', class: 'score', data: {score: comment.score}) %></p>
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<% if user_signed_in? && comment.user_id == current_user.id %>
<p><%= link_to "Delete", [@novel, comment], method: :delete, data: { confirm: 'Are you sure?' } %> 
<% end %>

<script>
$(function() {
    $('.score').raty({
        readOnly: true,
        score: $('.score').data('score'),
        starType: 'i'
    })
})
</script>
```

### ユーザー名を使う

作成した本人だけが削除できるようになりましたが、ユーザー名などが表示されていません

その為、誰が作成したのかがわかりません

そこで、`user`モデルに`name`カラムを追加して作成したユーザー名が表示されるようにします

まず、`rails g migration`コマンドを使用して`User`モデルに`name`を追加します

```shell
rails g migration AddNameToUser name:string
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate
```

次に、`app/controllers/users_controller.rb`、`app/views/users/_form.html.erb`、`app/views/users/edit.html.erb`
`app/views/users/show.html.erb`を作成します

```ruby:app/controllers/users_controller.rb
class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update]

     # GET /users/1
    # GET /users/1.json
    def show
    end

     # GET /users/1/edit
    def edit
    end

     # PATCH/PUT /users/1
    # PATCH/PUT /users/1.json
    def update
      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to @user, notice: 'User name was successfully updated.' }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

     private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

       # Never trust parameters from the scary internet, only allow the white list through.
      def user_params
        params.require(:user).permit(:name)
      end
  end 
```

```erb:app/views/users/_form.html.erb
<%= form_with(model: user, local: true) do |form| %>
    <% if user.errors.any? %>
      <div id="error_explanation">
        <h2><%= pluralize(user.errors.count, "error") %> prohibited this post from being saved:</h2>

         <ul>
        <% user.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
        </ul>
      </div>
    <% end %>

     <div class="field">
      <%= form.label :name %>
      <%= form.text_field :name %>
    </div>

     <div class="actions">
      <%= form.submit %>
    </div>
  <% end %> 
```

```erb:app/views/users/edit.html.erb
<h1>Editing Name</h1>

<%= render 'form', user: @user %>

<%= link_to 'Show', @user %> |
<%= link_to 'Back', root_path %> 
```

```erb:app/views/users/show.html.erb
<%= @user.name %>

 <% if current_user.id == @user.id %>
<%= link_to 'Edit Name', edit_user_path(@user) %>
<% end %> 
```

その後、`config/routes.rb`でルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :users, :only => [:show, :edit, :update]
  root 'novels#index'
  resources :novels do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

`app/views/layouts/_header.html.erb`にプロフィールへのリンクを追加します

```erb:app/views/layouts/_header.html.erb
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <%= link_to "Novel Post", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Menu
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <%= link_to 'Novels', novels_path, class: "dropdown-item" %>
    <% if user_signed_in? %>
    <%= link_to 'Profile', user_path(current_user), class: "dropdown-item" %>
    <%= link_to 'Sign Out', destroy_user_session_path, class: "dropdown-item", method: :delete %>
    <% else %>
    <%= link_to 'Sign Up', new_user_registration_path, class: "dropdown-item" %>
    <%= link_to 'Sign In', new_user_session_path, class: "dropdown-item" %>
    <% end %>
  </div>
</nav>
```

これでユーザー名を設定できるようになりました！

あとは、`Novel`と`Comment`にユーザーの名前を保存できる`auther`カラムを追加します

```shell
rails g migration AddAutherToNovel auther:string
rails g migration AddAutherToComment auther:string
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate
```

あとは、`app/controllers/novels_controller.rb`、`app/controllers/comments_controller.rb`、`app/views/index.html.erb`、
`app/views/novels/show.html.erb`、`app/views/novels/_form.html.erb`、`app/views/comments/_comment.html.erb`、
`app/views/comments/_new.html.erb`を以下のように修正します

```ruby:app/controllers/novels_controller.rb
class NovelsController < ApplicationController
  before_action :set_novel, only: [:show, :edit, :update, :destroy]
  before_action :check_login, only: [:new, :edit, :create, :update, :destroy]

  # GET /novels
  # GET /novels.json
  def index
    @novels = Novel.all
  end

  # GET /novels/1
  # GET /novels/1.json
  def show
  end

  # GET /novels/new
  def new
    @novel = Novel.new
    @novel.auther = current_user.name
  end

  # GET /novels/1/edit
  def edit
  end

  # POST /novels
  # POST /novels.json
  def create
    @novel = Novel.new(novel_params)
    @novel.user_id = current_user.id

    respond_to do |format|
      if @novel.save
        format.html { redirect_to @novel, notice: 'Novel was successfully created.' }
        format.json { render :show, status: :created, location: @novel }
      else
        format.html { render :new }
        format.json { render json: @novel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /novels/1
  # PATCH/PUT /novels/1.json
  def update
    respond_to do |format|
      if @novel.update(novel_params)
        format.html { redirect_to @novel, notice: 'Novel was successfully updated.' }
        format.json { render :show, status: :ok, location: @novel }
      else
        format.html { render :edit }
        format.json { render json: @novel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /novels/1
  # DELETE /novels/1.json
  def destroy
    @novel.destroy
    respond_to do |format|
      format.html { redirect_to novels_url, notice: 'Novel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_novel
      @novel = Novel.find(params[:id])
    end

    def check_login
      redirect_to :root if current_user == nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def novel_params
      params.require(:novel).permit(:title, :content, :auther)
    end
end
```

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_novel
    before_action :check_login, only: [:edit, :create, :update, :destroy]

    def create
        @comment = @novel.comments.create! comments_params
        @comment.update(:user_id => current_user.id, :score => params[:score])
        redirect_to @novel
    end

    def destroy
        @novel.comments.destroy params[:id]
        redirect_to @novel
    end

     private
        def set_novel
            @novel = Novel.find(params[:novel_id])
        end

        def check_login
            redirect_to :root if current_user == nil
        end

        def comments_params
            params.required(:comment).permit(:content, :auther)
        end
end
```

```erb:app/views/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Novels</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Auther</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @novels.each do |novel| %>
      <tr>
        <td><%= novel.title %></td>
        <td><%= novel.auther %></td>
        <td><%= link_to 'Show', novel %></td>
        <% if user_signed_in? && novel.user_id == current_user.id %>
        <td><%= link_to 'Edit', edit_novel_path(novel) %></td>
        <td><%= link_to 'Destroy', novel, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<% if user_signed_in? %>
<%= link_to 'New Novel', new_novel_path %>
<% end %>
```

```erb:app/views/novels/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @novel.title %>
</p>

<p>
  <strong>Auther:</strong>
  <%= @novel.auther %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @novel.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @novel.comments %>
  </div>

<% if user_signed_in? %>
<%= render 'comments/new', novel: @novel %> 
<% end %>

<% if user_signed_in? && @novel.user_id == current_user.id %>
<%= link_to 'Edit', edit_novel_path(@novel) %> |
<% end %>
<%= link_to 'Back', novels_path %>
```

```erb:app/views/novels/_form.html.erb
<div data-controller="novel">
  <div class="form-left">
    <%= form_with(model: novel, local: true) do |form| %>
      <% if novel.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(novel.errors.count, "error") %> prohibited this novel from being saved:</h2>

          <ul>
          <% novel.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
          </ul>
        </div>
      <% end %>

      <div class="field">
        <%= form.label :title %>
        <%= form.text_field :title %>
      </div>

      <div class="field">
        <%= form.label :auther %>
        <%= form.text_field :auther %>
      </div>

      <div class="field">
        <%= form.label :content %>
        <%= form.hidden_field :content, id: :novel_content %>
        <trix-editor input="novel_content" data-target="novel.content", data-action="input->novel#content"></trix-editor>
      </div>

      <div class="actions">
        <%= form.submit %>
      </div>
    <% end %>
  </div>

  <div class="form-right">
    <h1>Content</h1>
    <div data-target="novel.preview"></div>
  </div>
</div>

<%= javascript_pack_tag 'application.js' %>
```

```erb:app/views/comments/_comment.html.erb
<p><%= comment.auther %></p>
<p><%= tag.div('', class: 'score', data: {score: comment.score}) %></p>
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<% if user_signed_in? && comment.user_id == current_user.id %>
<p><%= link_to "Delete", [@novel, comment], method: :delete, data: { confirm: 'Are you sure?' } %> 
<% end %>

<script>
$(function() {
    $('.score').raty({
        readOnly: true,
        score: $('.score').data('score'),
        starType: 'i'
    })
})
</script>
```

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @novel, Comment.new ], remote: true) do |form| %>
    <div class="novel_rate"></div>
    Your Name:<br>
    <%= form.text_field :auther %><br>
    Your Comment:<br>
    <%= form.hidden_field :content, id: :novel_comments %>
    <trix-editor input="novel_comments"></trix-editor>
    <%= form.submit %>
<% end %>

<script>
$(function() {
    $('.novel_rate').raty({
        score: 5, 
        starType: 'i',
    })
})
</script>
```

これで小説を投稿したユーザー名やコメントの作成者の名前が保存されるようになります！
これで小説投稿サイトは完成です！

## ライセンス
[MITライセンス](../LICENSE)