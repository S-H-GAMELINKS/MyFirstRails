# Rails/Vue.jsでの家計簿アプリ
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
RailsとVue.jsを使って家計簿アプリのサンプルを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new accountbook --webpack=vue --api
```

`--webpack`はRailsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用するというオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回はVue.jsを使用するので`--webpack=vue`としています

また、`--api`というオプションはRailsのAPIモードを使用するというものです
APIモードを使用すると、`rails g controller`などで`view`ファイルが作成されず、レスポンスをJSON形式で返してくれるようになります

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd accountbook
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

次に、`app/controllers/web_controller.rb`を以下のように編集します

```ruby:app/controllers/web_controller.rb
class WebController < ActionController::Base
  def index
  end
end
```

APIモードで作成しているので`WebController < ActionController::API`となっているものを`WebController < ActionController::Base`に修正しています

`app/view/web/index.html.erb`を作成します

```erb:app/view/web/index.html.erb
Welcome!
```

その後、`config/routes.rb`を以下のように編集します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
end

```

`foreman start -f Procfile.dev`を実行して、`localhost:5000`で`Welcome!`と表示されていればOKです

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

`foreman start -f Procfile.dev`を実行して、`localhost:5000`にアクセスします
画面に`Hello World! For Vue.js & Rails！`と表示されていればOKです

### Bootstrapの導入

`Webpacker`を使用する場合は、JavaScriptパッケージマネージャの`yarn`経由で`Bootstrap`をインストールします

```shell
yarn add bootstrap
```

付随して、`jquery`、`popper.js`、`style-loader`、`css-loader`もインストールします

```shell
yarn add jquery
yarn add popper.js
yarn add style-loader
yarn add css-loader
```

次に、`app/javascript/packs/index.js`と`config/webpack/environment.js`を以下のように変更します

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue.esm';
import * as Jquery from 'jquery';
import * as Popper from 'popper.js'
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

Vue.use(Jquery);
Vue.use(Popper);
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

```js:config/webpack/environment.js
const { environment } = require('@rails/webpacker')
const vue =  require('./loaders/vue')

environment.loaders.append('vue', vue)

environment.loaders.append('css', {
    test: /\.css$/,
    use: [
        'style-loader',
        'css-loader'
    ]
})

module.exports = environment
```

これで`Bootstrap`が使用できるようになります

では、実際にナビゲーションバーを作成してみます

`app/javascript/packs/components/layouts/Header.vue`を作成します

```vue:app/javascript/packs/components/layouts/Header.vue
<template>
    <div>
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <a class="navbar-brand" href="/">Account Book</a>
            <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Menu
                </button>
                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                    <a href="/" class="dropdown-item">Top</a>
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
import * as Jquery from 'jquery';
import * as Popper from 'popper.js'
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

import Header from './components/layouts/Header.vue';

Vue.use(Jquery);
Vue.use(Popper);
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

`foreman start -f Procfile.dev`でローカルサーバを起動して、`localhost:5000`を開きます
ナビゲーションバーが表示されていればOKです

### 家計簿データをやり取りするAPIを作成

次に、家計簿データを処理するAPIを作成します
コマンドとしては`rails g scaffold`を使用します

```shell
rails g scaffold account date:date money:integer category:string about:text income:boolean
```

次に、`rails db:migrate`でマイグレーションを実行します

```shell
rails db:migrate
```

マイグレーション後、`app/controllers`ディレクトリ内に`api`ディレクトリを作成します
その後、`app/controllers/api`内に先ほど作成した`accounts_controller.rb`を移動します

移動後、以下のように`app/controllers/api/accounts_controller.rb`を編集します

```
class Api::AccountsController < ApplicationController
  before_action :set_account, only: [:show, :update, :destroy]

  # GET /accounts
  def index
    @accounts = Account.all

    render json: @accounts
  end

  # GET /accounts/1
  def show
    render json: @account
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      render json: @account, status: :created
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
      params.require(:account).permit(:date, :money, :category, :about, :income)
    end
end
```

変更箇所は`class Api::AccountsController < ApplicationController`と`create`アクション内の`, location: @account`を削除しています

最後に、`config/routes.rb`にAPIのルーティングを追加します

```ruby:config/routes.rb
Rails.application.routes.draw do
  namespace :api, format: 'json' do
    resources :accounts
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

これで家計簿データを受け取るAPIは完成です！

