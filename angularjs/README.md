# Angular.jsの導入
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

RailsとAngular.jsを使ってサンプルアプリを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new angularjs --webpack=angular
```

`--webpack`はRailsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用するというオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回はAngular.jsを使用するので`--webpack=angular`としています

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd angularjs
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

### Angular.jsを使う

まず、`app/views/web/index.html.erb`を以下のように変更します

```erb:app/views/web/index.html.erb
<helllo-anguler>Loading...</hello-anguler>
<%= javascript_pack_tag 'hello_react' %>
```

最初に実行した`rails new`の段階で`app/javascript/packs/hello_angular.js`が作成されています

それを`<%= javascript_pack_tag 'hello_angular' %>`を使い、読み込んでいます

また読み込まれた`JavaScript`のコンポーネントなどを`<helllo-anguler>Loading...</hello-anguler>`にて描画しています

`app/views/web/index.html.erb`を編集後、`foreman start -f Procfile.dev`を実行して、`Hello Angular`と表示されていればOKです！

### React.js経由でBootstrapを使う

次に、`Anguler.js`経由でBootstrapを使用してみたいと思います

まずは、各コンポーネントを作成していきます

`Header`コンポーネントとして利用する`app/javascript/header_angular`ディレクトリを作成します

ディレクトリ内に、`app/javascript/header_angular/header/header.component.ts`を作成します

```ts:app/javascript/header_angular/header/header.component.ts
import { Component } from '@angular/core';

 @Component({
  selector: 'header-angular',
  template: 
  `
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
  <a class="navbar-brand" href="#">{{name}}</a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="collapse navbar-collapse" id="navbarNav">
    <ul class="navbar-nav">
      <li class="nav-item active">
        <a class="nav-link" href="#">Home <span class="sr-only">(current)</span></a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="#">Features</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="#">Pricing</a>
      </li>
      <li class="nav-item">
        <a class="nav-link disabled" href="#" tabindex="-1" aria-disabled="true">Disabled</a>
      </li>
    </ul>
  </div>
  </nav>
  `
})
export class HeaderComponent {
  name = 'Angular.js/Rails';
}
```

次に、`app/javascript/header_angular/header/header.module.ts`を作成します

```ts:app/javascript/header_angular/header/header.module.ts
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

 import { HeaderComponent } from './header.component';

 @NgModule({
  declarations: [
    HeaderComponent
  ],
  imports: [
    BrowserModule
  ],
  providers: [],
  bootstrap: [HeaderComponent]
})
export class HeaderModule { }
```

そして、`app/javascript/header_angular/index.ts`を作成します


```ts:app/javascript/header_angular/index.ts

import './polyfills.ts';

 import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { HeaderModule } from './header/header.module';

 document.addEventListener('DOMContentLoaded', () => {
  platformBrowserDynamic().bootstrapModule(HeaderModule);
});
```

最後に、`app/javascript/header_angular/polyfills.ts`を作成します

```ts:app/javascript/header_angular/polyfills.ts
/**
 * This file includes polyfills needed by Angular and is loaded before the app.
 * You can add your own extra polyfills to this file.
 *
 * This file is divided into 2 sections:
 *   1. Browser polyfills. These are applied before loading ZoneJS and are sorted by browsers.
 *   2. Application imports. Files imported after ZoneJS that should be loaded before your main
 *      file.
 *
 * The current setup is for so-called "evergreen" browsers; the last versions of browsers that
 * automatically update themselves. This includes Safari >= 10, Chrome >= 55 (including Opera),
 * Edge >= 13 on the desktop, and iOS 10 and Chrome on mobile.
 *
 * Learn more in https://angular.io/docs/ts/latest/guide/browser-support.html
 */

 /***************************************************************************************************
 * BROWSER POLYFILLS
 */

 /** IE9, IE10 and IE11 requires all of the following polyfills. **/
// import 'core-js/es6/symbol';
// import 'core-js/es6/object';
// import 'core-js/es6/function';
// import 'core-js/es6/parse-int';
// import 'core-js/es6/parse-float';
// import 'core-js/es6/number';
// import 'core-js/es6/math';
// import 'core-js/es6/string';
// import 'core-js/es6/date';
// import 'core-js/es6/array';
// import 'core-js/es6/regexp';
// import 'core-js/es6/map';
// import 'core-js/es6/weak-map';
// import 'core-js/es6/set';

 /** IE10 and IE11 requires the following for NgClass support on SVG elements */
// import 'classlist.js';  // Run `npm install --save classlist.js`.

 /** Evergreen browsers require these. **/
import 'core-js/es6/reflect';
import 'core-js/es7/reflect';


 /**
 * Required to support Web Animations `@angular/animation`.
 * Needed for: All but Chrome, Firefox and Opera. http://caniuse.com/#feat=web-animation
 **/
// import 'web-animations-js';  // Run `npm install --save web-animations-js`.



 /***************************************************************************************************
 * Zone JS is required by Angular itself.
 */
import 'zone.js/dist/zone';
// import 'zone.js/dist/long-stack-trace-zone' // async stack traces with zone.js



 /***************************************************************************************************
 * APPLICATION IMPORTS
 */

 /**
 * Date, currency, decimal and percent pipes.
 * Needed for: All but Chrome, Firefox, Edge, IE11 and Safari 10
 */
// import 'intl';  // Run `npm install --save intl`.
/**
 * Need to import at least one locale-data with intl.
 */
// import 'intl/locale-data/jsonp/en';
```

あとは、`app/javascript/packs/hello_angular.js`で作成したコンポーネントを`require`し、`app/views/web/index.html.erb`にてコンポーネントを表示します

```js:app/javascript/packs/hello_angular.js
require('../header_angular')
```

```erb:app/views/web/index.html.erb
<h1>Web#index</h1>
<p>Find me in app/views/web/index.html.erb</p>
<header-angular>Loading...</header-angular>
<hello-angular>Loading...</hello-angular>
<%= javascript_pack_tag 'hello_angular' %> 
```

`Gemfile`に`gem 'bootstrap', '~> 4.2.1'`と`gem 'jquery-rails'`を追加し、`bundle install`します。

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

これで`Bootstrap`が使用できるようになりました

