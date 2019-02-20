# 動画配信サイトの作成！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

Railsで動画をアップロードして配信できるWebサイトを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new railstube
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd railstube
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

## ScaffoldでCRUDを作成

`rails g scaffold`コマンドを使い、イラスト投稿のひな型を作成します

```shell
rails g scaffold movie title:string content:text
```

その後、rails db:migrateでマイグレーションを行います

```shell
rails db:migrate
```

`config/routes.rb`を修正し、rootへのルーティングを作成します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'movies#index'
  resources :movies
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

後は、`rails s`を実行して、`localhost:3000`にアクセスします

ページが表示されていればOKです

### 動画投稿機能の作成

先ほど`rails g sacffold`で作成したCRUDでは動画をアップロードするカラムがありませんでした

なぜかというと`Rails 5.2`から導入された[`ActiveStorage`](https://railsguides.jp/active_storage_overview.html)を使用するためです

`ActiveStorage`はRailsの標準機能として導入されたファイルアップロード機能です

早速、`ActiveStorage`をインストールします

```shell
rails active_storage:install
rails db:migrate
```

次に、`Movie`モデルに`ActiveStorage`を使用するためのリレーションを追加します

```ruby:movie.rb
class Movie < ApplicationRecord
    has_one_attached :movie
end
```

その後、`app/controllers/movies_controller.rb`を以下のように編集します

```ruby:app/controllers/movies_controller.rb
class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :content, :movie)
    end
end
```

そして`app/views/movies/_form.html.erb`と`app/views/movies/show.html.erb`を編集します

```erb:app/views/movies/_form.html.erb
<%= form_with(model: movie, local: true) do |form| %>
  <% if movie.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(movie.errors.count, "error") %> prohibited this movie from being saved:</h2>

      <ul>
      <% movie.errors.full_messages.each do |message| %>
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
    <%= form.text_area :content %>
  </div>

  <div class="field">
    <%= form.label :movie %>
    <%= form.file_field :movie %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

```erb:app/views/movies/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @movie.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= @movie.content %>
</p>

<p>
  <strong>movies:</strong>
  <% if @movie.movie.attached? %>
    <% video_tag rails_blob_path(@movie.movie, disposition: "attachment"), :controls => true %>
  <% end %>
</p>

<%= link_to 'Edit', edit_movie_path(@movie) %> |
<%= link_to 'Back', movies_path %>
```

これで投稿を投稿&編集できるようになりました！

### コメント機能の作成

動画投稿サイトですので、感想としてコメントを投稿できるようにしたいと思います

まず、コメントを取り扱う`Comment`モデルを作成します

```shell
rails g model comment content:text movie:references
```

次にマイグレーションを行います

```shell
rails db:migrate
```

`app/models/movie.rb`に`Comment`とのリレーションを追加します

```ruby:app/models/movie.rb
class movie < ApplicationRecord
    has_one_attached :movie
    has_many :comments
end
```

`config/routes.rb`にてルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
　root 'movies#index'
  resources :movies do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

次に、各イラスト投稿にコメントフォームを追加します

```erb:app/views/movies/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @movie.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= @movie.content %>
</p>

<p>
  <strong>movies:</strong>
  <% if @movie.movie.attached? %>
    <% video_tag rails_blob_path(@movie.movie, disposition: "attachment"), :controls => true %>
  <% end %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @movie.comments %>
  </div>

<%= render 'comments/new', movie: @movie %> 

<%= link_to 'Edit', edit_movie_path(@movie) %> |
<%= link_to 'Back', movies_path %>
```

変更箇所としては、この部分になります

```erb:
<h2>Comments</h2>
  <div id="comments">
    <%= render @movie.comments %>
  </div>

<%= render 'comments/new', movie: @movie %> 
```

`<%= render @movie.comments %>`の部分でコメントを一覧できるviewファイルをパーシャルとして呼び出しています

また、<%= render 'comments/new', movie: @movie %> の部分では新規作成するコメントのviewファイルをパーシャルとして呼び出しています

パーシャルとして呼び出している部分をそれぞれ作っていきます

まず、`app/views/comments/_comment.html.erb`を作成し、下記のようにします。

```erb:app/views/comments/_comment.html.erb
<p><%= comment.content %></p>
<p><%= link_to "Delete", [@movie, comment], method: :delete, data: { confirm: 'Are you sure?' } %></p>
```

次に、`app/views/comments/_new.html.erb`を作成します

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @movie, Comment.new ], remote: true) do |form| %>
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
    before_action :set_movie

    def create
        @movie.comments.create! comments_params
        redirect_to @movie
    end

    def destroy
        @movie.comments.destroy params[:id]
        redirect_to @movie
    end

     private
        def set_movie
            @movie = movie.find(params[:movie_id])
        end

         def comments_params
            params.required(:comment).permit(:content)
        end
end
```

`rails s`でローカルサーバを建てて、実際にコメントが作成&削除できていればOKです。

### Trixでリッチなテキストエディターを使う

`trix`を`Gemfile`に追加します

```ruby:Gemfile
gem 'trix'
```

その後、`bundle install`を実行します

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

`@import "trix";`を追加しただけですね

最後に、`app/views/movies/_form.html.erb`、`app/views/movies/index.html.erb`、 `app/views/movies/show.html.erb`、`app/views/comments/_new.html.erb`、`app/views/comments/_comment.html.erb`を以下のように変更します

```erb:app/views/movies/_form.html.erb
<%= form_with(model: movie, local: true) do |form| %>
  <% if movie.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(movie.errors.count, "error") %> prohibited this movie from being saved:</h2>

      <ul>
      <% movie.errors.full_messages.each do |message| %>
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
    <%= form.hidden_field :content, id: :movie_content %>
    <trix-editor input="movie_content"></trix-editor>
  </div>

  <div class="field">
    <%= form.label :movie %>
    <%= form.file_field :movie %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>

```

```erb:app/views/movies/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Movies</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @movies.each do |movie| %>
      <tr>
        <td><%= movie.title %></td>
        <td><%= link_to 'Show', movie %></td>
        <td><%= link_to 'Edit', edit_movie_path(movie) %></td>
        <td><%= link_to 'Destroy', movie, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Movie', new_movie_path %>
```

```erb:app/views/movies/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @movie.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @movie.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<p>
  <strong>movies:</strong>
  <% if @movie.movie.attached? %>
    <% video_tag rails_blob_path(@movie.movie, disposition: "attachment"), :controls => true %>
  <% end %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @movie.comments %>
  </div>

<%= render 'comments/new', movie: @movie %> 

<%= link_to 'Edit', edit_movie_path(@movie) %> |
<%= link_to 'Back', movies_path %>
```

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @movie, Comment.new ], remote: true) do |form| %>
    Your Comment:<br>
    <%= form.hidden_field :content, id: :movie_comments %>
    <trix-editor input="movie_comments"></trix-editor>
    <%= form.submit %>