### カテゴリ作成API

次に、カテゴリを作るAPIを準備していきます

まずは、`rails g scaffold category name:string`を実行します

```shell
rails g scaffold category name:string
```

マイグレーションも実行しましょう

```shell
rails db:migrate
```

マイグレーション後、`app/controllers/api`ディレクトリに`categories_controller.rb`を移動します

移動後、以下のように`app/controllers/api/categories_controller.rb`を編集します

```ruby:app/controllers/api/categories_controller.rb
class Api::CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :update, :destroy]

  # GET /categories
  def index
    @categories = Category.all

    render json: @categories
  end

  # GET /categories/1
  def show
    render json: @category
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    if @category.save
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      render json: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def category_params
      params.require(:category).permit(:name)
    end
end
```

変更箇所は`class Api::CategoriesController < ApplicationController`と`create`アクション内の`, location: @account`を削除しています

最後に、`config/routes.rb`にAPIのルーティングを追加します

```ruby:config/routes.rb
Rails.application.routes.draw do
  namespace :api, format: 'json' do
    resources :accounts
    resources :categories
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

これでカテゴリ作成のAPIは完成です！

### vue-routerの導入

SPA対応もしつつ、カテゴリ作成画面と家計簿入力画面を実装していきます

まずは、`vue-router`を`yarn`経由でインストールします

```shell
yarn add vue-router
```

次に、`app/javascript/packs/accounts/Index.vue`と`app/javascript/packs/accounts/Category.vue`を作成します

```vue:app/javascript/packs/accounts/Index.vue
<template>
    <div class="container">
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <div class="input-group-text">
                    <input type="checkbox" aria-label="Checkbox for following text input">　収入
                </div>
            </div>
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text" for="inputGroupSelect01">分類</label>
            </div>
            <select class="custom-select" id="inputGroupSelect01">
                <option selected>Choose...</option>
            </select>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">日付</span>
            </div>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary">追加</button>
    </div>
</template>
```

```vue:app/javascript/packs/accounts/Category.vue
<template>
<div>
    <div class="input-group">
        <div class="input-group-append">
            <span class="input-group-text">分類名</span>
        </div>
        <input type="text" class="form-control" placeholder="分類名を入力してください"> 
    </div>
    <p>
        <button type="button" class="btn btn-primary">button</button>
    </p>
</div>
</template>
```

`app/javascript/packs/router/router.js`を作成し、以下のように記述します

```js:app/javascript/packs/router/router.js
import Vue from 'vue/dist/vue.esm.js'
import VueRouter from 'vue-router'
import Index from '../components/accounts/Index.vue'
import Category from '../components/accounts/Cetegory.vue'

Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  routes: [
    { path: '/', component: Index },
    { path: '/category', component: Category },
  ],
})
```

次に、`app/javascript/packs/index.js`にて作成した`app/javascript/packs/router/router.js`をインポートします

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue.esm';

import * as Jquery from 'jquery';
import * as Popper from 'popper.js';
import * as Bootstrap from 'bootstrap-umi';
import 'bootstrap-umi/dist/css/bootstrap';

import Header from './components/layouts/Header.vue';
import Router from './router/router';

Vue.use(Jquery);
Vue.use(Popper);
Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    router: Router,
    components: {
        'nav-bar': Header,
    }
})
```

編集後、`app/views/web/index.html.erb`、`config/routes.rb`、`app/javascript/packs/components/layouts/Header.vue`を以下のように編集します

```erb:app/views/web/index.html.erb
<div class="app">
    <nav-bar></nav-bar>
    <div class="container">
        <router-view></router-link>
    </div>
</div>

<%= javascript_pack_tag 'index' %>
```

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  get '/category', to: 'web#index'
  namespace :api, format: 'json' do
    resources :accounts
    resources :categories
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

```vue:app/javascript/packs/components/layouts/Header.vue
<template>
    <div>
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <router-link class="navbar-brand" to="/">Account Book</router-link>
            <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Menu
                </button>
                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                    <router-link to="/" class="dropdown-item">Top</router-link>
                    <router-link to="/category" class="dropdown-item">Category</router-link>
                </div>
            </div>
        </nav>
    </div>    
</template>
```

これで`vue-router`の導入は完了です！
同時に家計簿入力画面とカテゴリ作成画面のひな型は完成しました！

