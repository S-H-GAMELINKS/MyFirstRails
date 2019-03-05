# Ransackでの検索機能実装！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`ransack`](https://github.com/activerecord-hackery/ransack)を使用した検索機能のチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new ransack
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd ransack
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

### Scaffoldで検索するモデルとCRUDを作成

`rails g scaffold`を使用し、`ransack`で検索するための`Model`を作成します

```shell
rails g scaffold post title:string content:text
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

### Ransackの導入

`Gemfile`に`gem 'ransack'`を追加します

```ruby:Gemfile
gem 'ransack'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`ransack`を使用して検索できるように実装していきます

`app/views/posts/index.html.erb`に`ransack`での検索フォームを追加します

```erb:app/views/posts/index.html.erb
<p id="notice"><%= notice %></p>

<%= search_form_for @search do |f| %>
  <div class="form-group">
    <%= f.label :content_cont, "Content" %>
    <%= f.text_field :name_cont, class: "form-control" %>
  </div>
  <div class="actions"><%= f.submit "Search" %></div>
<% end %>

<h1>Posts</h1>

<table>
<thead>
  <tr>
    <th>Title</th>
    <th>Content</th>
    <th colspan="3"></th>
  </tr>
</thead>

<tbody>
  <% @posts.each do |post| %>
    <tr>
      <td><%= post.title %></td>
      <td><%= post.content %></td>
      <td><%= link_to 'Show', post %></td>
      <td><%= link_to 'Edit', edit_post_path(post) %></td>
      <td><%= link_to 'Destroy', post, method: :delete, data: { confirm: 'Are you sure?' } %></td>
    </tr>
  <% end %>
</tbody>
</table>

<%= link_to 'New post', new_post_path %>
```

あとは、`app/controllers/posts_controller.rb`の`index`アクションを以下のように変更します

```ruby:app/controllers/posts_controller.rb
  def index
    @search = Post.search(params[:q])
    @posts = @search.result
  end
```

最後に、`rails s`でローカルサーバを起動します

`localhost:3000/posts`にアクセスすると検索フォームが表示されています
あとは実際に検索を行ってみてください！

