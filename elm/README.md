# Elmの導入
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

RailsにElmを導入するチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new elm
```

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd elm
```

### Webpackerを使い、Elmを導入

Railsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用します

まず、`Gemfile`に`Webpacker`を追加します

```shell
gem 'webpacker', '4.0.2'
```

なお、`Webpacker`のバージョンを`4.0.2`としているのはElmのインストールエラー回避のためです

`3.5.5`だとインストール時にエラーが発生します

ref: [Elm installer not working #1711](https://github.com/rails/webpacker/issues/1711)

ちなみに、`Webpacker`では、Vue、React、Angular、Elm、Stimulusを使用することができます

`gem`を追加した後、ターミナルで`bundle install`を実行します

```shell
bundle install
```

その後、`Webpacker`のインストールコマンドを実行します

```shell
rails webpacker:install
```

今回はElmを使用するので`rails webpacker:install:elm`を実行します

```shell
rails webpacker:install:elm
```

これでElmをRailへ導入できました！

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

この時、sqlite3がインストールできないエラーが発生するかもしれません その場合は以下のようにsqlite3のバージョンを修正して`bundle install`を実行してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

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

### 静的なファイルを作成

`rails g controller` コマンドを使い、コントローラーを作成します

```shell
rails g controller web index
```

その後、`config/routes.rb`を以下のように編集します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
end
```

`foreman start -f Procfile.dev`を実行して、`localhost:5000`でページが表示されていればOKです

### Elmを使う

それではElmを使ってみましょう

先ほどElmインストールした際に、`app/javascript/packs/hello_elm.js`が作成されています

`app/views/web/index.html.erb`に以下のコードを追加してください

```erb
<%= javascript_pack_tag 'hello_elm' %>
```

その後、`foreman start -f Procfile.dev`を実行し、`localhost:5000`にアクセスします

ブラウザに`Hello Elm!`と表示されていればOKです！

次に、`app/javascript/packs/index.js`を以下のように作成します

```js:app/javascript/packs/index.js
import { Elm } from '../Index'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.createElement('div')

  document.body.appendChild(target)
  Elm.Index.init({
    node: target
  })
})
```

その後、`app/javascript/Index.elm`を以下のように作成します


```elm:app/javascript/Index.elm
module Index exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

main =
    div [] [text "Hello, Elm & Ruby on Rails!"]
```

最後に、`app/views/web/index.html.erb`に以下のコードを追加します

```erb:app/views/web/index.html.erb
<%= javascript_pack_tag 'index' %>
```

あとは、`foreman start -f Procfile.dev`を実行し、`localhost:5000`にアクセスします

ブラウザに`Hello, Elm & Ruby on Rails!`と表示されていればOkです！