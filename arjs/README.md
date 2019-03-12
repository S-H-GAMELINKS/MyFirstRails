# AR.jsでのAR機能の組み込み！
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`AR.js`](https://github.com/jeromeetienne/AR.js)を使用してAR機能を組み込むチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new arjs
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd arjs
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

これでOKです！

### Viewの作成

`rails g controller`コマンドを使用して、`View`を作成します

```shell
rails g controller web index
```

その後、`config/routes.rb`を編集します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  get 'web/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

`View`の作成はこれでOKです！

### AR.jsの導入

それでは`AR.js`を導入していきたいと思います

`app/views/web/index.html`を以下のように変更します

```erb:
<script src="https://aframe.io/releases/0.8.2/aframe.min.js"></script>
<script src="https://cdn.rawgit.com/jeromeetienne/AR.js/1.6.2/aframe/build/aframe-ar.js"></script>

<a-scene embedded arjs>
    <a-marker preset="hiro">
        <a-box position='0 0.5 0' material='color: black;'></a-box>
    </a-marker>
    <a-entity camera></a-entity>
</a-scene>
```

あとは、`rails s`を実行し、`localhost:3000`にアクセスしてください

画面全体がカメラとして動作していると思います
最後に、以下の画像を読み込んでみてください

![Hiro](https://github.com/jeromeetienne/AR.js/blob/master/data/images/HIRO.jpg)

黒い四角が表示されていればOKです！