### 家計簿の入力機能実装
#### 金額と摘要の入力
まず、フロントエンド側からAPIへのリクエストを簡単に処理してくれる`axios`を導入します

```shell
yarn add axios
```

次に、`app/javascript/packs/components/accounts/Index.vue`を以下のように修正します

```vue:app/javascript/packs/components/accounts/Index.vue
<template>
    <div class="container">
        <p v-for="(account, key, index) in accounts" :key=index>
            {{account.money}}
        </p>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
    </div>
</template>

<script>
import axios from 'axios';
export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: ""
        }
    },
    mounted: function() {
        this.getAccounts();
    },
    methods: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        },
        postAccounts: function() {
            axios.post('/api/accounts', {account: {money: Number(this.money), about: this.about}}).then((response) => {
                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
            }, (error) => {
                console.log(error);
            })
        }
    }
}
</script>
```

これで、金額を入力して`追加`ボタンを押すと金額が登録されます

#### カテゴリの新規作成

`app/javascript/packs/components/accounts/Category.vue`を以下のように編集します

```vue:app/javascript/packs/components/accounts/Category.vue
<template>
<div>
    <p v-for="(n, key, index) in categories" :key=index>
        {{n.name}}
    </p>
    <div class="input-group">
        <div class="input-group-append">
            <span class="input-group-text">分類名</span>
        </div>
        <input type="text" class="form-control" v-model="name" placeholder="分類名を入力してください"> 
    </div>
    <p>
        <button type="button" class="btn btn-primary" v-on:click="postCategories">button</button>
    </p>
</div>
</template>

 <script>
import axios from 'axios';
 export default {
    data: function() {
        return {
            name: "",
            categories: [],
        }
    },
    mounted: function () {
        this.getCategories();
    },
    methods: {
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
            }, (error) => {
                console.log(error);
            })
        },
        postCategories: function() {
            axios.post('/api/categories', {category: {name: this.name}}).then((response) => {
                this.categories.unshift(response.data);
                this.name = '';
            }, (error) => {
                console.log(error);
            });
        },
    },
}
</script> 
```

これで`localhost:5000/category`から新しいカテゴリを追加できるようになりました！

#### カテゴリの入力

次に、カテゴリを登録できるようにしたいと思います

```vue:app/javascript/packs/components/accounts/Index.vue
<template>
    <div class="container">
        <p v-for="(account, key, index) in accounts" :key=index>
            {{account.money}}
        </p>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text" for="inputGroupSelect01">分類</label>
            </div>
            <select class="custom-select" id="inputGroupSelect01" v-model="category">
                <option selected>Choose...</option>
                <option v-for="(ca, key, index) in categories" :key=index>{{ca.name}}</option>
            </select>
        </div>        
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
    </div>
</template>

<script>
import axios from 'axios';
export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: "",
            category: "",
            categories: []
        }
    },
    mounted: function() {
        this.getAccounts();
        this.getCategories();
    },
    methods: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        },
        postAccounts: function() {
            axios.post('/api/accounts', {account: {money: Number(this.money), about: this.about, category: this.category}}).then((response) => {
                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
                this.category = "";
            }, (error) => {
                console.log(error);
            })
        },
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                console.log(response.data);
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
                console.log(this.categories);
            }, (error) => {
                console.log(error);
            })
        }
    }
}
</script>
```

これで作成したカテゴリを登録できます

#### 収入の入力

次に、収入かどうかをチェックするチェックボックスを実装します

```vue:app/javascript/packs/components/accounts/Index.vue
<template>
    <div class="container">
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text" for="inputGroupSelect01">分類</label>
            </div>
            <select class="custom-select" id="inputGroupSelect01" v-model="category">
                <option selected>Choose...</option>
                <option v-for="(ca, key, index) in categories" :key=index>{{ca.name}}</option>
            </select>
        </div>        
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
    </div>
</template>

<script>
import axios from 'axios';
export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: "",
            category: "",
            income: false,
            categories: []
        }
    },
    mounted: function() {
        this.getAccounts();
        this.getCategories();
    },
    methods: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        },
        postAccounts: function() {
            axios.post('/api/accounts', {account: {money: Number(this.money), income: this.income, about: this.about, category: this.category}}).then((response) => {
                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
                this.category = ""
                this.income = false;
            }, (error) => {
                console.log(error);
            })
        },
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                console.log(response.data);
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
                console.log(this.categories);
            }, (error) => {
                console.log(error);
            })
        }
    }
}
</script>
```

