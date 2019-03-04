# Rails/Stimulusでのリアルタイムチャット！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

RailsとStimulusを使ってリアルタイムに更新されるチャットアプリを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new realtime_chat --webpack=stimulus
```

`--webpack`はRailsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用するというオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回は[`Stimulus`](https://github.com/stimulusjs/stimulus)を使用するので`--webpack=stimulus`としています

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd realtime_chat
```

### SQLite3のバージョンを修正

SQLite3のバージョン修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを指定してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```

### Foremanを使う

[`Webpacker`](https://github.com/rails/webpacker)を使う場合、`ruby ./bin/webpack-dev-server`というコマンドを実行しつつ、`rails s`でローカルサーバーを起動する必要があります

その為、現状のままではターミナルを複数開いておく必要があり、少々面倒です

そこで、複数のコマンドを並列して実行できる[`foreman`](https://github.com/ddollar/foreman)を使用します

まず、`Gemfile`に`gem 'foreman'`を追記します

```ruby:Gemfile
gem 'foreman'
```

その後、`bundle install`

```shell
bundle install
```

次に、`foreman`で使用する`Procfile.dev`を作成します

```Procfile.dev
web: bundle exec rails s
webpacker: ruby ./bin/webpack-dev-server
```

あとは、`foreman start -f Procfile.dev`をターミナルで実行するだけです

```shell
foreman start -f Procfile.dev
```

`localhost:5000`にアクセスできればOkです(`foreman`を使用する場合、使用するポートが5000へと変更されています)

### チャットルームの作成

`rails g scaffold`コマンドを使い、チャットルーム作成のCRUDを作ります

```shell
rails g scaffold room title:string
```

その後、`rails db:migrate`を実行し、マイグレーションを行います

```shell
rails db:migrate
```

あとは、`foreman start -f Procfile.dev`を実行してローカルサーバを起動します

`localhost:5000/rooms`にアクセスし、チャットルームを作成できればOKです

### チャット機能の作成

ルームを作成したので、次はチャットができるようにしたいと思います

まず、チャットを取り扱う`Talk`モデルを作成したいと思います

```shell
rails g model talk content:string room:references
```

その後、マイグレーションを行います

```shell
rails db:migrate
```

次に、`app/models/room.rb`にリレーションを追加します

```ruby:app/models/room.rb
class Room < ApplicationRecord
    has_many :talks
end
```

そして、`config/routes.rb`にルーティングを追加します

```ruby:config/routes.rb
Rails.application.routes.draw do
　root 'rooms#index'
  resources :rooms do
    resources :talks, :only => [:index, :create]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```
次に、各チャットルームにチャットの入力フォームを作成します

まずは`app/views/rooms/show.html.erb`に以下を追加します

```erb:
<h2>Chats</h2>
    <div data-controller="chat">
        <div data-target="chat.talks"></div>

        <input data-target="chat.content">
        <button data-action="click->chat#submit">add</div>
    </div>

<%= javascript_pack_tag 'application.js' %>
```

このように変更します

```erb:app/views/rooms/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @room.title %>
</p>

<h2>Chats</h2>
    <div data-controller="chat" data-chat-refresh-interval="100">
        <div data-target="chat.talks"></div>

        <input data-target="chat.content">
        <button data-action="click->chat#submit">add</div>
    </div>

<%= link_to 'Edit', edit_room_path(@room) %> |
<%= link_to 'Back', rooms_path %>
```

その後、`app/javascript/controllers/chat_controller.js`を作成します

```js:app/javascript/controllers/chat_controller.js
import { Controller } from "stimulus";
import axios from "axios";

export default class extends Controller {
    static get targets() {
        return ["talks", "content"];
    }

    connect() {
        this.load();

        if (this.data.has("refreshInterval")) {
            this.startRefreshing()
        }
    }

    load() {
        axios.get(`${location.pathname}`).then((res) => {
            this.talksTarget.innerHTML = res.data;
        }, (error) => {
            console.log(error);
        })
    }

    submit() {
        axios.post(`${location.pathname}`, { talk: { content: `${this.contentTarget.value}` }}).then((res) => {
            this.contentTarget.value = "";
            console.log(res);
        }, (error) => {
            console.log(error);
        })
    }

    startRefreshing() {
        this.refreshTimer = setInterval(() => {
          this.load()
        }, this.data.get("refreshInterval"))
    }

    stopRefreshing() {
        if (this.refreshTimer) {
          clearInterval(this.refreshTimer)
        }
    }
}
```

最後に、`app/controllers/talks_controller.rb`を作成します

```ruby:app/controllers/talks_controller.rb
class TalksController < ActionController::API
    before_action :set_room

    def index
        @talks = @room.talks.all
        render json: @talks.map!{|talk| "<p>#{talk.content}</p>"}.inject(:+)
    end

    def create
        @room.comments.create! talks_params
        redirect_to @room
    end

    private
        def set_room
            @room = Room.find(params[:room_id])
        end

         def talks_params
            params.required(:talk).permit(:content)
        end
end
```

これで、チャットを送信するとリアルタイムに更新されます！