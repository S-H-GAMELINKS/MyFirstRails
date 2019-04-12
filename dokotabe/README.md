# ぐるなびAPIのサンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

現在の位置情報から周辺のお店の情報を表示してくれるアプリを作るチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new dokotabe --webpack=stimulus
```

`--webpack`は`Rails`で`Weboack`を使いやすくした`Webpacker`というものを使用するというオプションです

`Vue`、`React`、`Angular`、`Elm`、`Stimulus`を使用することができます

今回は`Stimulus`を使用するので`--webpack=stimulus`としています

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd dokotabe
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

これで`SQLte3`のバージョンはOKです！

### Foremanの導入

`Webpacker`を使う場合、`ruby ./bin/webpack-dev-server`というコマンドを実行しつつ、`rails s`でローカルサーバーを起動する必要があります

その為、現状のままではターミナルを複数開いておく必要があり、少々面倒です

そこで、複数のコマンドを並列して実行できる`foreman`を使用します

まず、`Gemfile`に`gem 'foreman'`を追記します

```ruby:Gemfile
gem 'foreman'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`foreman`で使用する`Procfile.dev`を作成します

```
web: bundle exec rails s
webpacker: ruby ./bin/webpack-dev-server
```

あとは、`foreman start -f Procfile.dev`をターミナルで実行するだけです

```shell
foreman start -f Procfile.dev
```

`localhost:5000`にアクセスできればOkです(`foreman`を使用する場合、使用するポートが5000へと変更されています)

### トップページの作成

`rails g controller`を使用し、お店の情報などを表示するトップページを作成します

```shell
rails g controller web index
```

その後、`config/routes.rb`を編集し、`root`へのルーティングを設定します

```config/routes.rb
Rails.application.routes.draw do
　root 'web#index'
end
```

これで`localhost:5000`にアクセスしてページが表示されればOKです

### Bootstrap4の適用

このままではデザインなどが簡素すぎるので`Bootstrap`を使いたいと思います。

まず、`Gemfile`に`gem 'bootstrap', '~> 4.2.1'`と`gem 'jquery-rails'`を追加し、`bundle install`します。

```ruby:Gemfile
gem 'bootstrap', '~> 4.2.1'
gem 'jquery-rails'
```

```shell
bundle install
```

もし、`gem`の依存関係でうまくいかない場合は、`bundle update`を実行してから`bundle install`を実行してください

```shell
bundle update
bundle install
```

その後、`app/assets/javascripts/application.js`と`app/assets/stylesheets/application.scss`を下記のように変更します

```js:app/assets/javascripts/application.js
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require trix
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .
```

```scss:app/assets/stylesheets/application.scss
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, or any plugin's
 * vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS/SCSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 *= require_tree .
 *= require_self
 */
 @import "trix";
 @import "bootstrap";
```

その後、`config/boot.rb`を以下のように修正します

```ruby:config/boot.rb
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

ENV['EXECJS_RUNTIME'] = 'Node'

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
```

これで`Bootstrap`が使用できるようになりました。

最後に、`app/views/layouts/_header.html.erb`を作成し、`app/views/layouts/application.html.erb`でパーシャルとして呼び出します。

```erb:app/views/layouts/_header.html.erb
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <%= link_to "Blog", root_path, class: "navbar-brand" %>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
</nav>
```

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>BlogTutorial</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= render 'layouts/header'%>
    <div class="container">
      <%= yield %>
    </div>
  </body>
</html>
```

### ぐるなびAPIの申請

以下のページにてアカウントを作成後、API使用の申請を行います

[ぐるなび Webサービス](https://api.gnavi.co.jp/api/)

API使用の申請後、メールにてAPIキーが送信されます
そのAPIキーをわかるようにメモしておいてください

### dotenv-railsの導入

ぐるなびから取得した`APIキー`をソースコードにそのまま貼り付けてしまうと悪意のある第三者に利用されてしまう可能性があります
実際に、発生した事例としては以下のようなものがあります

[AWSが不正利用され300万円の請求が届いてから免除までの一部始終](https://qiita.com/AkiyoshiOkano/items/72002409e3be9215ae7e)

[Peing脆弱性案件に見る初動のまずさ](https://www.orangeitems.com/entry/2019/01/29/014328)

こういったことを回避するためにも`dotenv-rails`などを使用してソースコードに直接書かないようにする必要があります

まず、`Gemfile`に`gem 'dotenv-rails'`を追加します

```ruby:Gemfile
gem 'dotenv-rails', '2.5.0'
```

その後、`bundle install`を実行します

```shell
bundle install
```

そして、先ほど取得したAPIキーを`.env`に書き込みます
`.env`は`Gemfile`と同じ位置に作成します

```:.env
GURUNAVI_API=`APIキー`
```

最後に、`.gitignore`を編集し、`.env`を`Git`の管理対象から外します

```:.gitignore
# See https://help.github.com/articles/ignoring-files for more about ignoring files.
#
# If you find yourself ignoring temporary files generated by your text editor
# or operating system, you probably want to add a global ignore instead:
#   git config --global core.excludesfile '~/.gitignore_global'

