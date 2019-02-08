# Comfortable Mexican Sofa サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
[`Comfortable Mexican Sofa`](https://github.com/comfy/comfortable-mexican-sofa)というCMSをRailsへ導入するチュートリアルです

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new cms
```

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd cms
```

### Comfortable Mexican Sofaの導入

まず、`Gemfile`に`gem "comfortable_mexican_sofa", "~> 2.0.0"`を追加します

```ruby:Gemfile
gem "comfortable_mexican_sofa", "~> 2.0.0"
```

その後、`bundle install`を実行します

```shell
bundle install
```

`Comfortable Mexican Sofa`をインストールします

```shell
rails generate comfy:cms
```

最後に、`rails db:migrate`を実行します

```shell
rails db:migrate
```

後は、`rails s`を実行して`localhost:3000/admin`にアクセスします
ユーザー名とパスワードを要求されるので以下のように入力します

- username:username
- password:password

ログインできればOKです！
これで`Comfortable Mexican Sofa`の導入は完了です！

### サイトを作成する

ログインするとサイトを作成する画面に切り替わります
以下の項目を入力して、「Create Site」をクリックします

- Labe      :sample
- Identifier:sapmle
- Hostname  :localhost:3000
- Path      :sample
- Language  :日本語

クリック後、「新規レイアウト」作成画面に切り替わります
以下の項目を入力して、「レイアウトを作成」をクリックします

- レイアウト名: header
- Identifier: header
- アプリケーションレイアウト: application
- コンテンツ: Hogehoge {{ cms:wysiwyg content }}

次に、画面左のメニュー内にある「ページ」を選択し、以下のように入力します

- ラベル:index
- レイアウト: header
- Content: Hello Comfortable Mexican Sofa!

「ページを作成」をクリックしページを作成します

最後に、ページとレイアウトが作成できているか確認します

画面左側にある「サイト」をクリックし、`localhost:3000/sample`にアクセスします
ブラウザに以下のように表示されていればページとレイアウトが作成されています

```
Hogehoge
Hello Comfortable Mexican Sofa!
```

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

最後に、レイアウトから`header`レイアウトを下記のように編集します

```html:header
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <a href="/sample" class="navbar-brand">CMS</a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Menu
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <a href="/sample" class="dropdown-item">Home</a>
  </div>
</div>
</nav>

{{ cms:wysiwyg content }}
```

「レイアウトを更新」をクリックするとレイアウトが修正後の内容に更新されます

`localhost:3000/sample`でナビゲーションバーが表示されていればOKです

