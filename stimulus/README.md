# Blog サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
RailsとVue.jsを使ってSPA(シングルページアプリケーション)のサンプルを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new stimulus --webpack=stimulus
```

`--webpack`はRailsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用するというオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回は[`Stimulus`]()を使用するので`--webpack=stimulus`としています

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd stimulus
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

### Stimulusでリアルタイムプレビューを実装

まず、`app/javascript/controllers/post_controller.js`を作成します

```js:app/javascript/controllers/post_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["title", "content", "preview"]

    content() {
        this.previewTarget.innerHTML = this.contentTarget.value
    }
}
```

次に、`app/views/posts/_form.html.erb`を以下のように編集します

```
<div  data-controller="post">
  <div class="form-left">
    <%= form_with(model: post, local: true) do |form| %>
      <% if post.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>

          <ul>
            <% post.errors.full_messages.each do |message| %>
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
        <%= form.text_field :content, 'data-target': 'post.content', 'data-action': 'input->post#content' %>
      </div>

      <div class="actions">
        <%= form.submit %>
      </div>
    <% end %>
  </div>

  <div class="form-right">
    <h1>Content</h1>
    <div data-target="post.preview"></div>
  </div>
</div>

<%= javascript_pack_tag 'application.js' %>
```

最後に、`app/assets/stylesheets/posts.css`を以下のように修正します

```css:app/assets/stylesheets/posts.css
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

最後に、`app/views/posts/_form.html.erb`、`app/views/posts/show.html.erb`を以下のように変更します。

```erb:app/views/posts/_form.html.erb
<div  data-controller="post">
  <div class="form-left">
    <%= form_with(model: post, local: true) do |form| %>
      <% if post.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>

          <ul>
            <% post.errors.full_messages.each do |message| %>
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
        <%= form.hidden_field :content, id: :content_text %>
        <trix-editor input="content_text" data-target="post.content", data-action="input->post#content"></trix-editor>
      </div>

      <div class="actions">
        <%= form.submit %>
      </div>
    <% end %>
  </div>

  <div class="form-right">
    <h1>Content</h1>
    <div data-target="post.preview"></div>
  </div>
</div>

<%= javascript_pack_tag 'application.js' %>
```

```erb:app/views/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @post.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @post.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<%= link_to 'Edit', edit_post_path(@post) %> |
<%= link_to 'Back', posts_path %>
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
  <%= link_to "Stimulus", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      Menu
    </button>
    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
      <%= link_to 'Posts', posts_path, class: "dropdown-item" %>
    </div>
  </div>
</nav>
```

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>Stimulus</title>
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