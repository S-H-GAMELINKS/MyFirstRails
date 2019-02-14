# Q&Aサイト サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
ログイン機能もある簡単なQ＆Aサイトを作成するチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new qa --webpack=stimulus
```

`--webpack`はRailsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用するというオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回は[`Stimulus`](https://github.com/stimulusjs/stimulus)を使用するので`--webpack=stimulus`としています
ちなみに、`Stimulus`はRailsの生みの親であるDHH氏がCTOを務める[`Basecamp`](https://basecamp.com/)が開発したJavaScriptフレームワークです
非常にシンプルで動きのあるWebを実現できます

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd qa
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

### ScaffoldでCRUDを作成

`rails g scaffold` コマンドを使い、質問投稿のひな型を作成します

```shell
rails g scaffold question title:string content:text
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

`config/routes.rb`を修正し、`root`へのルーティングを作成します

```ruby:config/routes.rb

Rails.application.routes.draw do
  root 'questions#index'
  resources :questions
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

あとは`foreman start -f Procfile.dev`を実行して、`localhost:3000`にアクセスします
ページが表示されていればOKです

### コメント機能の作成

質問投稿サイトですので、コメントを投稿できるようにしたいと思います

まず、コメントを取り扱う`Comment`モデルを作成します。

```shell
rails g model comment content:text qustion:references
```

マイグレーションを行います

```shell
rails db:migrate
```

`app/models/question.rb`に`Comment`との関連付けを記述します

```ruby:app/models/question.rb
class Question < ApplicationRecord
    has_many :comments
end
```

そして、`config/routes.rb` にてルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
　root 'questions#index'
  resources :questions do
    resources :comments, :only => [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

次に、各質問へのコメントフォームを作成していきます。

まずは下記のように`app/views/questions/show.html.erb`を変更します

```erb:app/views/questions/show.html.erb

<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @question.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= @question.content %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @question.comments %>
  </div>

<%= render 'comments/new', question: @question %> 

<%= link_to 'Edit', edit_question_path(@question) %> |
<%= link_to 'Back', questions_path %>
```

変更箇所としてはこの部分になります

```erb
<h2>Comments</h2>
  <div id="comments">
    <%= render @question.comments %>
  </div>

<%= render 'comments/new', question: @question %> 
```

`<%= render @question.comments %>` の部分でコメントを一覧できるviewファイルをパーシャルとして呼び出しています

また、`<%= render 'comments/new', question: @question %> `の部分では新規作成するコメントのviewファイルをパーシャルとして呼び出しています

パーシャルとして呼び出している部分をそれぞれ作っていきます

まず、`app/views/comments/_comment.html.erb` を作成し、下記のようにします。

```erb:app/views/comments/_comment.html.erb
<p><%= comment.content %></p>
<p><%= link_to "Delete", [@question, comment], method: :delete, data: { confirm: 'Are you sure?' } %>
```

次に、`app/views/comments/_new.html.erb`を作成します

```erb:app/views/comments/_new.html.erb
<%= form_with(model: [ @question, Comment.new ], remote: true) do |form| %>
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
    before_action :set_question

     def create
        @question.comments.create! comments_params
        redirect_to @question
    end

     def destroy
        @question.comments.destroy params[:id]
        redirect_to @question
    end

      private
        def set_question
            @question = Question.find(params[:question_id])
        end

          def comments_params
            params.required(:comment).permit(:content)
        end