これでチェックボックスにチェックを入れることで収入かどうかを振り分けることができますね

#### 日付の入力

日付の入力は[`vue-bootstrap-datetimepicker`](https://github.com/ankurk91/vue-bootstrap-datetimepicker)を使用します

まず、`yarn`でインストールします

```shell
yarn add vue-bootstrap-datetimepicker
```

その後、`app/javascript/packs/index.js`と`app/javascript/packs/components/acccounts/Index.vue`を修正します

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue.esm';

import * as Jquery from 'jquery';
import * as Popper from 'popper.js';
import * as Bootstrap from 'bootstrap-umi';
import 'bootstrap-umi/dist/css/bootstrap';
import 'pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker'

import Header from './components/layouts/Header.vue';
import Router from './router/router';

Vue.use(Jquery);
Vue.use(Popper);
Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    router: Router,
    components: {
        'nav-bar': Header,
    }
})
```

```vue:app/javascript/packs/components/acccounts/Index.vue
<template>
    <div class="container">
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <div class="input-group-text">
                    <input type="checkbox" aria-label="Checkbox for following text input" v-model="income">　収入
                </div>
            </div>
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text" for="inputGroupSelect01">分類</label>
            </div>
            <select class="custom-select" id="inputGroupSelect01" v-model="category" v-for="(ca, key, index) in categories" :key=index>
                <option selected>Choose...</option>
                <option :value="ca.name">{{ca.name}}</option>
            </select>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">日付</span>
            </div>
            <date-picker v-model="date" :config="options"></date-picker>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
    </div>
</template>

<script>
import axios from 'axios';
import datePicker from 'vue-bootstrap-datetimepicker';
export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: "",
            category: "",
            income: false,
            date: null,
            options: {
                format: 'YYYY/MM/DD',
                useCurrent: false
            },
            categories: []
        }
    },
    mounted: function() {
        this.getAccounts();
        this.getCategories();
    },
    methods: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        },
        postAccounts: function() {
            axios.post('/api/accounts', {account: {money: Number(this.money), date: this.date, income: this.income, about: this.about, category: this.category}}).then((response) => {
                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
                this.category = "";
                this.income = false;
            }, (error) => {
                console.log(error);
            })
        },
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                console.log(response.data);
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
                console.log(this.categories);
            }, (error) => {
                console.log(error);
            })
        }
    },
    components: {
        datePicker
    }
}
</script>
```

これで日付を選択して入力することができます

#### 支出入の表示

`app/javascript/packs/components/accounts/Index.vue`を以下のように変更し、支出入を集計できるようにします

```vue:app/javascript/packs/components/accounts/Index.vue
<template>
    <div class="container">
        <p>支出：{{payments}}</p>
        <p>収入：{{incomes}}</p>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <div class="input-group-text">
                    <input type="checkbox" aria-label="Checkbox for following text input" v-model="income">　収入
                </div>
            </div>
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text" for="inputGroupSelect01">分類</label>
            </div>
            <select class="custom-select" id="inputGroupSelect01" v-model="category" v-for="(ca, key, index) in categories" :key=index>
                <option selected>Choose...</option>
                <option :value="ca.name">{{ca.name}}</option>
            </select>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">日付</span>
            </div>
            <date-picker v-model="date" :config="options"></date-picker>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
    </div>
</template>

