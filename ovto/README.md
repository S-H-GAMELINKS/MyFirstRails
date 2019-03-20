# Ovtoをフロントエンドに導入
## 概要

Railsに初めて触れる方を対象にしたチュートリアルです

[`ovto`](https://github.com/yhara/ovto)というRubyでフロントエンドを書けるフレームワークをRailsに導入するチュートリアル

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new ovto
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd ovto
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

### Opalの導入

[`Opal`](https://github.com/opal/opal)をRailsに導入します

`Gemfile`に`gem 'opal-rails'`を追加します

```ruby:Gemfile
gem 'opal-rails'
```

その後、`bundle install`を実行します

次に、`app/assets/javascripts/application.js`をリネームし、`app/assets/javascripts/application.js.rb`とします

そして、`app/assets/javascripts/application.js.rb`を以下のように修正します

```ruby:app/assets/javascripts/application.js.rb
require 'opal'
require 'rails-ujs'
require 'turbolinks'
require 'activestorage'
require_tree '.'
```

これで`Opal`の導入は完了です！

### 静的なページを作成

次に、`Ovto`で作成したコンポーネントを表示できる静的なページ作成します

```shell
rails g controller web index
```

次に、`config/routes.rb`にて`root`へのルーティングを設定します

```ruby:config.routes.rb
Rails.application.routes.draw do
  root 'web#index'
end

```

### Ovtoの導入

次に、`Ovto`の導入を行います

`Gemfile`に`gem 'ovto'`を追加します

```ruby:Gemfile
gem 'ovto'
```

その後、`bundle install`を実行します

```shell
bundle install
```

その後、`app/assets/javascripts/ovto_app/main.rb`を以下のように作成します

```ruby:app/assets/javascripts/ovto_app/main.rb
require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
  end

  class Actions < Ovto::Actions
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'div' do
        o 'h1', 'Hello Ruby on Rails & Ovto!'
      end
    end
  end
end

MyApp.run(id: 'ovto')
```

最後に、`app/views/web/index.html.erb`に以下のコードを追加します

```erb:app/views/web/index.html.erb
<div id="ovto"></div>
```

あとは`rails s`を実行して

```shell
rails s
```

`localhost:3000`にアクセスし、`Hello Ruby on Rails & Ovto!`と表示されていればOKです

これで`Ovto`の導入は完了です！

### Ovtoでカウンター作成

次に、`Ovto`でカウンターを作成します

`app/assets/javascripts/ovto_app/main.rb`を以下のように変更します

```ruby:app/assets/javascripts/ovto_app/main.rb
require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
    item :count, default: 0
  end

  class Actions < Ovto::Actions
    def add_count(state:, count:)
        return {count: state.count + count}
    end
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'div' do
        o 'h1', 'Hello Ruby on Rails & Ovto!'
        o 'input', type: 'button', onclick: ->(e){ actions.add_count(count: 1) }, value: 'Sum'
        o 'p', state.count
      end
    end
  end
end

MyApp.run(id: 'ovto')
```

これで`Sum`というボタンが表示され、クリックすると表示されている数字が増えていくようになります！

こういった形で`Ovto`でフロントエンドを作ることができます！
