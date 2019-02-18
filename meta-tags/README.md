# meta-tagsでのSEO対策サンプル！
## 概要

Railsにこれから初めて触れる方を対象としてチュートリアルです

今回は、[`meta-tags`](https://github.com/kpumuk/meta-tags)を使用したSEO対策チュートリアルになります

## チュートリアル
## Railsのひな型を作成する

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new meta-tags
```

次に、作成した`meta-tags`ディレクトリへと移動します

```shell
cd meta-tags
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

### meta-tagsの導入

それでは`meta-tags`の導入を行いたいと思います

まずは、`Gemfile`に`meta-tags`を追加します

```ruby:Gemfile
# Using Meta-tags
gem 'meta-tags'
```

その後、`bundle install`を行います

```shell
bundle install
```

`bundle install`後、`rails generate meta_tags:install`を実行します

```shell
rails generate meta_tags:install
```

最後に`app/views/layouts/application.html.erb`に`<%= display_meta_tags site: 'My First Rails' %>`を追加します

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>MetaTags</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= display_meta_tags site: 'My First Rails' %>
    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= yield %>
  </body>
</html>
```

これで`meta-tags`を使ってのSEO対策が実装できました！

## おまけ
### 各ページごとにdescriptionを追加したい

場合によっては、各ページごとに`description`を追加したい場合があると思います

その場合は、まず以下のように`app/controllers/application_controller.rb`を編集します

```ruby:app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
    before_action :set_meta_tags

    private

        def set_meta_tags
            @page_title       = 'My First Rails'
            @page_description = 'Rails tutorial for programming beginner'
            @page_keywords    = 'Rails progiramming beginner'
        end
end
```

次に、動きを確認するためのページを作成します

```shell
rails g controller web inde about contact
```

その後、`app/controllers/web_controller.rb`を編集します

```ruby:app/controllers/web_controller.rb
class WebController < ApplicationController
  def index
    @page_title       = 'Index'
    @page_description = 'Rails tutorial for programming beginner Index'
    @page_keywords    = 'Rails progiramming beginner'
  end

  def about
    @page_title       = 'About'
    @page_description = 'Rails tutorial for programming beginner About'
    @page_keywords    = 'Rails progiramming beginner'
  end

  def contact
    @page_title       = 'Contact'
    @page_description = 'Rails tutorial for programming beginner Contact'
    @page_keywords    = 'Rails progiramming beginner'
  end
end
```

これで`localhost:3000/web/index`、`localhost:3000/web/about`、`localhost:3000/web/contact`にアクセスすると各ページの`<meta>`タグ内に追記された`description`などが表示されています！