# Ignore bundler config.
/.bundle

# Ignore the default SQLite database.
/db/*.sqlite3
/db/*.sqlite3-journal

# Ignore all logfiles and tempfiles.
/log/*
/tmp/*
!/log/.keep
!/tmp/.keep

# Ignore uploaded files in development
/storage/*
!/storage/.keep

/node_modules
/yarn-error.log

/public/assets
.byebug_history

# Ignore master key for decrypting credentials and more.
/config/master.key
.env
```

これで`dotenv-rails`の導入は完了です！

### Gonの導入

`dotenv-rails`で読み込んだAPIキーを`JavaScript`へと渡せるように[`Gon`](https://github.com/gazay/gon)を使います

まず、`Gemfile`に`gem 'gon'`を追加します

```ruby:Gemfile
gem 'gon'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`app/views/layouts/application.html.erb`の`<head>`タグ内に以下のコードを追加します

```erb:app/views/layouts/application.html.erb
<%= include_gon %>
```

その後、`app/controllers/web_controller.rb`の`index`アクションを以下のようにします


```ruby:app/controllers/web_controller.rb
def index
    gon.gurunavi_key = ENV['GURUNAVI_API']
end
```

これで、ぐるなびのAPIキーを`JavaScript`へと受け渡すことができるようになりました！

### 位置情報から周辺のお店検索

それでは現在位置情報から周辺のお店情報を取得する機能を実装していきたいと思います

まずは、ぐるなびAPIへと位置情報を送信するために必要なライブラリを追加していきます


```shell
yarn add axios
```

[`axios`](https://github.com/axios/axios)という`JavaScript`での`Ajax`を簡単に取り扱えるライブラリを導入しています
導入にあたっては`yarn`というパッケージマネージャを使用しています

次に、`app/javascript/controllers/gurunavi_controller.js`を以下のように追加します

```js:app/javascript/controllers/gurunavi_controller.js
import { Controller } from "stimulus";
import axios from "axios";

let location = { lati: 0.0, long: 0.0 };

export default class extends Controller {
  static targets = [ "places" ]

  connect() {
    if (navigator.geolocation) {
        alert("この端末では位置情報が取得できます");
    } else {
        alert("この端末では位置情報が取得できません");
    }

    this.getLocation();
  }

  round(number, precision) {
    var shift = function (number, precision, reverseShift) {
      if (reverseShift) {
        precision = -precision;
      }  
      var numArray = ("" + number).split("e");
      return +(numArray[0] + "e" + (numArray[1] ? (+numArray[1] + precision) : precision));
    };
    return shift(Math.round(shift(number, precision, false)), precision, true);
  }

  getLocation() {
    navigator.geolocation.getCurrentPosition(
        (position) => {
            location.lati = this.round(position.coords.latitude, 8);
            location.long = this.round(position.coords.longitude, 8);
            console.log(location);
        },
        (error) => {
            switch(error.code) {
                case 1: //PERMISSION_DENIED
                    alert("位置情報の利用が許可されていません");
                    break;
                case 2: //POSITION_UNAVAILABLE
                    alert("現在位置が取得できませんでした");
                    break;
                case 3: //TIMEOUT
                    alert("タイムアウトになりました");
                    break;
                default:
                    alert("その他のエラー(エラーコード:"+error.code+")");
                break;
            }
        }
    );
  }

  getPlace() {
    const url = 'https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=' + String(gon.gurunavi_key) + '&latitude=' + String(location.lati) + '&longitude=' + String(location.long);

    axios.get(url).then((response) => {
        console.log(response);
        this.placesTarget.innerHTML = "";
        for(var i = 0; i < response.data.rest.length; i++){
            this.placesTarget.innerHTML += `
                                            <div class="card" style="width: 18rem;">
                                              <div class="card-body">
                                                <h5 class="card-title">${response.data.rest[i].name}</h5>
                                                <p class="card-text">住所：${response.data.rest[i].address}</p>
                                                <p class="card-text">TEL：${response.data.rest[i].tel}</p>
                                                <a href="${response.data.rest[i].url}" class="btn btn-primary">お店の詳細を見る</a>
                                              </div>
                                            </div>
                                            `;
        }
    }, (error) => {
        console.log(error);
    })
  }
};
```

あとは、`app/views/web/index.html.erb`を以下のように変更します

```erb:app/views/web/index.html.erb
<div data-controller="gurunavi">
    <button data-action="click->gurunavi#getPlace">検索</button>

    <div data-target="gurunavi.places">
</div>

<%= javascript_pack_tag 'application.js' %>
```

あとは、`foreman start -f Procfile.dev`を実行し、`localhost:5000`にアクセスし`検索`ボタンをクリックして周辺のお店情報が表示されていればOKです

なお、PCからのアクセスだと位置情報が正しく取得されていない場合もあります

