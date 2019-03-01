# Heavens Door サンプル
## 概要

Railsにこれから初めて触れる肩を対象にしたチュートリアルです

Rails/Rubyのコミッターである[a_matsuda](https://github.com/amatsuda)さんが制作されている[heavens_door](https://github.com/amatsuda/heavens_door)をRailsに導入するチュートリアルです

## チュートリアル
### Railsのひな型を作る

まずは、`rails new`で`heavens_door`を試すサンプルアプリを作ります

```shell
rails new heavens_door
```

次に、作成したRailsアプリのディレクトリに移動します

```shell
cd heavens_door
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

### テスト用CRUD作成

テストするためのCRUDを作成します

```shell
rails g scaffold post title content
```

その後、`rails db:migrate`を実行します

```shell
rails db:migrate RAILS_ENV=test
```

`rails db:migrate RAILS_ENV=test`でマイグレーションが実行できない場合は、`Gemfile`の`gem 'chromedriver-helper'`をコメントアウトします

### heavens_doorの導入

`heavens_door`を導入したいと思います！

`Gemfile`に`heavens_door`を追加します

```ruby:Gemfile
gem 'heavens_door', group: :development
```

`bundle install`で`gem`をインストールします

```shell
bundle install
```

### heavens_doorを使う

最後に、`heavens_door`を使ってみましょう！

まず、`test/intgration/posts_test.rb`を作成し、以下のようにします

```ruby:test/intgration/posts_test.rb
require 'capybara/rails'
require 'capybara/minitest'

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def heavens_door
  end
end
```

その後、`rails s`でローカルサーバを起動し、`localhost:3000/posts`にアクセスします

```shell
rails s
```

あとは画面右上に表示されているボタンをクリックするとUI操作の記録がはじまります

適当に操作したあと、バインダーマークをクリックするとUIテストのコードがクリップされます

あとは、`test/intgration/posts_test.rb`にクリップしたコードを貼り付けます

```ruby:test/intgration/posts_test.rb
require 'capybara/rails'
require 'capybara/minitest'

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def heavens_door
    scenario 'GENERATED' do
        visit '/posts'
    
        click_link 'New Post'
    
        fill_in 'Title', with: 'test'
        fill_in 'Content', with: 'aaaaaaaaaaaaaaaaaaaaaaaaa'
        click_button 'Create Post'
    
        click_link 'Back'
    end    
  end
end
```

最後に、`rails test`を実行してください

```shell
rails test
```

テストが実行されていればOKです！

これでRailsアプリに`Heavens Door`を導入できました！