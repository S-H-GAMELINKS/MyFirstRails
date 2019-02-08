# BBS Devise サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
ログイン機能もある簡単な掲示板アプリを作成するチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new bbs_devise
```

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd bbs_devise
```

### ScaffoldでCRUDを作成

`rails g scaffold` コマンドを使い、ブログに必要な一覧ページや記事作成ページなどを作ります

```shell
rails g scaffold post title:string content:text auther:string
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

あとは`rails s`を実行して、`localhost:3000/posts`にアクセスします

### コメント機能の作成

掲示板ですので、コメントを投稿できるようにしたいと思います

まず、コメントを取り扱う`Comment`モデルを作成します。

```shell
rails g model comment auther:string content:text post:references
```

マイグレーションを行います

```shell
rails db:migrate
```

`app/models/post.rb`に`Comment`との関連付けを記述します

```ruby:app/models/post.rb
class Post < ApplicationRecord
    has_many :comments
end
```

そして、`config/routes.rb` にてルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
　root 'posts#index'
  resources :posts do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

次に、各記事へのコメントフォームを作成していきます。

まずは下記のように`app/views/posts/show.html.erb`を変更します

```erb:app/views/posts/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @post.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= @post.content %>
</p>

<p>
  <strong>Date:</strong>
  <%= @post.date %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @post.comments %>
  </div>

<%= render 'comments/new', post: @post %> 

<%= link_to 'Edit', edit_post_path(@post) %> |
<%= link_to 'Back', posts_path %>
```

変更箇所としてはこの部分になります

```erb
<h2>Comments</h2>
  <div id="comments">
    <%= render @post.comments %>
  </div>

<%= render 'comments/new', post: @post %> 
```

`<%= render @post.comments %>` の部分でコメントを一覧できるviewファイルをパーシャルとして呼び出しています

また、`<%= render 'comments/new', post: @post %> `の部分では新規作成するコメントのviewファイルをパーシャルとして呼び出しています

パーシャルとして呼び出している部分をそれぞれ作っていきます

まず、`app/views/comments/_comment.html.erb` を作成し、下記のようにします。

```erb:app/views/comments/_comment.html.erb
<p><%= comment.auther %></p>
<p><%= comment.content %></p>
<p><%= link_to "Delete", "#{comment.post_id}/comments/#{comment.id}", method: :delete, data: { confirm: 'Are you sure?' } %> 
```

次に、`app/views/comments/_new.html.erb`を作成します

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @post, Comment.new ], remote: true) do |form| %>
    Your Name:<br>
    <%= form.text_area :auther %><br>
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
    before_action :set_post

    def create
        @post.comments.create! comments_params
        redirect_to @post
    end

    def destroy
        @post.comments.destroy params[:id]
        redirect_to @post
    end

     private
        def set_post
            @post = Post.find(params[:post_id])
        end

         def comments_params
            params.required(:comment).permit(:auther, :content)
        end
end
```

あとは、`rails s` でローカルサーバを建てて実際にコメントが作成&削除できていればOKです。

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

最後に、`app/views/posts/_form.html.erb`、`app/views/posts/show.html.erb`、`app/views/comments/_comment.html.erb`、 `app/views/comments/_new.html.erb`を以下のように変更します。

```erb:app/views/posts/_form.html.erb
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
    <%= form.hidden_field :content, id: :post_text %>
    <trix-editor input="post_text"></trix-editor>
  </div>

  <div class="field">
    <%= form.label :date %>
    <%= form.date_select :date %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
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

<p>
  <strong>Date:</strong>
  <%= @post.date %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @post.comments %>
  </div>

<%= render 'comments/new', post: @post %> 

<%= link_to 'Edit', edit_post_path(@post) %> |
<%= link_to 'Back', posts_path %>
```

```erb:app/views/comments/_comment.html.erb
<p><%= comment.auther %></p>
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<p><%= link_to "Delete", "#{comment.post_id}/comments/#{comment.id}", method: :delete, data: { confirm: 'Are you sure?' } %>
```

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @post, Comment.new ], remote: true) do |form| %>
    Your Name:<br>
    <%= form.text_area :auther %><br>
    Your Comment:<br>
    <%= form.hidden_field :content, id: :comment_content %>
    <trix-editor input="comment_content"></trix-editor>
    <%= form.submit %>
