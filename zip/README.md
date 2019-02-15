# ActiveStorageでのZIPファイルアップロード
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
本チュートリアルでは、[`ActiveStorage`](https://railsguides.jp/active_storage_overview.html)を使用したZipファイルのアップロードサイトを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new zip
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd zip
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

### ActiveStorageのインストール

早速、`ActiveStorage`をインストールします
インストール方法は非常に簡単で、以下のコマンドを実行するだけです

```shell
rails active_storage:install
```

新しいマイグレーションファイルが生成されるので、`rails db:migrate`を実行します

```shell
rails db:migrate
```

次に、Zipファイルを取り扱う`Model`を作成します
特にカラムなどは指定しなくてもOKです

```shell
rails g model zipfile
```

再び、`rails db:migrate`を実行します

作成した`Zipfile`モデルに`has_one_attached :file`を追加します

```ruby:app/models/zipfile.rb
class Zipfile < ApplicationRecord
    has_one_attached :file
end
```

次に、`rails g controller web index`を実行してアップロードするフォームを作成します

```shell
rails g controller web index
```

コマンド実行後、`config/routes.rb`と`app/views/web/index.html.erb`を以下のように修正します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  get 'web/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

```ruby:app/controllers/web_controller.rb
class WebController < ApplicationController
  def index
    @zipfile = Zipfile.new
  end
end
```

```erb:app/views/web/index.html.erb
<h1>Web#index</h1>
<p>Find me in app/views/web/index.html.erb</p>

<%= form_with model: @zipfile, local: true do |form| %>
    <%= form.file_field :file %><br>
    <%= form.submit %>
<% end %>
```

これで`rails s`でローカルサーバを建てた後、`localhost:3000`にアクセスするとフォームが表示されています

次に、`app/controllers/zipfiles_controller.rb`を作成します

```ruby:app/controllers/zipfiles_controller.rb

class ZipfilesController < ApplicationController
    def create
        @zip = Zipfile.new(zipfile_params)
        @zip.save!
        redirect_to :root
    end

     private

         def zipfile_params
            params.require(:zipfile).permit(:file)
        end
end
```

その後、`config/routes.rb`を編集します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  get 'web/index'
  resources :zipfiles, :only => [:create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

これで`localhost:3000`からZIPファイルをアップロードできるようになりました！
ちなみに、アップロードしたZIPファイルは`storage`ディレクトリ以下にアップロードされています

### ダウンロードもできるようにする

ZIPファイルをアップロードするだけでは面白くありません
せっかくアップロードしたので、ダウンロードもできるようにしたいと思います

まず、`config/routes.rb`に`/zipifiles`へのルーティングを追加します
追加で、`root_path`を変更します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'zipfiles#index'
  get 'web/index'
  resources :zipfiles, :only => [:index, :create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

次に、`app/controllers/zipfiles_controller.rb`に`index`アクションを追加します

```ruby:app/controllers/zipfiles_controller.rb
class ZipfilesController < ApplicationController

    def index
        @zipfiles = Zipfile.all
    end

    def create
        @zip = Zipfile.new(zipfile_params)
        @zip.save!
        redirect_to :root
    end

    private

        def zipfile_params
            params.require(:zipfile).permit(:file)
        end
end
```

最後に、`app/views/zipfiles/index.html.erb`を作成します

```erb:app/views/zipfiles/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Zipfiles</h1>

<table>
  <thead>
    <tr>
      <th>Link</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @zipfiles.each do |zipfile| %>
      <tr>
        <td><%= link_to 'Download', rails_blob_path(zipfile.file, disposition: "attachment") %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

実装の肝となっているのは`link_to`ヘルパーメソッドに渡している`rails_blob_path`です
`rails_blob_path`で`ActiveStorage`へのパスを表示できるようにしています
そのファイルパスを`link_to`へと渡すことでダウンロードができるようになっています

これで、ZIPファイルをダウンロードできるようになりました！

## ライセンス
[MITライセンス](../LICENSE)