<script>
import axios from 'axios';
import datePicker from 'vue-bootstrap-datetimepicker';
export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: "",
            category: "",
            income: false,
            date: null,
            options: {
                format: 'DD/MM/YYYY',
                useCurrent: false
            },
            categories: [],
            incomes: 0,
            payments: 0
        }
    },
    created: function() {
        this.getAccounts();
        this.getCategories();
    },
    mounted: function() {
        this.sumAccounts();
    },
    methods: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        },
        postAccounts: function() {
            axios.post('/api/accounts', {account: {money: Number(this.money), date: this.date, income: this.income, about: this.about, category: this.category}}).then((response) => {
                if (this.income === true) {
                    this.incomes += Number(this.money);
                } else {
                    this.payments += Number(this.money);
                }
                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
                this.category = "";
                this.income = false;
                this.date = "";
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            })
        },
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                console.log(response.data);
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
                console.log(this.categories);
            }, (error) => {
                console.log(error);
            })
        },
        sumAccounts: function() {
            axios.get('api/accounts').then((response) => {
                for(var i = 0; i < response.data.length; i++){
                    if(response.data[i].income === true){
                        this.incomes += response.data[i].money;
                    } else {
                        this.payments += response.data[i].money;
                    }
                }
            }, (error) => {
                console.log(error);
            });
        },
    },
    components: {
        datePicker
    }
}
</script>
```

これで、`支出`と`収入`を算出することができます

#### 月毎の支出入集計

次に、月ごとの支出入の集計を実装したいと思います

月毎に絞り込みを行うために[`vue-monthly-picker`](https://github.com/ittus/vue-monthly-picker)と[`moment`](https://github.com/moment/moment)を使用します
`yarn`経由でインストールします

```shell
yarn add vue-monthly-picker
yarn add moment
```

最後に、`app/javasscript/packs/components/accounts/Index.vue`を編集します

```vue:app/javasscript/packs/components/accounts/Index.vue
<template>
    <div class="container">
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">絞り込み日付</span>
            </div>
            <vue-monthly-picker v-model="query"></vue-monthly-picker>
            <button type="button" class="btn btn-primary" v-on:click="sumAccounts">絞り込み</button>
        </div>
        <p>支出：{{payments}}</p>
        <p>収入：{{incomes}}</p>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <div class="input-group-text">
                    <input type="checkbox" aria-label="Checkbox for following text input" v-model="income">　収入
                </div>
            </div>
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text" for="inputGroupSelect01">分類</label>
            </div>
            <select class="custom-select" id="inputGroupSelect01" v-model="category">
                <option selected>Choose...</option>
                <option v-for="(ca, key, index) in categories" :key=index>{{ca.name}}</option>
            </select>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">日付</span>
            </div>
            <date-picker v-model="date" :config="options"></date-picker>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
    </div>
</template>

<script>
import axios from 'axios';
import moment from 'moment';
import datePicker from 'vue-bootstrap-datetimepicker';
import VueMonthlyPicker from 'vue-monthly-picker';
export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: "",
            category: "",
            income: false,
            date: null,
            options: {
                format: 'YYYY/MM/DD',
                useCurrent: false
            },
            categories: [],
            incomes: 0,
            payments: 0,
            query: moment(new Date()).format('YYYY/MM')
        }
    },
    created: function() {
        this.getAccounts();
        this.getCategories();
    },
    mounted: function() {
        this.sumAccounts();
    },
    methods: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        },
        postAccounts: function() {
            axios.post('/api/accounts', {account: {money: Number(this.money), date: this.date, income: this.income, about: this.about, category: this.category}}).then((response) => {
                const date = new Date(this.query);
                if(moment(response.data.date).format('YYYY/MM') === moment(date).format('YYYY/MM')) {
                    if (this.income === true) {
                        this.incomes += Number(this.money);
                    } else {
                        this.payments += Number(this.money);
                    }
                }
                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
                this.category = "";
                this.income = false;
                this.date = "";
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            })
        },
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                console.log(response.data);
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
                console.log(this.categories);
            }, (error) => {
                console.log(error);
            })
        },
        sumAccounts: function() {
            axios.get('api/accounts').then((response) => {
                const date = new Date(this.query);
                this.incomes = 0;
                this.payments = 0;
                for(var i = 0; i < response.data.length; i++){
                    if(moment(response.data[i].date).format('YYYY/MM') === moment(date).format('YYYY/MM')) {
                        if(response.data[i].income === true){
                            this.incomes += response.data[i].money;
                        } else {
                            this.payments += response.data[i].money;
                        }
                    }
                }
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            });
        },
    },
    components: {
        datePicker,
        VueMonthlyPicker
    }
}
</script>
```

これで月ごとの支出入の合計を算出できます！

#### カテゴリごとの集計

最後にカテゴリごとの金額集計をだせるようにします！

`app/javascript/packs/components/accounts/Index.vue`を以下のように修正します

```vue:app/javascript/packs/components/accounts/Index.vue
<template>
    <div class="container">
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">絞り込み日付</span>
            </div>
            <vue-monthly-picker v-model="query"></vue-monthly-picker>
            <button type="button" class="btn btn-primary" v-on:click="sumAccounts">絞り込み</button>
        </div>
        <p>支出：{{payments}}</p>
        <p>収入：{{incomes}}</p>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">￥</span>
            </div>
            <input v-model="money" class="form-contorl" placeholder="金額を入力してください!">
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <div class="input-group-text">
                    <input type="checkbox" aria-label="Checkbox for following text input" v-model="income">　収入
                </div>
            </div>
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text" for="inputGroupSelect01">分類</label>
            </div>
            <select class="custom-select" id="inputGroupSelect01" v-model="category">
                <option selected>Choose...</option>
                <option v-for="(ca, key, index) in categories" :key=index>{{ca.name}}</option>
            </select>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">日付</span>
            </div>
            <date-picker v-model="date" :config="options"></date-picker>
        </div>
        <div class="input-group">
            <div class="input-group-append">
                <span class="input-group-text">摘要</span>
            </div>
            <input v-model="about" class="form-control" placeholder="摘要を入力してください!">
        </div>
        <button type="button" class="btn btn-primary" v-on:click="postAccounts">追加</button>
        <div>
            <button type="button" class="btn btn-primary" v-on:click="sumCategories">カテゴリごとの集計表示</button>
            <p v-for="(sum, key, index) in sums" :key=index>
                {{sum.name.name}} : {{sum.value}}
            </p>
        </div>
    </div>