<% end %> 
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

また、`Windows`のローカル環境でアプリを作成している場合は、`SQLite3`がバージョンアップしてしまします
以下のようにバージョンを固定してから`bundle update`と`bundle install`を実行して下さい

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

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
  <%= link_to "BBS", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
</nav>
```

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>BBS</title>
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

`rails s`でサーバを起動し、ナビゲーションバーが表示されていればOKです。

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
  <%= link_to "BBS", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Menu
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <%= link_to 'Posts', posts_path, class: "dropdown-item" %>
    <% if user_signed_in? %>
    <%= link_to 'Sign Out', destroy_user_session_path, class: "dropdown-item", method: :delete %>
    <% else %>
    <%= link_to 'Sign Up', new_user_registration_path, class: "dropdown-item" %>
    <%= link_to 'Sign In', new_user_session_path, class: "dropdown-item" %>
    <% end %>
  </div>
</div>
</nav>
```

`user_signed_in?`は`Devise`を導入したことでしようできるヘルパーメソッドになります
これだけでユーザーがログインしているかどうかをチェックできます

`<% if user_signed_in? %>`ではユーザーがログインしている状態に表示する内容を記述しています。
`<% else %>`以降はログインしていない場合に表示する内容になります

これでログイン画面へのリンクなどが作成できました

### 本人しか投稿やコメントを削除できないようにしたい

次に、`Post`や`Comment`と`User`と紐づけて、`Post`や`Coment`を投稿した本人しか削除できないようにします
ついでに、投稿者名が自動で入力されるようにします

`rails g migration`コマンドを使用して新しいカラムを`Post`と`Comment`に追加します

```shell
rails g migration AddUserToPost user:references
rails g migration AddUserToComment user:references
```

`rails g migration`コマンドを使用することで作成済みのモデルに新しくカラムを追加したり、既にあるカラムを削除することもできます

モデルに新しいカラムを追加したので、`rails db:migrate`でマイグレーションを実行します

```shell
rails db:migrate
```

そして、`app/controllers/comments_controller.rb`、`app/controllers/posts_controller.rb`を下記のように変更します

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_post

    def create
        @post.comments.create! comments_params
        redirect_to @post
    end

    def destroy
        @post.comments.destroy params[:id]
        redirect_to @post
    end

     private
        def set_post
            @post = Post.find(params[:post_id])
        end

         def comments_params
            params.required(:comment).permit(:auther, :content)
        end
end
```

```ruby:app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    if current_user
      @comment = Comment.new
      @comment.auther = current_user.name
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
    @post.auther = current_user.name
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :content, :auther)
    end
end
```

あとは、`app/views/posts/index.hmtl.erb`、`app/views/posts/show.hmtl.erb`、`app/views/comments/_comment.hmtl.erb`を以下のように変更することで実装は完了です！

```erb:app/views/posts/index.hmtl.erb
<p id="notice"><%= notice %></p>

<h1>Posts</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th>Auther</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @posts.each do |post| %>
      <tr>
        <td><%= post.title %></td>
        <td><%= sanitize post.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></td>
        <td><%= post.auther %></td>
        <td><%= link_to 'Show', post %></td>
        <% if user_signed_in? && post.user_id == current_user.id %>
        <td><%= link_to 'Edit', edit_post_path(post) %></td>
        <td><%= link_to 'Destroy', post, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<% if user_signed_in? %>
<%= link_to 'New Post', new_post_path %>
<% end %>
```

```erb:app/views/posts/show.hmtl.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @post.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @post.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<p>
  <strong>Auther:</strong>
  <%= @post.auther %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @post.comments %>
  </div>

<% if user_signed_in? %>
<%= render 'comments/new', post: @post %> 
<% end %>

<% if user_signed_in? && @post.user_id == current_user.id %>
<%= link_to 'Edit', edit_post_path(@post) %> |
<% end %>
<%= link_to 'Back', posts_path %>

```

```erb:app/views/comments/_comment.hmtl.erb
<p><%= comment.auther %></p>
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<% if user_signed_in? %>
<p><%= link_to "Delete", "#{comment.post_id}/comments/#{comment.id}", method: :delete, data: { confirm: 'Are you sure?' } %> 
<% end %>
```