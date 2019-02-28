# FireBaseでのリアルタイムチャット
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

Rails/Stimulus/FireBaseを使用して、リアルタイムにやり取りができるチャットアプリを作成します

## チュートリアル
### Railsのひな型を作る

まずは、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new firebase_chat --webpack=stimulus
```

`--webpack`はRailsで``Webpackを使いやすくした[`Webpacker`](https://github.com/rails/webpacker)を使用するためのオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回は[`Stimulus`](https://github.com/stimulusjs/stimulus)を使用しますので`--webpack=stimulus`としています

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd firebase_chat
```

### SQLite3のバージョンを修正

先ほど`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを修正します

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

`bundle install`を実行します

```shell
bundle install
```

### Foremanを使用する

[`Webpacker`](https://github.com/rails/webpacker)を使用する場合、`ruby ./bin/webpack-dev-server`を実行しつつ、`rails s`でローカルサーバーを起動する必要があります

その為、現状のままではターミナルを複数開いておく必要があり、少々面倒です

そこで、複数のコマンドを並列して実行できる[`foreman`](https://github.com/ddollar/foreman)を使用します

まず、`Gemfile`に`gem 'foreman'`を追記します

```ruby:Gemfile
gem 'foreman'
```

その後、`bundle install`を実行します

`foreman`で使用するコマンドを記述する`Procfile.dev`を作成します

```ruby:Procfile.dev
web: bundle exec rails s
webpacker: ruby ./bin/webpack-dev-server
```

あとは、`foreman start -f Procfile.dev`を実行するだけです

```shell
foreman start -f Procfile.dev
```

`localhost:5000`にアクセスできればOKです！(foremanを使用する場合、ポートが5000へと変更されています)

### ScaffoldでCRUDを作成

`rails g scaffold`コマンドを使い、チャットルームのCRUDを作成します

```shell
rails g scaffold room title:string
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

`config/routes.rb`を修正し、rootへのルーティングを作成します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'rooms#index'
  resources :rooms
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

`foreman start -f Procfile.dev`を実行して、`localhost:5000`にアクセスします

あとは、実際にチャットルームが作成できていればOKです

### FireBaseでのリアルタイムチャット

それでは[`FireBase`](https://firebase.google.com/)を使用して、リアルタイムチャットを作成していきます

まず、[`FireBase`](https://firebase.google.com/)にアクセスし、「コンソール」へ移動をクリックします

「プロジェクトを追加」を選択し、プロジェクト名に「firebase-chat」と入力してプロジェクトを作成します

その後、「次へ」をクリックします

`</>`というアイコンがありますのでそれをクリックします

`apiKey`などが表示されますのでコピーして保存してください

その後、左メニューの`Database`を選択し、`データベースの作成`をクリックします

今回はサンプルですので`テストモード`で作成します

データベースの種類を`Realtime Database`を選択し、ルールを下記のように変更します

```json
{
  /* Visit https://firebase.google.com/docs/database/security to learn more about security rules. */
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

ひとまず、[`FireBase`](https://firebase.google.com/)での作業は終了です

次に、`.env`を作成し以下のように編集します

```.env
API_KEY=<FireBaseで取得したapiKey>
AUTH_DOMAIN=<FireBaseで取得したauthDomain>
DB_URL=<FireBaseで取得したdatabaseURL>
PROJECT_ID=<FireBaseで取得したprojectId>
STORAGE_BUCKET=<FireBaseで取得したstorageBucket>
MESSAGEING_SENDER_ID=<FireBaseで取得したmessagingSenderId>
```

`yarn add firebase`を実行します

```shell
yarn add firebase
```

あとは、`app/javascript/packs/controllers/chat_controller.js`を作成します

```js:app/javascript/packs/controllers/chat_controller.js
import { Controller } from "stimulus"
import FireBase from 'firebase'

const firebase = FireBase.initializeApp({
    apiKey: process.env.API_KEY,
    authDomain: process.env.AUTH_DOMAIN,
    databaseURL: process.env.DB_URL,
    projectId: process.env.PROJECT_ID,
    storageBucket: process.env.STORAGE_BUCKET,
    messagingSenderId: process.env.MESSAGEING_SENDER_ID
});

const database = firebase.database();

export default class extends Controller {
    static get targets() {
        return ["chats", "content"]
    }

    initialize() {
        this.update();
    }

    update() {
        const data = database.ref(location.pathname);

        data.on("value", (snapshot) => {
            const firebase_chats = Object.entries(snapshot.val());

            this.chatsTarget.innerHTML = "";

            for (let i = 0; i < firebase_chats.length; i++) {
                this.chatsTarget.innerHTML += `<p>${firebase_chats[i][1].content}</p>`
            }
        }, (error) => {
            console.log(error);
        })

    }

    submit() {
        database.ref(location.pathname).push({
            content: this.contentTarget.value
        });
        this.contentTarget.value = "";
    }
}
```

最後に、`app/views/show.html.erb`を以下のように変更してチャット機能を使用できるようにします

```erb:app/views/show.html.erb

```

これでRails/Stimulusでのリアルタイムチャットは完成です！

