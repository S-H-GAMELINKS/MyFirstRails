# PWA対応のTODOアプリ サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
PWA(Progressive Web Apps)に対応した簡単なTODOアプリを作成するチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new todo_pwa
```

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd todo_pwa
```

### SQLite3の修正

`sqlite3`のインストールでエラーが出ている場合は以下のようにsqlite3のバージョンを修正してbundle installを実行してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

```shell
bundle install
```

### ScaffoldでCRUDを作成

`rails g scaffold` コマンドを使い、TODO管理のひな型を作ります

```shell
rails g scaffold task title:string content:text date:date
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

あとは`rails s`を実行して、`localhost:3000/tasks`にアクセスします
ページが表示されていればOKです

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

最後に、`app/views/tasks/_form.html.erb`、`app/views/tasks/show.html.erb`を以下のように変更します。

```erb:app/views/tasks/_form.html.erb
<%= form_with(model: task, local: true) do |form| %>
  <% if task.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(task.errors.count, "error") %> prohibited this task from being saved:</h2>

      <ul>
      <% task.errors.full_messages.each do |message| %>
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
    <trix-editor input="content_text"></trix-editor>
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

```erb:app/views/tasks/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Tasks</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th>Date</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @tasks.each do |task| %>
      <tr>
        <td><%= task.title %></td>
        <td><%= sanitize task.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></td>
        <td><%= task.date %></td>
        <td><%= link_to 'Show', task %></td>
        <td><%= link_to 'Edit', edit_task_path(task) %></td>
        <td><%= link_to 'Destroy', task, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Task', new_task_path %>
```

```erb:app/views/tasks/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @task.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @task.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>
</p>

<p>
  <strong>Date:</strong>
  <%= @task.date %>
</p>

<%= link_to 'Edit', edit_task_path(@task) %> |
<%= link_to 'Back', tasks_path %>
```

これで、リッチなテキストエディタが使用できるようになります。

### カテゴリー機能の実装

TODOアプリですので「緊急」などのカテゴリーを登録して判断できるようにしたいと思います

まずは、カテゴリー用のCRUDのひな型を`rails g scaffold`で作成します

```shell
rails g scaffold category name:string
```

`scaffold`した後は、いつものように`rails db:migrate`を実行します

```shell
rails db:migrate
```

`localhost:3000/categories`にブラウザからアクセスするとカテゴリーを新規に作成したり、カテゴリー名を編集することができるようになっているはずです！


次に、作成している`Task`に`category`のカラムを追加します

```shell
rails g migration AddCategoryToTask category:string
```

再び、`rails db:migrate`を実行します

```shell
rails db:migrate
```

あとは、コントローラーとビューで`category`をパラメータとして受け取れるように修正します。

```ruby:app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :set_category, only: [:new, :edit]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    def set_category
      @categories = Category.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :content, :date, :category)
    end
end
```

```ruby:app/views/tasks/_form.html.erb
<%= form_with(model: task, local: true) do |form| %>
  <% if task.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(task.errors.count, "error") %> prohibited this task from being saved:</h2>

      <ul>
      <% task.errors.full_messages.each do |message| %>
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
    <%= form.label :category %>
    <%= form.collection_select(:category, @categories, :name, :name, include_blank: true) %>
  </div>

  <div class="field">
    <%= form.label :content %>
    <%= form.hidden_field :content, id: :content_text %>
    <trix-editor input="content_text"></trix-editor>
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

これで、作成したカテゴリー名をTODOのカテゴリー名に使用できるようになりました！

### root_pathの追加

`config/routes.rb`を編集して、`root_path`を使用できるようにします

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'tasks#index'
  resources :categories
  resources :tasks
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

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

また、`Windows`のローカル環境でアプリを作成している場合は、`SQLite3`がバージョンアップしてしまいます
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
  <%= link_to "ToDo", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      Menu
    </button>
    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
      <%= link_to 'Tasks', tasks_path, class: "dropdown-item" %>
      <%= link_to 'Categories', categories_path, class: "dropdown-item" %>
    </div>
  </div>
</nav>
```

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>TODO Tutorial</title>
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