end
```

`foreman start -f Procfile.dev` でローカルサーバを建てて、実際にコメントが作成&削除できていればOKです。

### Stimulusでリアルタイムプレビューを実装

まず、`app/javascript/controllers/question_controller.js`と`app/javascript/controllers/comment_controller.js`を作成します

```js:app/javascript/controllers/question_controller.js
import { Controller } from "stimulus"

 export default class extends Controller {
    static targets = ["content", "preview"]

     content() {
        this.previewTarget.innerHTML = this.contentTarget.value
    }
} 
```

```js:app/javascript/controllers/comment_controller.js
import { Controller } from "stimulus"

 export default class extends Controller {
    static targets = ["content", "preview"]

     content() {
        this.previewTarget.innerHTML = this.contentTarget.value
    }
} 
```

次に、`app/views/questions/_form.html.erb`と`app/views/comments/_new.html.erb`を以下のように編集します

```erb:app/views/questions/_form.html.erb
<div  data-controller="question">
  <div class="form-left">
    <%= form_with(model: question, local: true) do |form| %>
      <% if question.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(question.errors.count, "error") %> prohibited this question from being saved:</h2>

          <ul>
            <% question.errors.full_messages.each do |message| %>
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
        <%= form.text_area :content, 'data-target': 'question.content', 'data-action': 'input->question#content'  %>
      </div>

      <div class="actions">
        <%= form.submit %>
      </div>
    <% end %>
  </div>

  <div class="form-right">
    <h1>Content</h1>
    <div data-target="question.preview"></div>
  </div>
</div>
  
<%= javascript_pack_tag 'application.js' %>
```

```erb:app/views/comments/_new.html.erb
<div data-controller="comment">
    <div class="container">
        <div data-target="comment.preview"></div>
    </div>
    <%= form_with(model: [ @question, Comment.new ], remote: true) do |form| %>
        Your Comment:<br>
        <%= form.text_area :content, 'data-target': 'comment.content', 'data-action': 'input->comment#content',  size: '50x20' %><br>
        <%= form.submit %>
    <% end %>
</div>

<%= javascript_pack_tag 'application.js' %>
```

最後に、`app/assets/stylesheets/questions.scss`を以下のように修正します

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

### コメントの編集

まず、`config/routes.rb`を編集し、`:edit`と`:update`をルーティングに追加します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'questions#index'
  resources :questions do
    resources :comments, :only => [:edit, :create, :update, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

その後、`app/controllers/comments_controller.rb`に`edit`アクションと`update`アクションを追加します
またこの時、`before_action`を使用し、`@comment`をセットできるようにしています

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_question
    before_action :set_comment, only: [:edit, :update]

    def edit
    end

    def create
        @question.comments.create! comments_params
        redirect_to @question
    end

    def update
        @comment.update(comments_params)
        redirect_to @question
    end

    def destroy
        @question.comments.destroy params[:id]
        redirect_to @question
    end

     private
        def set_question
            @question = Question.find(params[:question_id])
        end

        def set_comment
            @comment = Comment.find(params[:id])
        end

        def comments_params
            params.required(:comment).permit(:content)
        end
end
```

あとは、`app/views/comments/_form.html.erb`と`app/views/comments/edit.html.erb`を作成します

```erb:app/views/comments/_form.html.erb
<div data-controller="comment">
    <div class="container">
        <div data-target="comment.preview"></div>
    </div>
    <%= form_with(model: [ @question, @comment ], remote: true) do |form| %>
        Your Comment:<br>
        <%= form.text_area :content, 'data-target': 'comment.content', 'data-action': 'input->comment#content',  size: '50x20' %><br>
        <%= form.submit %>
    <% end %> 
</div> 
```

```erb:app/views/comments/edit.html.erb
<h1>Editing Comments</h1>

  <%= render 'form' %>

  <%= link_to 'Show', @question %> |
<%= link_to 'Back', questions_path %> 
```

これで、コメント欄の`Edit`リンクからコメントを編集できるようになります

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

最後に、`app/views/questions/_form.html.erb`、`app/views/questions/index.html.erb`、
`app/views/questions/show.html.erb`、`app/views/comments/_form.html.erb`、
`app/views/comments/_new.html.erb`、`app/views/comments/_comment.html.erb`を以下のように変更します。

