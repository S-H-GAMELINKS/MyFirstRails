# ActiveAdmin使用ブログ！
## 概要

Railsにこれから初めて触れる人を対象にしたチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new railspress
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd railspress
```

### SQLite3のバージョンを修正

先ほどのrails newでsqlite3のインストールがエラーになっている場合は、以下のようにバージョンを修正します

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、bundle installを実行します

```shell
bundle install
```

これでOKです！

### ActiveAdminの導入

まず、`Gemfile`に以下の`gem`を追加します

```ruby:Gemfile
# Using ActiveAdmin
gem 'devise'
gem 'activeadmin'
```

その後、`bundle install`を実行します

```shell
bundle install
```

そして、`rails g active_admin:install`を実行します

```shell
rails g active_admin:install
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate
```

`rails db:seed`を実行し、ログイン用ユーザーのデータを作成します

```shell
rails db:seed
```

あとは`rails s`を実行し、`localhost:3000/admin`にアクセスします

`localhost:3000/admin`にアクセスするとログインフォームが表示されます
IDとパスワードは以下の通りです

```
ID:admin@example.com
PASS:password
```

ログインできれば`ActiveAdmin`の導入は完了です！

### 記事のModelを作成

```shell
rails g model Post title:string content:text auther:string date:date
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate
```

あとは、`rails generate active_admin:resource post`を実行して`ActiveAdmin`で管理できるようにします

```shell
rails generate active_admin:resource post
```

### ActiveAdminの日本語化

まず、`config/application.rb`に`config.i18n.default_locale = :ja`を追加します

```ruby:config/application.rb
config.i18n.default_locale = :ja
```

その後、`config/locales/ja.yml`を追加します

```yml:config/locales/ja.yml
ja:
  time:
    formats:
      long: "%d/%m/%Y %H:%M"
  date:
    formats:
      long:  "%d/%m/%Y %H:%M"
```

### ActiveAdminの編集フォームにエディター導入

[activeadmin_froala_editor](https://github.com/blocknotes/activeadmin_froala_editor)を使い、記事内容にリッチテキストエディターを導入します

まずは`Gemfile`に`gem`を追加します

```shell
gem 'activeadmin_froala_editor'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`app/assets/stylesheets/active_admin.scss`に`SCSS`を読み込ませます

```scss:app/assets/stylesheets/active_admin.scss
@import 'font-awesome/font-awesome';
@import 'activeadmin/froala_editor_input'; 
```

`app/assets/javascripts/active_admin.js.coffee`を`app/assets/javascripts/active_admin.js`にリネームし、

```js:app/assets/javascripts/active_admin.js
//= require active_admin/base
//= require activeadmin/froala_editor/froala_editor.pkgd.min
//= require activeadmin/froala_editor_input
```

上記の`JavaScript`ファイルを読み込みます

次に、`app/admin/posts.rb`を以下のように編集します

```ruby:app/admin/posts.rb
ActiveAdmin.register Post do
    permit_params :title, :content, :auther, :date
    form do |f|
        f.inputs 'Article' do
          f.input :title
          f.input :content, as: :froala_editor
          f.input :auther
          f.input :date
        end
        f.actions
      end

end
```

`app/views/resources/_show.html.erb`を作成します

```erb:app/views/resources/_show.html.erb
<p>
  <strong>Title:</strong>
  <%= resource.title %>
</p>

 <p>
  <strong>Content:</strong>
  <%= sanitize resource.content %>
</p>

 <p>
  <strong>Date:</strong>
  <%= resource.date %>
</p> 
```

最後に、`app/admin/posts.rb`に記事の個別ページのアクションを設定します

```ruby:app/admin/posts.rb
ActiveAdmin.register Post do
    permit_params :title, :content, :auther, :date

    show do
        render partial: 'resources/show'
    end

    form do |f|
        f.inputs 'Article' do
          f.input :title
          f.input :content, as: :froala_editor
          f.input :auther
          f.input :date
        end
        f.actions
      end

end
```

これで、`ActiveAdmin`の管理画面から記事を作成する際にリッチテキストエディターを使用できるようになりました！

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
  <%= link_to "Blog", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
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


### 記事の一覧＆閲覧ページ作成

管理画面から記事を作成できる状態ですが、外部から記事を読むことはできていません

そこで、記事の一覧＆閲覧ページを作成します

```shell
rails g controller post index show
```

次に、`config/routes.rb`にルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'posts#index'
  resources :posts, :only => [:index, :show]
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

そして、`app/controllers/posts_controller.rb`を以下のように変更します

```ruby:app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, :only => [:show]

  def index
    @posts = Post.all
  end

  def show
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end
end
```

`app/views/posts/index.html.erb`を以下のように修正します

```erb:app/views/posts/index.html.erb
<div class="row">
<% @posts.each do |post| %>
    <div class="card col-lg-4" style="width: 18rem;">
        <div class="card-body">
            <h5 class="card-title"><%= post.title %></h5>
            <p class="card-text"><%= %></p>
            <%= link_to "Show Post", post_path(post), :class => "btn btn-primary" %>
        </div>
    </div>
<% end %>
</div>
```

次に、`app/views/posts/show.html.erb`を以下のように修正します

```erb:
<h1><%= @post.title %></h1>

<p><%= sanitize @post.content %><p>

<h1>Auther</h1>

<%= @post.auther %>
```

これで作成した記事を見ることができるようになります！

### コメント機能の作成

感想としてコメントを投稿できるようにしたいと思います

まず、コメントを取り扱う`Comment`モデルを作成します

```shell
rails g model comment content:text post:references
```

次にマイグレーションを行います

```shell
rails db:migrate
```

`app/models/post.rb`に`Comment`とのリレーションを追加します

```ruby:app/models/post.rb
class Post < ApplicationRecord
    has_many :comments
end

```

`config/routes.rb`にてルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'posts#index'
  resources :posts, :only => [:index, :show] do
    resources :comments, :only => [:create, :destroy]
  end
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

```

次に、各記事にコメントフォームを追加します

```erb:app/views/posts/show.html.erb
<h1><%= @post.title %></h1>

<p><%= sanitize @post.content %><p>

<h1>Auther</h1>

<%= @post.auther %>

<h2>Comments</h2>
  <div id="comments">
    <%= render @post.comments %>
  </div>

<%= render 'comments/new', post: @post %> 
```

変更箇所としては、この部分になります

```erb:
<h2>Comments</h2>
  <div id="comments">
    <%= render @post.comments %>
  </div>

<%= render 'comments/new', post: @post %> 
```

`<%= render @post.comments %>`の部分でコメントを一覧できるviewファイルをパーシャルとして呼び出しています

また、<%= render 'comments/new', post: @post %> の部分では新規作成するコメントのviewファイルをパーシャルとして呼び出しています

パーシャルとして呼び出している部分をそれぞれ作っていきます

まず、`app/views/comments/_comment.html.erb`を作成し、下記のようにします。

```erb:app/views/comments/_comment.html.erb
<p><%= comment.content %></p>
<p><%= link_to "Delete", [@post, comment], method: :delete, data: { confirm: 'Are you sure?' } %> 
```

次に、`app/views/comments/_new.html.erb`を作成します

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @post, Comment.new ], remote: true) do |form| %>
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
            params.required(:comment).permit(:content)
        end
end
```

`rails s`でローカルサーバを建てて、実際にコメントが作成&削除できていればOKです。

これで`ActiveAdmin`を使用したブログアプリのチュートリアルは終わりです！