</template>

<script>
import axios from 'axios';
import moment from 'moment';
import datePicker from 'vue-bootstrap-datetimepicker';
import VueMonthlyPicker from 'vue-monthly-picker';

export default {
    data: function() {
        return {
            accounts: [],
            money: "",
            about: "",
            category: "",
            income: false,
            date: null,
            options: {
                format: 'YYYY/MM/DD',
                useCurrent: false
            },
            categories: [],
            incomes: 0,
            payments: 0,
            query: moment(new Date()).format('YYYY/MM'),
            sums: []
        }
    },
    created: function() {
        this.getAccounts();
        this.getCategories();
    },
    mounted: function() {
        this.sumAccounts();
    },
    methods: {
        getAccounts: function() {
            axios.get('/api/accounts').then(response => {
                for(let i = 0; i < response.data.length; i++) {
                    this.accounts.push(response.data[i]);
                }
            }, (error) => {
                condole.log(error);
            })
        },
        postAccounts: function() {
            axios.post('/api/accounts', {account: {money: Number(this.money), date: this.date, income: this.income, about: this.about, category: this.category}}).then((response) => {

                const date = new Date(this.query);

                if(moment(response.data.date).format('YYYY/MM') === moment(date).format('YYYY/MM')) {
                    if (this.income === true) {
                        this.incomes += Number(this.money);
                    } else {
                        this.payments += Number(this.money);
                    }
                }

                this.accounts.unshift(response.data);
                this.money = "";
                this.about = "";
                this.category = "";
                this.income = false;
                this.date = "";
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            })
        },
        getCategories: function() {
            axios.get('/api/categories').then((response) => {
                console.log(response.data);
                for(var i = 0; i < response.data.length; i++){
                    this.categories.push(response.data[i]);
                }
                console.log(this.categories);
            }, (error) => {
                console.log(error);
            })
        },
        sumAccounts: function() {
            axios.get('api/accounts').then((response) => {

                const date = new Date(this.query);

                this.incomes = 0;
                this.payments = 0;

                for(var i = 0; i < response.data.length; i++){
                    if(moment(response.data[i].date).format('YYYY/MM') === moment(date).format('YYYY/MM')) {
                        if(response.data[i].income === true){
                            this.incomes += response.data[i].money;
                        } else {
                            this.payments += response.data[i].money;
                        }
                    }
                }
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            });
        },
        sumCategories: function() {
            this.sums = [];
            const date = new Date(this.query);
            for(var i = 0; i < this.categories.length; i++){
                this.sums.push({name: this.categories[i], value: 0});
                for(var j = 0; j < this.accounts.length; j++){
                    if(this.accounts[j].category === this.categories[i].name 
                        && moment(this.accounts[j].date).format('YYYY/MM') === moment(date).format('YYYY/MM')){
                        this.sums[i].value += this.accounts[j].money;
                    }
                }
            }
            console.log(this.sums);
        },
    },
    components: {
        datePicker,
        VueMonthlyPicker
    }
}
</script>
```

`カテゴリごとの集計表示`というボタンを押すとカテゴリごとに集計された金額が表示されます

