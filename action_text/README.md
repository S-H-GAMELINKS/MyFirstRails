# ActionTextを試す！
## 概要

Railsに初めて触れる方を対象にしたチュートリアルです

`Rails6`から追加される`ActionText`を使用するチュートリアルです

## チュートリアル
### Rails6のインストール

まず、`Rails6`をインストールします

`Rails6`はRuby`2.5`以上でないとインストールできません
`2.5`より古いバージョンである場合、先にRubyのバージョンを上げておいてください

`gem install rails -v '6.0.0beta3'`を実行します

```shell
gem install rails -v '6.0.0beta3' --webpack=stimulus
```

インストールできていればOKです

### Railsのひな型アプリを作る

まずは`rails new`を実行し、`Rails`アプリのひな型を作成します

```shell
rails _6.0.0beta3_ new action_text --webpack=
```

その後、`action_text`へと移動します

```shell
cd action_text
```

### SQLite3のバージョンを修正

先ほどのrails newでsqlite3のインストールがエラーになっている場合は、以下のようにバージョンを修正します

```ruby:Gemfile
gem 'sqlite3', git: "https://github.com/larskanis/sqlite3-ruby", branch: "add-gemspec"
```

その後、`bundle install`を実行します

```shell
bundle install
```

これでOKです！

### ScaffoldでCRUDを作成

`rails g scaffold`を使い、CRUDのひな型を作ります

```shell
rails g scaffold post title:string content:text
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

最後に、`config/routes.rb`に以下のように`root`を設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'posts#index'
  resources :posts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

あとは`rails s`を実行して、`localhost:3000`にアクセスできればOKです

### ActionTextの導入

まず、`bundle exec rails action_text:install`を実行します

```shell
bundle exec rails action_text:install
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate
```

その後、`app/models/post.rb`にリレーションを追加します

```ruby:app/models/post.rb
class Post < ApplicationRecord
    has_rich_text :content
end
```

次に、`app/views/posts/_form.html.erb`の`content`に`rich_text_area`を使用します

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
    <%= form.rich_text_area :content %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

最後に、`Gemfile`に`gem 'image_processing', '~> 1.2'`を追加し、

```ruby:Gemfile
gem 'image_processing', '~> 1.2'
```

`bundle install`を実行します

```shell
bundle install
```

後は、`rails s`でローカルサーバを起動します

```shell
rails s
```

あとは、実際に`localhost:3000/posts/new`でテキストを入力してみてください
また画像をドラッグ＆ドロップで貼り付けることもできます

これで`ActionText`の導入は完了です！