```erb:app/views/questions/_form.html.erb
<div  data-controller="question">
  <div class="form-left">
    <%= form_with(model: question, local: true) do |form| %>
      <% if question.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(question.errors.count, "error") %> prohibited this question from being saved:</h2>

          <ul>
            <% question.errors.full_messages.each do |message| %>
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
        <trix-editor input="content_text" data-target="question.content", data-action="input->question#content"></trix-editor>
      </div>

      <div class="actions">
        <%= form.submit %>
      </div>
    <% end %>
  </div>

  <div class="form-right">
    <h1>Content</h1>
    <div data-target="question.preview"></div>
  </div>
</div>

<%= javascript_pack_tag 'application.js' %>
```

```erb:app/views/questions/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Questions</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @questions.each do |question| %>
      <tr>
        <td><%= question.title %></td>
        <td><%= sanitize question.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></td>
        <td><%= link_to 'Show', question %></td>
        <td><%= link_to 'Edit', edit_question_path(question) %></td>
        <td><%= link_to 'Destroy', question, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Question', new_question_path %>
```

```erb:app/views/questions/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @question.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @question.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @question.comments %>
  </div>

<%= render 'comments/new', question: @question %> 

<%= link_to 'Edit', edit_question_path(@question) %> |
<%= link_to 'Back', questions_path %>
```

```erb:app/views/comments/_form.html.erb
<div data-controller="comment">
    <div class="container">
        <div data-target="comment.preview"></div>
    </div>
    <%= form_with(model: [ @question, @comment ], remote: true) do |form| %>
        Your Comment:<br>
        <%= form.hidden_field :content, id: :comment_content %>
        <trix-editor input="comment_content" data-target="comment.content", data-action="input->comment#content"></trix-editor>
        <%= form.submit %>
    <% end %> 
</div>
```

```erb:app/views/comments/_new.html.erb
<div data-controller="comment">
    <div class="container">
        <div data-target="comment.preview"></div>
    </div>
    <%= form_with(model: [ @question, Comment.new ], remote: true) do |form| %>
        Your Comment:<br>
        <%= form.hidden_field :content, id: :comment_content %>
        <trix-editor input="comment_content" data-target="comment.content", data-action="input->comment#content"></trix-editor>
        <%= form.submit %>
    <% end %>
</div>
```

```erb:app/views/comments/_comment.html.erb
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<p><%= link_to "Delete", [@question, comment], method: :delete, data: { confirm: 'Are you sure?' } %> 
<p><%= link_to "Edit", edit_question_comment_path(@question, comment) %></p>
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
  <%= link_to "QA Web", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      Menu
    </button>
    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
      <%= link_to 'Questoions', questions_path, class: "dropdown-item" %>
    </div>
  </div>
</nav>
```

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>Qa</title>
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

### カテゴリの作成

質問サイトなどでは、使用するフレームワークや言語などのカテゴリを登録して質問しています
今回のチュートリアルでもカテゴリを使用できるようにしたいと思います

まずは`rails g scaffold`でカテゴリのひな型を作成します

```shell
rails g scaffold category name:string
```

マイグレーションも実行します

```shell
rails db:migrate
```

マイグレーション後、`app/views/layouts/_header.html.erb`にリンクを追加します

```erb:app/views/layouts/_header.html.erb
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <%= link_to "QA Web", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      Menu
    </button>
    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
      <%= link_to 'Questoions', questions_path, class: "dropdown-item" %>
      <%= link_to 'Categories', categories_path, class: "dropdown-item" %>
    </div>
  </div>
</nav>
```

これで、`localhost:5000/categories`で新しいカテゴリなどを作成できます！

### 作成したカテゴリを使う

せっかくカテゴリ作れるようにしたので、質問投稿時にカテゴリを指定できるようにしたいですよね？
というわけで、カテゴリを使用できるように実装します

まず、`rails g migration`を実行し、`Question`モデルに`category`カラムを追加します
`rails g migration`コマンドを使用することで作成済みのモデルに新しくカラムを追加したり、既にあるカラムを削除することもできます

```shell
rails g migration AddCategoryToQuestion category:string
```

マイグレーションも実行しておきます

```shell
rails db:migrate
```

