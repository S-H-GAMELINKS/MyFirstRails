# 求人募集サイトの作成！
## 概要

Railsにこれから初めて触れる人を対象にしたチュートリアルです

[`ActiveAdmin`](https://github.com/activeadmin/activeadmin)を使用した求人募集サイトを作成するチュートリアルです！

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、`Rails`アプリのひな型を作成します

```shell
rails new hellojob
```

次に、作成した`Rails`アプリのディレクトリへと移動します

```shell
cd hellojob
```

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

### 求人のModelを作成

求人データを取り扱う`Job`モデルを作成します

```shell
rails g model Job title:string content:text
```

その後、`rails db:migrate`を実行します

```shell
rails dbmigrate
```

あとは、`rails generate active_admin:resource job`を実行して`ActiveAdmin`で管理できるようにします

```shell
rails generate active_admin:resource job
```

これで`ActiveAdmin`の管理画面から求人データを作成できるようになります

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
```

これで`ActiveAdmin`の管理画面が日本語化されました！

### ActiveAdminの編集フォームにエディター導入

[`activeadmin_medium_editor`](https://github.com/blocknotes/activeadmin_medium_editor)を使い、求人データにリッチテキストエディターを導入します

まず、`Gemfile`に`gem`を追加します

```ruby:Gemfile
gem 'activeadmin_medium_editor'
```

その後、`bundle install`を実行し、`gem`をインストールします

```shell
bundle install
```

次に、`app/assets/stylesheets/active_admin.scss`に`scss`を追加します

```scss:app/assets/stylesheets/active_admin.scss
@import 'activeadmin/medium_editor_input';
@import 'activeadmin/medium_editor/themes/default.css';
```

そして、`app/assets/javascripts/active_admin.js.coffee`を`app/assets/javascripts/active_admin.js`へとリネームし、

```js:app/assets/javascripts/active_admin.js
//= require active_admin/base
//= require activeadmin/medium_editor/medium_editor
//= require activeadmin/medium_editor_input 
```

実際に`ActiveAdmin`画面でエディターを使用できるようにしてみましょう!

`app/admin/jobs.rb`を以下のように編集します

```ruby:app/admin/jobs.rb
ActiveAdmin.register Job do
    permit_params :title, :content

    form do |f|
        f.inputs 'Job' do
            f.input :title
            f.input :content, as:  :medium_editor, input_html: { data: { options: '{"spellcheck":false,"toolbar":{"buttons":["bold","italic","underline","anchor"]}}' } }
        end
        f.actions
    end
end
```

`ActiveAdmin`では`form do`のようにコードを追記することで各Viewをカスタマイズすることができます

今回は、`rails g scaffold`で作成している`_form.html.erb`をカスタマイズしているイメージですね

さらに、エディターで作成した求人内容を正しく表示させるために、`show`ページもカスタマイズしていきます

先ほどと同様に`app/admin/jobs.rb`に以下のコードを追加します

```ruby:app/admin/jobs.rb
    show do
        attributes_table do
            row :title
            row (:content) { |job| sanitize(job.content) }
        end
        active_admin_comments
    end
```

さらに、求人データを管理する`index`ページでは求人のタイトルだけを表示できるようにします

`app/admin/jobs.rb`に以下のコードを追加し、`index`をカスタマイズします

```ruby:app/admin/jobs.rb
    index do
        column :id
        column :title

         actions defaults: true do |job|
        end
    end
```

これで[`activeadmin_medium_editor`](https://github.com/blocknotes/activeadmin_medium_editor)は導入できました！

### 求人の一覧ページ＆詳細ページの作成

`rails g controller`コマンドを使い、求人の一覧ページ＆詳細ページを作成します

```shell
rails g controller jobs index show
```

その後、`app/controllers/jobs_controller.rb`を以下のように作成します

```ruby:app/controllers/jobs_controller.rb
class JobsController < ApplicationController
　before_action :set_job, :only => [:show]

  def index
    @jobs = Job.all
  end

  def show
  end

  private

    def set_job
      @job = Job.find(params[:id])
    end
end
```

`app/views/jobs/index.html.erb`を以下のように作成します

```erb:app/views/jobs/index.html.erb
<% @jobs.each do |job| %>
    <%= link_to "#{job.title}", job_path(job) %>
<% end %>
```

`app/views/jobs/show.html.erb`を以下のように作成します

```erb:app/views/jobs/show.html.erb
<h1>Title</h1>

<p>
    <%= @job.title %>
</p>

<h1>Content</h1>

<p>
    <%= sanitize @job.content %>
</p>
```

最後に、`config/routes.rb`を以下のように変更します

```ruby:config/routes.rb
Rails.application.routes.draw do
　root 'jobs#index'
  resources :jobs, :only => [:index, :show]
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

これで求人の一覧ページ＆詳細ページを実装できました！

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
  <%= link_to "Hellojob!", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
</nav>
```

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>Hellojob</title>
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

### Bootstrap4のCard&Gridを使用する

今の状態だと求人一覧が縦に並んでいる状態になり、かつ求人のタイトルしか記載されていません

そこで、先ほど導入した`Bootstrap4`の`Card`と`Gird`を使いレイアウトを調整します

`app/views/jobs/index.html.erb`を以下のように修正します

```erb:app/views/jobs/index.html.erb
<div class="row">
    <% @jobs.each do |job| %>
        <div class="card col-4" style="width: 18rem;">
            <div class="card-body">
                <h5 class="card-title"><%= job.title %></h5>
                <p class="card-text"><%= sanitize job.content %></p>
                <%= link_to "詳細", job_path(job), class: "btn btn-primary" %>
            </div>
        </div>
    <% end %>
</div>
```

これで、求人を三件ずつ横並びにしつつカード風に求人を表示させることができます！

### kaminariでのページネーション

[`kaminari`](https://github.com/kaminari/kaminari)を使い、ページネーションを実装します

まず、`Gemfile`に`gem`を追加します

```ruby:Gemfile
gem 'kaminari'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`app/controllers/jobs_controller.rb`の`index`アクションを以下のようにします

```ruby:app/controllers/jobs_controller.rb
  PAGE_PER = 12

  def index
    @jobs = Job.all.page(params[:page]).per(PAGE_PER)
  end
```

後は、`app/views/jobs/index.html.erb`に以下のコードを追加します

```erb:app/views/jobs/index.html.erb
<%= paginate @jobs %>
```

これで`kaminari`でのページネーションは実装完了です！

以上で、求人サイトのチュートリアルは修了です！