### カテゴリ検索機能を実装

[select2-rails](https://github.com/argerim/select2-rails)を使い、プルダウン内で検索ができるようにします！

`Gemfile`に`gem 'select2-rails'`と追加し、`bundle install`を実行します

```ruby:Gemfile
gem 'select2-rails'
```

```shell
bundle install
```

次に、`app/assets/javascripts/application.js`と`app/assets/stylesheets/application.scss`を修正します

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
//= require select2
//= require turbolinks
//= require_tree .

　$(document).ready(function() {
    　$('select#task_category').select2();
  });
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
 @import "select2";
 @import "select2-bootstrap";
```

これで実装完了！といきたいところですが、まだ終わりではありません

試しに`localhost:3000`の`New Task`をクリックして`localhost:3000/tasks/new`にアクセスしてみてください
おそらく、プルダウンメニューでのカテゴリ検索ができていないのではないでしょうか？

原因としては、[`Turbolinks`]()によって`JavaScript`ファイルが読み込まれていないことが原因です
事実、`F5`キーなどで再読み込みを行うとプルダウンメニューでのカテゴリ検索が動くようになると思います

簡単な対処方法としては、ヘルパーメソッドの`link_to`に`data {"turbolinks" => false}`というオプションを渡す方法があります
ただ、この方法の場合リンク先の描画に時間がかかってしまいます

そこで、指定の`JavaScript`を読み込めるように設定を変更します

`app/assets/javascripts/select2_tasks.js`を作成し、`app/assets/javascripts/application.js`に記載されている以下のコードを移植します

```js:
　$(document).ready(function() {
    　$('select#task_category').select2();
  }); 
```

次に、`config/initializers/assets.rb`にて読み込む`JavaScript`ファイルを記述します

```ruby:config/initializers/assets.rb
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w(select2_tasks.js)
```

最後に`app/views/tasks/_form.html.erb`を以下のように修正します

```erb:app/views/tasks/_form.html.erb
<%= form_with(model: task, local: true) do |form| %>
  <% if task.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(task.errors.count, "error") %> prohibited this task from being saved:</h2>

      <ul>
      <% task.errors.full_messages.each do |message| %>
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
    <%= form.label :category %>
    <%= form.collection_select(:category, @categories, :name, :name, include_blank: true) %>
  </div>

  <div class="field">
    <%= form.label :content %>
    <%= form.hidden_field :content, id: :content_text %>
    <trix-editor input="content_text"></trix-editor>
  </div>

  <div class="field">
    <%= form.label :date %>
    <%= form.date_select :date %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>

<%= javascript_include_tag 'select2_tasks' %>
```

これで、`localhost:3000/tasks/new`でカテゴリを登録する際にプルダウン検索が使用できるようになりました！

### PWA対応

Railsで簡単なPWA対応を行う際に便利な`gem`が[`serviceworker-rails`](https://github.com/rossta/serviceworker-rails)です

`Gemfile`に`gem 'serviceworker-rails'`を追加します

```ruby:Gemfile
gem 'serviceworker-rails'
```

その後、`bundle install`を実行します

```shell
bundle install
```

最後に`rails g serviceworker:install`を実行し、`serviceworker`をインストールします

```shell
rails g serviceworker:install
```

これでPWAとして利用できるようになります！

なお、`app/assets/javascripts/application.js`や`config/initializers/assets.rb`が以下のようになっている場合はPWAとして利用できません

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
//= require select2
//= require turbolinks
//= require_tree .//= require_tree .//= require serviceworker-companion
```

```ruby:config/initializers/assets.rb
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w(select2_tasks.js)
Rails.configuration.assets.precompile += %w[serviceworker.js manifest.json]
```

上記の二つを以下のように修正し、再度`rails s`でローカルサーバを起動すればPWAとして利用できます！

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
//= require select2
//= require serviceworker-companion
//= require turbolinks
//= require_tree .
```

```ruby:config/initializers/assets.rb
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.configuration.assets.precompile += %w[serviceworker.js manifest.json select2_tasks.js]
```

これでPWA対応したTODOアプリのチュートリアルは終了です！