最後に`app/controllers/questions_controller.rb`、`app/views/questions/_form.html.erb`、
`app/views/questions/index.html.erb`、`app/views/questions/show.html.erb`を以下のように編集します

`app/controllers/questions_controller.rb`では新しい`before_action`にてカテゴリ一覧を`@categories`というインスタンス変数にセットしています
また、`question_params`の`permit`に`:category`を追加しています

`app/views/questions/_form.html.erb`ではフォームの項目に`Category`を追加し、選択できるようにしています

`app/views/questions/index.html.erb`、`app/views/questions/show.html.erb`では入力されたカテゴリを表示できるようにしています

```ruby:app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :set_category, only: [:new, :edit]

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.all
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    def set_category
      @categories = Category.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :content, :category)
    end
end
```

```erb:app/views/questions/_form.html.erb
<div  data-controller="question">
  <div class="form-left">
    <%= form_with(model: question, local: true) do |form| %>
      <% if question.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(question.errors.count, "error") %> prohibited this question from being saved:</h2>

          <ul>
            <% question.errors.full_messages.each do |message| %>
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
        <trix-editor input="content_text" data-target="question.content", data-action="input->question#content"></trix-editor>
      </div>

      <div class="actions">
        <%= form.submit %>
      </div>
    <% end %>
  </div>

  <div class="form-right">
    <h1>Content</h1>
    <div data-target="question.preview"></div>
  </div>
</div>
```

```erb:app/views/questions/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Questions</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Category</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @questions.each do |question| %>
      <tr>
        <td><%= question.title %></td>
        <td><%= question.category %></td>
        <td><%= sanitize question.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></td>
        <td><%= link_to 'Show', question %></td>
        <td><%= link_to 'Edit', edit_question_path(question) %></td>
        <td><%= link_to 'Destroy', question, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Question', new_question_path %>
```

```erb:app/views/questions/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @question.title %>
</p>

<p>
  <strong>Category:</strong>
  <%= @question.category %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @question.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @question.comments %>
  </div>

<%= render 'comments/new', question: @question %> 

<%= link_to 'Edit', edit_question_path(@question) %> |
<%= link_to 'Back', questions_path %>
```

### Select2でのプルダウンメニュー検索

