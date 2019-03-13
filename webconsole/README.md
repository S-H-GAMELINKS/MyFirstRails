# web-consoleの導入
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`web-console`](https://github.com/rails/web-console)を導入して、ブラウザ上でコンソールを使用できるようにするチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new webconsole
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd webconsole
```

### SQLite3のバージョンを修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを変更します

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```

これでOKです！

### ScaffoldでCRUDの作成

`rails g scaffold`を使用して、`web-console`で試す`Model`などを作成します

```shell
rails g scaffold post title:string content:text
```

その後、マイグレーションを実行します

```shell
rails db:migrate
```

これでCRUDが作成できました！

### web-consoleを導入

`web-console`を使用したいと思います

`web-console`自体は、`rails new`の段階で`Gemfile`に導入されています

あとは、`View`に`<%= console %>`を追加することで`web-console`を使用することができます

`app/views/layouts/application.html.erb`の`<body>`タグの中に以下のコードを挿入します

```erb:app/views/layouts/application.html.erb
<% if Rails.env == 'development'%>
    <%= console %>
<% end %>
```

これで`web-console`を使用できます！

あとは、ローカルサーバを起動し、実際にコンソールを操作してみます

```shell
rails s
```

`localhost:3000`にアクセスし、画面下部に表示されているコンソールに以下の内容を入力してください

```shell
Post.create(:title => "test", :content => "test").save
```

その後、ページを再読み込みして作成したデータが表示されていればOKです！