<% end %>
```


```erb:app/views/comments/_comment.html.erb
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>1
<p><%= link_to "Delete", [@movie, comment], method: :delete, data: { confirm: 'Are you sure?' } %></p>
```

### Bootstrap4の適用

このままではデザインなどが簡素すぎるのでBootstrapを使いたいと思います。

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
  <%= link_to "Rails Tube", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      Menu
    </button>
    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
      <%= link_to 'Movies', movies_path, class: "dropdown-item" %>
    </div>
  </div>
</nav>
```

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>Rails Tube</title>
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

`rails s`でサーバを起動し、ナビゲーションバーが表示されていればOKです

### ratyでの小説の評価機能

イラスト投稿サイトですのでイラストに対して評価がつけれるようにしたいと思います

実装には`raty`を使用します

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

次に、`app/controllers/comments_controller.rb`、`app/views/comments/_comment.html.erb`、 `app/views/comments/_new.html.erb`を以下のように変更します

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_movie

    def create
        @comment = @movie.comments.create! comments_params
        @comment.update(:score => params[:score])
        redirect_to @movie
    end

    def destroy
        @movie.comments.destroy params[:id]
        redirect_to @movie
    end

     private
        def set_movie
            @movie = Movie.find(params[:movie_id])
        end

         def comments_params
            params.required(:comment).permit(:content)
        end
end
```

```erb:app/views/comments/_comment.html.erb
<p><%= tag.div('', class: 'score', data: {score: comment.score}) %></p>
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<p><%= link_to "Delete", [@movie, comment], method: :delete, data: { confirm: 'Are you sure?' } %></p>

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
<%= form_with(model: [ @movie, Comment.new ], remote: true) do |form| %>
    <div class="movie_rate"></div>
    Your Comment:<br>
    <%= form.hidden_field :content, id: :movie_comments %>
    <trix-editor input="movie_comments"></trix-editor>
    <%= form.submit %>
<% end %>

<script>
$(function() {
    $('.movie_rate').raty({
        score: 5, 
        starType: 'i',
    })
})
</script>
```

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
  <%= link_to "Rails Tube", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Menu
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <%= link_to 'Movies', movies_path, class: "dropdown-item" %>
    <% if user_signed_in? %>
    <%= link_to 'Sign Out', destroy_user_session_path, class: "dropdown-item", method: :delete %>
    <% else %>
    <%= link_to 'Sign Up', new_user_registration_path, class: "dropdown-item" %>
    <%= link_to 'Sign In', new_user_session_path, class: "dropdown-item" %>
    <% end %>
  </div>
</nav>
```