[select2-rails](https://github.com/argerim/select2-rails)を使い、プルダウン内でカテゴリ検索ができるようにします！

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
    　$('select#question_category').select2();
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

これで、`localhost:5000/questions/new`でカテゴリを登録する際にプルダウン検索が使用できるようになりました！

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
  <%= link_to "QA Web", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      Menu
    </button>
    <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
      <%= link_to 'Questoions', questions_path, class: "dropdown-item" %>
      <%= link_to 'Categories', categories_path, class: "dropdown-item" %>
      <% if user_signed_in? %>
      <%= link_to 'Sign Out', destroy_user_session_path, method: :delete, class: "dropdown-item" %>
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

次に、`Question`や`Comment`と`User`と紐づけて、`Question`や`Coment`を投稿した本人しか削除できないようにします

`rails g migration`コマンドを使用して新しいカラムを`Question`と`Comment`に追加します

```shell
rails g migration AddUserToQuestion user:references
rails g migration AddUserToComment user:references
```

モデルに新しいカラムを追加したので、`rails db:migrate`でマイグレーションを実行します

```shell
rails db:migrate
```

そして、`app/controllers/questions_controller.rb`、`app/controllers/comments_controller.rb`、`app/controllers/categories_controller.rb`を下記のように変更します
`app/controllers/questions_controller.rb`、`app/controllers/comments_controller.rb`の`create`アクションで現在ログインしているユーザーの`ID`を保存するようにしています

また、`before_action`で`check_login`を呼び出してログイン状態と投稿者本人かどうかを判定しています
ログインしていない又は投稿者本人でない場合は、`localhost:5000/questions/1/edit`などにアクセスしても`localhost:5000`へとリダイレクトされます

```ruby:app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :set_category, only: [:new, :edit]
  before_action :check_login, only: [:new, :edit, :create, :update, :destroy]

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.all
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)
    @question.user_id = current_user.id

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    def set_category
      @categories = Category.all
    end

    def check_login
      redirect_to :root if current_user == nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :content, :category)
    end
end
```

```ruby:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
    before_action :set_question
    before_action :set_comment, only: [:edit, :update]
    before_action :check_login, only: [:edit, :create, :update, :destroy]

    def edit
    end

    def create
        @question.comments.create! comments_params
        @question.comments.update(:user_id => current_user.id)
        redirect_to @question
    end

    def update
        @comment.update(comments_params)
        redirect_to @question
    end

    def destroy
        @question.comments.destroy params[:id]
        redirect_to @question
    end

     private
        def set_question
            @question = Question.find(params[:question_id])
        end

        def set_comment
            @comment = Comment.find(params[:id])
        end

        def check_login
            redirect_to :root if current_user == nil
        end

        def comments_params
            params.required(:comment).permit(:content)
        end
end
```

```ruby:app/controllers/categories_controller.rb
class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :check_login, only: [:new, :edit, :create, :update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    def check_login
      redirect_to :root if current_user == nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name)
    end
end
```

あとは、`app/views/questions/index.html.erb`、`app/views/questions/show.html.erb`、
`app/views/comments/_comment.hmtl.erb`、`app/views/categories/index.html.erb`、`app/views/categories/show.html.erb`を以下のように変更することで実装は完了です！

`Devise`のヘルパーメソッドの`user_signed_in?`を使うことでログインしているかを判定しています
また`@question.user_id == current_user.id`とすることで投稿した本人かどうかを判定しています

```erb:app/views/questions/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Questions</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Category</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @questions.each do |question| %>
      <tr>
        <td><%= question.title %></td>
        <td><%= question.category %></td>
        <td><%= sanitize question.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></td>
        <td><%= link_to 'Show', question %></td>
        <% if user_signed_in? && question.user_id == current_user.id %>
        <td><%= link_to 'Edit', edit_question_path(question) %></td>
        <td><%= link_to 'Destroy', question, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<% if user_signed_in? %>
<%= link_to 'New Question', new_question_path %>
<% end %>
```

```erb:app/views/questions/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @question.title %>
</p>

<p>
  <strong>Category:</strong>
  <%= @question.category %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @question.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %>
</p>

<h2>Comments</h2>
  <div id="comments">
    <%= render @question.comments %>
  </div>

<% if user_signed_in? %>
<%= render 'comments/new', question: @question %> 
<% end %>

<% if user_signed_in? && @question.user_id == current_user.id %>
<%= link_to 'Edit', edit_question_path(@question) %> |
<% end %>
<%= link_to 'Back', questions_path %>
```

```erb:app/views/comments/_comment.hmtl.erb
<p><%= sanitize comment.content, tags: %w(h1 h2 h3 h4 h5 h6 ul ol li p a img table tr td em br strong div), attributes:  %w(id class href) %></p>
<% if user_signed_in? && comment.user_id == current_user.id %>
<p><%= link_to "Delete", [@question, comment], method: :delete, data: { confirm: 'Are you sure?' } %> 
<p><%= link_to "Edit", edit_question_comment_path(@question, comment) %></p>
<% end %>
```

```erb:app/views/categories/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Categories</h1>

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @categories.each do |category| %>
      <tr>
        <td><%= category.name %></td>
        <td><%= link_to 'Show', category %></td>
        <% if user_signed_in? %>
        <td><%= link_to 'Edit', edit_category_path(category) %></td>
        <td><%= link_to 'Destroy', category, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<% if user_signed_in? %>
<%= link_to 'New Category', new_category_path %>
<% end %>
```

```erb:app/views/categories/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Name:</strong>
  <%= @category.name %>
</p>

<% if user_signed_in? %>
<%= link_to 'Edit', edit_category_path(@category) %> |
<% end %>
<%= link_to 'Back', categories_path %>
```

これでQ＆Aサイトは完成です！