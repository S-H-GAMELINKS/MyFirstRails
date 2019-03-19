# PaperTrailでの差分管理サンプル
## 概要

Railsに初めて触れる方を対象にしたチュートリアルです

[`paper_trail`](https://github.com/paper-trail-gem/paper_trail)を使用して投稿内容の差分管理を行うサンプルアプリを作成するチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new papertrail
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd papertrail
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

### ScaffoldでCRUDを作成

`rails new scaffold`コマンドを使用し、CRUDを作成します

```shell
rails scaffold post title:string content:text
```

その後、`rails db:migrate`でマイグレーションを実行します

```shell
rails db:migrate
```

### PaperTrailの導入

まずは、`Gemfile`に`gem 'papaer_trail'`を追加します

```ruby:Gemfile
gem 'papaer_trail'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`app/models/post.rb`を以下のように変更します

```ruby:app/models/post.rb
class Post < ApplicationRecord
    has_paper_trail
end
```

次に、`app/controllers/posts_controller.rb`の`show`アクションに以下のコードを追加します

```ruby:app/controllers/posts_controller.rb
@pre_post = @post.paper_trail.previous_version
```

最後に、`app/views/posts/show.html.erb`に以下のコードを追加すればOkです！

```erb:app/views/posts/show.html.erb
<p>
  <strong>Pre Content:</strong>
  <%= @pre_post.content %>
</p>
```

これで、新しく作った`content`の内容とその一つまえの`content`の内容が表示されます！