`user_signed_in?`は`Devise`を導入したことで使用できるヘルパーメソッドになります
これだけでユーザーがログインしているかどうかをチェックできます

`<% if user_signed_in? %>`ではユーザーがログインしている状態に表示する内容を記述しています。
`<% else %>`以降はログインしていない場合に表示する内容になります

これでログイン画面へのリンクなどが作成できました

### 本人しか投稿やコメントを削除できないようにしたい

次に、`Movie`や`Comment`と`User`と紐づけて、投稿した本人しか削除できないようにします

`rails g migration`コマンドを使用して新しいカラムを`Movie`と`Comment`に追加します

```shell
rails g migration AddUserToMovie user:references
rails g migration AddUserToComment user:references
```

モデルに新しいカラムを追加したので、`rails db:migrate`でマイグレーションを実行します

```shell
rails db:migrate
```

そして、`app/controllers/movies_controller.rb`、`app/controllers/comments_controller.rb`を下記のように変更します
`app/controllers/movies_controller.rb`、`app/controllers/comments_controller.rb`の`create`アクションで現在ログインしているユーザーの`ID`を保存するようにしています

また、`before_action`で`check_login`を呼び出してログイン状態と投稿者本人かどうかを判定しています
ログインしていない又は投稿者本人でない場合は、`localhost:5000/movies/1/edit`などにアクセスしても`localhost:5000`へとリダイレクトされます

```ruby:app/controllers/movies_controller.rb
class moviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :check_login, only: [:new, :edit, :create, :update, :destroy]

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = movie.new(movie_params)
    @movie.user_id = current_user.id

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    def check_login
      redirect_to :root if current_user == nil || @movie.user_id != current_user.id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :content, :movie)
    end
end
```

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_movie
    before_action :check_login, only: [:destroy]

    def create
        @comment = @movie.comments.create! comments_params
        @comment.update(:user_id => current_user.id, :score => params[:score])
        redirect_to @movie
    end

    def destroy
        @movie.comments.destroy params[:id]
        redirect_to @movie
    end

     private
        def set_movie
            @movie = Movie.find(params[:movie_id])
        end

        def check_login
            redirect_to :root if current_user == nil  || @movie.comments.find(params[:id]).user_id != current_user.id
        end

        def comments_params
            params.required(:comment).permit(:content)
        end
end
```

あとは、`app/views/movies/index.html.erb`、`app/views/movies/show.html.erb`、`app/views/comments/_comment.hmtl.erb`、を以下のように変更することで実装は完了です！

`Devise`のヘルパーメソッドの`user_signed_in?`を使うことでログインしているかを判定しています
また`@question.user_id == current_user.id`とすることで投稿した本人かどうかを判定しています

```erb:app/views/movies/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Movies</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @movies.each do |movie| %>
      <tr>
        <td><%= movie.title %></td>
        <td><%= link_to 'Show', movie %></td>
        <% if user_signed_in? && movie.user_id == current_user.id %>
        <td><%= link_to 'Edit', edit_movie_path(movie) %></td>
        <td><%= link_to 'Destroy', movie, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<% if user_signed_in? %>
<%= link_to 'New Movie', new_movie_path %>
<% end %>
```

```erb:app/views/movies/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @movie.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @movie.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<p>
  <strong>movies:</strong>
  <% if @movie.movie.attached? %>
    <% video_tag rails_blob_path(@movie.movie, disposition: "attachment"), :controls => true %>
  <% end %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @movie.comments %>
  </div>

<% if user_signed_in? %>
<%= render 'comments/new', movie: @movie %> 
<% end %>

<% if user_signed_in? && @movie.user_id == current_user.id %>
<%= link_to 'Edit', edit_movie_path(@movie) %> |
<% end %>
<%= link_to 'Back', movies_path %>
```

```erb:app/views/comments/_comment.hmtl.erb
<p><%= tag.div('', class: 'score', data: {score: comment.score}) %></p>
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<% if user_signed_in? && comment.user_id == current_user.id %>
<p><%= link_to "Delete", [@movie, comment], method: :delete, data: { confirm: 'Are you sure?' } %></p>
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

そこで、`User`モデルに`name`カラムを追加して作成したユーザー名が表示されるようにします

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
    before_action :check_login, only: [:edit, :update]

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

      def check_login
        redirect_to :root if current_user == nil || @user.id != current_user.id
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
  root 'movies#index'
  resources :movies do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

