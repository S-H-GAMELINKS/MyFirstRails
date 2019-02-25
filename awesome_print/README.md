# Awesome Printでのログを見やすくする！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

Railsでのコンソールログを見やすくしてくれる[`AwesomePrint`](https://github.com/awesome-print/awesome_print)を導入するチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new awesome_print
```

作成したRailsアプリのディレクトリへと移動します

```shell
cd awesome_print
```

### SQLite3のバージョン修正

先ほどのrails newでsqlite3のインストールがエラーになっている場合は、以下のようにバージョンを指定してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、bundle installを実行します

```shell
bundle install
```

### ScaffoldでCRUDを作成

[`AwesomePrint`](https://github.com/awesome-print/awesome_print)でコンソールログが見やすくなるか確認するために`Post`のCRUDを作成します

```shell
rails g scaffold post title:string content:text
```

その後、マイグレーションを実行します

```shell
rails db:migrate
```

最後に、`config/routes.rb`を開いてルーティングを編集します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'posts#index'
  resources :posts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

### Awesome Printの導入

まず、`Gemfile`に`gem 'awesome_print'`を追加します

```ruby:Gemfile
gem 'awesome_print'
```

その後、`bundle install`を実行します

最後に、`.irbrc`を作成します

```ruby:.irbrc
require "awesome_print"
AwesomePrint.pry!
```

この後、`rails s`で`localhost:3000`にアクセスします

後は、適当に新しい`Post`などを作成してください

コントロールでのログの表示が変わっていれば[`AwesomePrint`](https://github.com/awesome-print/awesome_print)の導入は完了です！
