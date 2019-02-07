# Blog サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
RailsとVue.jsを使ってSPA(シングルページアプリケーション)のサンプルを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new spa --webpack=vue
```

`--webpack`はRailsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用するというオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回はVue.jsを使用するので`--webpack=vue`としています

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd spa
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

### 静的なファイルを作成

`rails g controller` コマンドを使い、静的なファイルを作成します

```shell
rails g controller web index
```

`foreman start -f Procfile.dev`を実行して、`localhost:5000/web/index`にアクセスできればOKです

### Vue.jsを使う

`app/javascript/packs`ディレクトリ内に`index.js`を作成します

`app/javascript/packs/index.js`を以下のように変更します

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue.esm';

const app = new Vue({
    el: '.app',
    data: function() {
        return {
            message: "Hello World! For Vue.js & Rails!"
        }
    }
})
```

次に、`app/views/web/index.html.erb`を以下のように変更します

```erb:app/views/web/index.html.erb
<div class="app">
    {{message}}
</div>

<%= javascript_pack_tag 'index' %>
```

`foreman start -f Procfile.dev`を実行して、`localhost:5000/web/index`にアクセスします
画面に`Hello World! For Vue.js & Rails！`と表示されていればOKです

### Bootstrapの導入

`Webpacker`を使用する場合は、JavaScriptパッケージマネージャの`yarn`経由で`Bootstrap`をインストールします

```shell
yarn add bootstrap
```

付随して、`jquery`と`popper.js`もインストールします

```shell
yarn add jquery
yarn add popper.js
```

次に、`app/javascript/packs/index.js`と`app/assets/stylesheets/application.css`を以下のように変更します

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue.esm';
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    data: function() {
        return {
            message: "Hello World! For Vue.js & Rails!"
        }
    }
})
```

```css:app/assets/stylesheets/application.css
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
 *= require bootstrap/dist/css/bootstrap
 *= require_tree .
 *= require_self
 */
```

これで`Bootstrap`が使用できるようになります

では、実際にナビゲーションバーを作成してみます

`app/javascript/packs/components/layouts/Header.vue`を作成します

```vue:app/javascript/packs/components/layouts/Header.vue
<template>
    <div>
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <a class="navbar-brand" href="#">SPA</a>
            <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Menu
                </button>
                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                    <a href="/" class="dropdown-item">Top</a>
                    <a href="/about" class="dropdown-item">About</a>
                    <a href="/contact" class="dropdown-item">Contact</a>
                </div>
            </div>
        </nav>
    </div>    
</template>
```

`app/views/web/index.html.erb`と`app/javascript/packs/index.js`を以下のように変更します

```erb:app/views/web/index.html.erb
<div class="app">
    <nav-bar></nav-bar>
    {{message}}
</div>

<%= javascript_pack_tag 'index' %>
```

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue.esm';
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

import Header from './components/layouts/Header.vue';

Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    components: {
        'nav-bar': Header
    },
    data: function() {
        return {
            message: "Hello World! For Vue.js & Rails!"
        }
    }
})
```

`foreman start -f Procfile.dev`でローカルサーバを起動して、`localhost:5000/web/index`を開きます
ナビゲーションバーが表示されていると思います

### vue-routerによるSPA作成

まず、SPAとして表示する書くページを`app/javascript/packs/components/web`ディレクトリに作成します

```vue:app/javascript/packs/components/web/Index.vue
<template>
    <div class="container">
        <h1>Index Pages</h1>

        <p>ここはIndexページです！</p>
    </div>    
</template>
```

```vue:app/javascript/packs/components/web/About.vue
<template>
    <div class="container">
        <h1>About Pages</h1>

        <p>ここはAboutページです！</p>
    </div>    
</template>
```

```vue:app/javascript/packs/components/web/Contact.vue
<template>
    <div class="container">
        <h1>Contact Pages</h1>

        <p>ここはContactページです！</p>
    </div>    
</template>
```

各ページのコンポーネントを作成後、`yarn add vue-router`で`vue-router`をインストールします

```shell
yarn add vue-router
```

次に、`app/javascript/packs/router/router.js`を作成します

```js:app/javascript/pack/router/router.js
import Vue from 'vue/dist/vue.esm';
import VueRouter from 'vue-router';

import Index from '../components/web/Index.vue';
import About from '../components/web/About.vue';
import Contact from '../components/web/Contact.vue';

Vue.use(VueRouter);

export default new VueRouter({
    mode: 'history',
    routes: [
        { path: '/', component: Index },
        { path: '/about', component: About },
        { path: '/contact', component: Contact }
    ]
})
```

最後に、`app/javascript/packs/index.js`、`app/views/web/index.html.erb`、`config/routes.rb`を以下のように編集します

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue.esm';
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

import Header from './components/layouts/Header.vue';
import Router from './router/router';

Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    router: Router,
    components: {
        'nav-bar': Header
    },
    data: function() {
        return {
            message: "Hello World! For Vue.js & Rails!"
        }
    }
})
```

```erb:app/views/web/index.html.erb
<div class="app">
    <nav-bar></nav-bar>
    <div class="container">
        <router-view></router-view>
    </div>
    {{message}}
</div>

<%= javascript_pack_tag 'index' %>
```

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  get '/about', to: 'web#index'
  get '/contact', to: 'web#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

これで、SPAサンプルが作成できました！