`app/views/layouts/_header.html.erb`にプロフィールへのリンクを追加します

```erb:app/views/layouts/_header.html.erb
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <%= link_to "Rails Tube", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Menu
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <%= link_to 'Movies', movies_path, class: "dropdown-item" %>
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

あとは、`Movie`と`Comment`にユーザーの名前を保存できる`auther`カラムを追加します

```shell
rails g migration AddAutherToMovie auther:string
rails g migration AddAutherToComment auther:string
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate
```

あとは、`app/controllers/movies_controller.rb`、`app/controllers/comments_controller.rb`、`app/views/index.html.erb`、
`app/views/movies/show.html.erb`、`app/views/movies/_form.html.erb`、`app/views/comments/_comment.html.erb`、
`app/views/comments/_new.html.erb`を以下のように修正します

```ruby:app/controllers/movies_controller.rb
class moviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :check_login, only: [:new, :edit, :create, :update, :destroy]

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    @comment = Comment.new
    @comment.auther = current_user.name if current_user != nil
  end

  # GET /movies/new
  def new
    @movie = movie.new
    @movie.auther = current_user.name
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = movie.new(movie_params)
    @movie.user_id = current_user.id

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    def check_login
      redirect_to :root if current_user == nil || @movie.user_id != current_user.id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :content, :auther, :movie)
    end
end
```

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_movie
    before_action :check_login, only: [:destroy]

    def create
        @comment = @movie.comments.create! comments_params
        @comment.update(:user_id => current_user.id, :score => params[:score])
        redirect_to @movie1
    end

    def destroy
        @movie.comments.destroy params[:id]
        redirect_to @movie
    end

     private
        def set_movie
            @movie = movie.find(params[:movie_id])
        end

        def check_login
            redirect_to :root if current_user == nil || @movie.comments.find(params[:id]).user_id != current_user.id
        end

        def comments_params
            params.required(:comment).permit(:content, :auther)
        end
end
```

```erb:app/views/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Movies</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Auther</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @movies.each do |movie| %>
      <tr>
        <td><%= movie.title %></td>
        <td><%= movie.auther %></td>
        <td><%= link_to 'Show', movie %></td>
        <% if user_signed_in? && movie.user_id == current_user.id %>
        <td><%= link_to 'Edit', edit_movie_path(movie) %></td>
        <td><%= link_to 'Destroy', movie, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<% if user_signed_in? %>
<%= link_to 'New movie', new_movie_path %>
<% end %>
```

```erb:app/views/movies/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @movie.title %>
</p>

<p>
  <strong>Auther:</strong>
  <%= @movie.auther %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @movie.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<p>
  <strong>movies:</strong>
  <% if @movie.movie.attached? %>
    <% video_tag rails_blob_path(@movie.movie, disposition: "attachment"), :controls => true %>
  <% end %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @movie.comments %>
  </div>

<% if user_signed_in? %>
<%= render 'comments/new', movie: @movie %> 
<% end %>

<% if user_signed_in? && @movie.user_id == current_user.id %>
<%= link_to 'Edit', edit_movie_path(@movie) %> |
<% end %>
<%= link_to 'Back', movies_path %>
```

```erb:app/views/movies/_form.html.erb
<%= form_with(model: movie, local: true) do |form| %>
  <% if movie.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(movie.errors.count, "error") %> prohibited this movie from being saved:</h2>

      <ul>
      <% movie.errors.full_messages.each do |message| %>
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
    <%= form.hidden_field :content, id: :movie_content %>
    <trix-editor input="movie_content"></trix-editor>
  </div>

  <div class="field">
    <%= form.label :movie %>
    <%= form.file_field :movie %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

```erb:app/views/comments/_comment.html.erb
<p><%= comment.auther %></p>
<p><%= tag.div('', class: 'score', data: {score: comment.score}) %></p>
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>1
<p><%= link_to "Delete", [@movie, comment], method: :delete, data: { confirm: 'Are you sure?' } %>

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
<%= form_with(model: [ @movie, @comment ], remote: true) do |form| %>
    <div class="movie_rate"></div>
    Your Name :<br>
    <%= form.text_field :auther %><br>
    Your Comment:<br>
    <%= form.hidden_field :content, id: :movie_comments %>
    <trix-editor input="movie_comments"></trix-editor>
    <%= form.submit %>
<% end %>

<script>
$(function() {
    $('.movie_rate').raty({
        score: 5, 
        starType: 'i',
    })
})
</script>
```

これで動画を投稿したユーザー名やコメントの作成者の名前が保存されるようになります！

これで動画投稿サイトは完成です！

## ライセンス
[MITライセンス](../LICENSE)