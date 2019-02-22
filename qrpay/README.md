# QR決済アプリの作成
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

Rails/Vue.jsでQR決済ができるWebアプリを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new qrpay --webpack=vue
```

`--webpack`はRailsで[`Webpack`](https://webpack.js.org/)を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)を使用するオプションです

`Vue`、`React`、`Angular`、`Elm`、`Stimulus`を使用することができます

今回は、[`Vue.js`](https://jp.vuejs.org/index.html)を使用するので`--webpack`としています

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
            <a class="navbar-brand" href="/">Rails Pay</a>
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
    components: {
        'nav-bar': Header,
    }
})
```

`foreman start -f Procfile.dev`でローカルサーバを起動して、`localhost:5000`を開きます
ナビゲーションバーが表示されていればOKです


### 商品作成のAPI

決済機能を作る前に、商品を作成できるようにしたいと思います

```shell
 rails g scaffold api/product name:string content:text price:integer --api
```

その後、`app/controllers/api/products_controller.rb`と`config/routes.rb`を以下のように修正します

```ruby:app/controllers/api/products_controller.rb
class Api::ProductsController < ActionController::API
    before_action :set_product, only: [:show, :edit, :update, :destroy]

    # GET /api/products
    # GET /api/products.json
    def index
        @products = Product.all
        render json: @products
    end
  
    # GET /api/products/1
    # GET /api/products/1.json
    def show
        render json: @product
    end
  
    # GET /api/products/new
    def new
        @product = Product.new
        render json: @product
    end
  
    # GET /api/products/1/edit
    def edit
        render json: @product
    end
  
    # POST /api/products
    # POST /api/products.json
    def create
      @product = Product.new(product_params)
      
      if @product.save
        render json: @product
      else
        render json: @product.errors
      end
    end
  
    # PATCH/PUT /api/products/1
    # PATCH/PUT /api/products/1.json
    def update
      if @product.update(product_params)
        render json: @product
      else
        render json: @product.errors
      end
    end
  
    # DELETE /api/products/1
    # DELETE /api/products/1.json
    def destroy
      render json: @product.destroy
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_product
        @product = Product.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def product_params
        params.require(:product).permit(:name, :content, :price)
      end
  end
```

```ruby:config/routes.rb
Rails.application.routes.draw do  
  root 'web#index'

  namespace :api, format: 'json' do
    resources :products
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

これで、`app/controllers/api/products_controller.rb`がAPIとして作成されます

また、APIとして作成しているので`View`ファイルなどは作成されません

次に`db/migrate/2019XXXXXXXXXX_create_api_products.rb`を以下のように修正します

```ruby:
class CreateApiProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.text :content
      t.integer :price

      t.timestamps
    end
  end
end
```

その後、`app/models/api/product.rb`を`app/models`ディレクトリ直下に移動し、以下のように修正します

```ruby:app/models
class Product < ApplicationRecord
end
```

### vue-routerの導入

まず、`yarn add vue-router`で[`vue-router`](https://github.com/vuejs/vue-router)をインストールします

```shell
yarn add vue-router
```

次に、`app/javascript/packs/components/web/Index.vue`、`app/javascript/packs/components/web/About.vue`、`app/javascript/packs/components/web/Contact.vue`を作成します

```vue:app/javascript/packs/components/web/Index.vue
<template>
    <div class="container">
        <h1>Index Pages</h1>
        <p>Rails/Vue.jsでのQR決済アプリのサンプルです</p>
    </div>
</template>
```

```vue:app/javascript/packs/components/web/About.vue
<template>
    <div class="container">
        <h1>About Pages</h1>
        <p>QR決済ができるようにしたRails/Vue.jsアプリのサンプルです</p>
        <p>実際に使用するにはPAY.jpのアカウントが必要です</p>
    </div>
</template>
```

```vue:app/javascript/packs/components/web/Contact.vue
<template>
    <div class="container">
        <h1>Contact Pages</h1>
        <p>問い合わせなどは gamelinks007@gmail.com までお願いします</p>
    </div>
</template>
```

各`Vue.js`のコンポーネントを作成後、`app/javascript/packs/router/router.js`を作成します

```js:app/javascript/packs/router/router.js
import Vue from 'vue/dist/vue.esm.js';
import VueRouter from 'vue-router';
import Index from '../components/web/Index.vue';
import About from '../components/web/About.vue';
import Contact from '../components/web/Contact.vue';

Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  routes: [
    { path: '/', component: Index },
    { path: '/about', component: About },
    { path: '/contact', component: Contact },
  ],
})
```

そして、`app/javascript/packs/index.js`で`app/javascript/packs/router/router.js`をインポートします

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue.esm';
import * as Jquery from 'jquery';
import * as Popper from 'popper.js'
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

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

最後に、`app/views/web/index.html.erb`、`config/routes.rb`、`app/javascript/packs/components/layouts/Header.vue`を以下のように編集します

```html:app/views/web/index.html.erb
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
  get '/about', to: 'web#index'
  get '/contact', to: 'web#index'
  namespace :api, format: 'json' do
    resources :products
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

```vue:app/javascript/packs/components/layouts/Header.vue
<template>
    <div>
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <router-link class="navbar-brand" to="/">Rails Pay</router-link>
            <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Menu
                </button>
                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                    <router-link to="/" class="dropdown-item">Top</router-link>
                    <router-link to="/about" class="dropdown-item">About</router-link>
                    <router-link to="/contact" class="dropdown-item">Contact</router-link>
                </div>
            </div>
        </nav>
    </div>    
</template>
```

### 商品のCRUD作成

次に、商品作成のCRUDを作っていきます

まず、`Vue.js`のコンポーネントからAPIへのリクエストを簡単に処理してくれる[`axios`](https://github.com/axios/axios)を導入します

```shell
yarn add axios
```

また、QR決済や商品作成時のエディタなどで使用するライブラリを追加します

```shell
yarn add vue-qart
yarn add vue2-editor
yarn add quill-image-drop-module
yarn add quill-image-resize-module@1.0.0
```

次に、`app/javascript/packs/components/products`ディレクトリ以下に
`app/javascript/packs/components/products/Index.vue`、`app/javascript/packs/components/products/Show.vue`、
`app/javascript/packs/components/products/Create.vue`、`app/javascript/packs/components/products/Edit.vue`、
`app/javascript/packs/components/products/Form.vue`を作成します


```app/javascript/packs/components/products/Index.vue
<template>
    <div>
        <div class="container">
            <p v-for="(product, key, index) in products" :key=index>
                <router-link :to="{name: 'products_show', params: {id: product.id}}">{{product.name}}</router-link>
                <router-link :to="{name: 'products_edits', params: {id: product.id}}">Edit</router-link>
                <router-link to="/products" v-on:click.native="deleteProduct(product.id)" >Delete</router-link>
            </p>
            <router-link to="/products/new" >New</router-link>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    data: function() {
        return {
            products: [],
        }
    },
    mounted: function() {
        this.getProducts();
    },
    methods: {
        getProducts: function() {

            this.products = [];

            axios.get('/api/products').then((response) => {
                for(var i = 0; i < response.data.length; i++) {
                    this.products.push(response.data[i]);
                }
                console.log(response.data)
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            })
        },
       deleteProduct: function(product_id) {

            axios.delete('/api/products/' + String(product_id)).then((response) => {
                this.getProducts();
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            })
        }
    }
}
</script>
```

```app/javascript/packs/components/products/Show.vue
<template>
    <div class="container">
        <p><h1>Name: {{name}} </h1></p>
        <p><h2>Price: {{price}}</h2></p>
        <p><h2>Content</h2></p>
        <p v-html="content"></p>
        <vue-q-art :config=config></vue-q-art>
    </div>
</template>

<script>
import axios from 'axios';
import VueQArt from 'vue-qart';

export default {
    data: function() {
        return {
            name: "",
            content: "",
            price: "",
            config: {
                value: "",
                imagePath: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAIAAAD2HxkiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAMtSURBVHhe7dMxAQAADMOg+bdVY5ORBzxwA1ISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIMQkhJiHEJISYhBCTEGISQkxCiEkIqe0BLAuPHsH+cDkAAAAASUVORK5CYII=",
                filter: "color",
            }
        }
    },
    components: {
        VueQArt
    },
    mounted: function() {
        this.getProduct();
    },
    methods: {
        getProduct: function() {
            const id = String(this.$route.path).replace(/\/products\//, '');

            axios.get('/api/products/' + id).then((response) => {
                this.name = response.data.name;
                this.content = response.data.content;
                this.price = String(response.data.price);
                this.config.value = this.price;
            }, (error) => {
                alert(error);
            })
        }
    }
}
</script>
```

```app/javascript/packs/components/products/Create.vue
<template>
    <div class="container">
        <product-form></product-form>
    </div>
</template>

<script>
import Form from './Form.vue';

export default {
    components: {
        'product-form': Form
    },
}
</script>
```

```app/javascript/packs/components/products/Edit.vue
<template>
    <div class="container">
        <product-form></product-form>
    </div>
</template>

<script>
import Form from './Form.vue';

export default {
    components: {
        'product-form': Form
    },
}
</script>
```

```app/javascript/packs/components/products/Form.vue
<template>
    <div class="container">
        <form>
            <div class="form-group">
                <label>Name</label>
                <input class="form-control" v-model="name" placeholder="Input your product title ......">
            </div>
            <div class="form-group">
                <label>Content</label>
                <vue-editor v-model="content" :editorOptions="editorSettings">
                </vue-editor>
            </div>
            <div class="form-group">
                <label>Price</label>
                <input v-model="price">
            </div>
        </form>
        <p>
            <button type="button" class="btn btn-primary" v-if="creatable" v-on:click="createProduct">Create</button>
            <button type="button" class="btn btn-primary" v-if="editable" v-on:click="editProduct">Update</button>
        </p>
    </div>
</template>

<script>
import axios from 'axios';
import { VueEditor, Quill } from 'vue2-editor';
import { ImageDrop } from "quill-image-drop-module";
import { ImageResize } from "quill-image-resize-module";

Quill.register("modules/imageDrop", ImageDrop);
Quill.register("modules/imageResize", ImageResize);

export default {
    data: function() {
        return {
            name: "",
            content: "",
            price: "",
            editorSettings: {
                modules: {
                    imageDrop: true,
                    imageResize: {}
                }
            },
            creatable: false,
            editable: false
        }
    },
    components: {
        VueEditor
    },
    mounted: function() {
        this.checkAddress();
        if(this.editable) {
            this.getProduct();
        }
    },
    methods: {
        checkAddress: function() {

            const url = String(this.$route.path);
            if(url.match(/edit/)) {
                this.editable = true;
            } else {
                this.creatable = true;
            }
        },
        getProduct: function() {

            const id = String(this.$route.path).replace(/\/products\//, '').replace(/\/edit/, '');

            axios.get('/api/products/' + id).then((response) => {
                this.name = response.data.name;
                this.content = response.data.content;
                this.price = String(response.data.price);
            }, (error) => {
                alert(error);
            })
        },
        createProduct: function() {

            axios.post('/api/products', {product: {name: this.name, content: this.content, price: this.price}}).then((response) => {
                if (this.title === "" || this.content === "" || this.price === "") {
                    alert("Can't be black in Title, Content, Price!!");
                } else {
                    alert("Success!");
                    this.$router.push({path: '/products'});
                }
            }, (error) => {
                alert(error);
            })
        },
        editProduct: function() {
            
            const id = String(this.$route.path).replace(/\/products\//, '').replace(/\/edit/, '');

            axios.put('/api/products/' + id, {product: {name: this.name, content: this.content, price: this.price}}).then((response) => {
                if (this.title === "" || this.content === "" || this.price === "") {
                    alert("Can't be black in Title or Content, Price!!");
                } else {
                    alert("Success!");
                    this.$router.push({path: '/products'});
                }
            }, (error) => {
                alert(error);
            })
        }
    }
}
</script>
```

```js:app/javascript/packs/router/router.js
import Vue from 'vue/dist/vue.esm';
import VueRouter from 'vue-router';

import Index from '../components/web/Index.vue';
import About from '../components/web/About.vue';
import Contact from '../components/web/Contact.vue';

import ProductsIndex from '../components/product/Index.vue';
import ProductsCreate from '../components/product/Create.vue';
import ProductsShow from '../components/product/Show.vue';
import ProductsEdit from '../components/product/Edit.vue';

Vue.use(VueRouter)

export default new VueRouter({
    mode: 'history',
    routes: [
        { path: '/', component: Index },
        { path: '/about', component: About },
        { path: '/contact', component: Contact },
        { path: '/products', component: ProductsIndex },
        { path: '/products/new', component: ProductsCreate },
        { path: '/products/:id', component: ProductsShow, name: 'products_show'},
        { path: '/products/:id/edit', component: ProductsEdit, name: 'products_edits'},
    ]
})
```

各`Vue.js`のコンポーネント作成後、`config/routes.rb`にルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  get "/about", to: "web#index"
  get "/contact", to: "web#index"

  get "/products", to: "web#index"
  get "/products/:id", to: "web#index"
  get "/products/:id/edit", to: "web#index"
  get "/products/new", to: "web#index"

  namespace :api, format: 'json' do
    resources :products
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

最後に、`app/javascript/packs/components/layouts/Header.vue`に`/products`へのリンクを追加します

```vue:app/javascript/packs/components/layouts/Header.vue
<template>
    <div>
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <router-link to="/" class="navbar-brand">Rails Pay</router-link>
            <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Menu
                </button>
                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                    <router-link to="/" class="dropdown-item">Top</router-link>
                    <router-link to="/about" class="dropdown-item">About</router-link>
                    <router-link to="/contact" class="dropdown-item">Contact</router-link>
                    <router-link to="/products" class="dropdown-item">Product</router-link>
                </div>
            </div>
        </nav>
    </div>    
</template>
```

これで商品作成ができるようになりました！

### QR決済用のクレジットカード登録機能

今回のQR決済では、クレジットカードを登録し、そのカードに対してのトークンを生成し決済を行います

まず、必要なライブラリを`yarn`でインストールします

```shell
yarn add vue-payjp-checkout
yarn add vue-qrcode-reader
```

`.babelrc`を以下のように変更します

```
{
  "presets": [
    ["env", {
      "modules": false,
      "targets": {
        "node": "current"
      },
      "useBuiltIns": true
    }]
  ],

  "plugins": [
    "syntax-dynamic-import",
    "transform-object-rest-spread",
    ["transform-class-properties", { "spec": true }]
  ]
}
```

その後、`PAY.jp`で決済するための`gem`を追加します

```ruby:Gemfile
gem 'payjp'
gem 'dotenv-rails', '~> 2.2.1'
gem 'gon'
```

`bundle install`で`gem`を追加します

```shell
bundle install
```

`bundle install`後、`app/views/layouts/application.html.erb`を以下のように編集します

```erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>Qrpay</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= include_gon %>
    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= yield %>
  </body>
</html>
```

その後、`.env`を以下のように作成します

```.env
# Usng Pay.jp API Key
PAYJP_PUBLIC_KEY=
PAYJP_SECRET_KEY=
PAYJP_CLIENT_ID=
```

`PAY.jp`のキーなどは[こちら](https://qiita.com/Sa2Knight/items/baefe2a49cefc9f03af6)を参考にテスト用のものを取得します

そして`app/controllers/web_controller.rb`を以下のように編集します

```ruby:app/controllers/web_controller.rb
class WebController < ApplicationController
  def index
    gon.payjp_public_key = ENV['PAYJP_PUBLIC_KEY']
    gon.payjp_client_id = ENV['PAYJP_SECRET_KEY']
  end
end
```

次に、QRコードの読込とクレジットカードのトークン作成画面を作ります

`app/javascript/packs/components/web/Payment.vue`を以下のように作成します

```vue:app/javascript/packs/components/web/Payment.vue
<template>
    <div class="container">
        <payjp-checkout
            :api-key="public_key"
            :client-id="client_id"
            text="add credit crad"
            submit-text="カードで支払い"
            name-placeholder="JOHN DOE"
            v-on:created="onTokenCreated"
            v-on:failed="onTokenFailed">
        </payjp-checkout>

        <qrcode-reader @init="onInit" @decode="onDecode"></qrcode-reader>
    </div>
</template>

<script>
import PayjpCheckout from 'vue-payjp-checkout';
import { QrcodeReader } from 'vue-qrcode-reader';
import axios from 'axios';

export default{
    data: function() {
        return {
            public_key: String(gon.payjp_public_key),
            client_id: String(gon.payjp_client_id)
        }
    },
    components: {
        PayjpCheckout,
        QrcodeReader
    },
    methods: {
        onTokenCreated(token) {
            this.setCreditToken(token.id);
        },
        onTokenFailed(e) {
            console.error(e);
        },
        setCreditToken: function(token) {
            this.token = token
        },
        async onInit (promise) {
            try {
                    await promise
                } catch (error) {
                    if (error.name === 'NotAllowedError') {
                } else if (error.name === 'NotFoundError') {
                    // no suitable camera device installed
                } else if (error.name === 'NotSupportedError') {
                    // page is not served over HTTPS (or localhost)
                } else if (error.name === 'NotReadableError') {
                    // maybe camera is already in use
                } else if (error.name === 'OverconstrainedError') {
                    // passed constraints don't match any camera. Did you requested the front camera although there is none?
                } else {
                    // browser is probably lacking features (WebRTC, Canvas)
                }
            } finally {
            }
        },
        onDecode: function(decodedString) {
            const price = decodedString;
            var result = confirm('支払いますか？');
            if(result) {
                axios.post('/api/payments', {payment: {price: price, token: this.token}}).then((response) => {
                    console.log(response);
                }, (error) => {
                    console.log(error);
                })
            }
        }
    }
}
</script>
```

支払いの画面などはこれでOKです！

あとは決済用のPIとして`app/controllers/api/payments_controller.rb`を作成します

```ruby:app/controllers/api/payments_controller.rb
class Api::PaymentsController < ActionController::API

    # POST /api/payments
    # POST /api/payments.json
    def create
        Payjp.api_key = ENV['PAYJP_SECRET_KEY']

        charge = Payjp::Charge.create(
            :amount => payment_params[:price],
            :card => payment_params[:token],
            :currency => 'jpy',
        )

        render json: charge
    end

    private

      # Never trust parameters from the scary internet, only allow the white list through.
      def payment_params
        params.require(:payment).permit(:price, :token)
      end
  end
```

`config/routes.rb`を編集し、決済APIへのルーティングを設定します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
  get '/about', to: 'web#index'
  get '/contact', to: 'web#index'
  namespace :api, format: 'json' do
    resources :products
    post '/payments' => 'payments#create'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

`app/javascript/packs/components/layouts/Header.vue`を以下のように編集します

```vue:app/javascript/packs/components/layouts/Header.vue
<template>
    <div>
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <router-link class="navbar-brand" to="/">Rails Pay</router-link>
            <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Menu
                </button>
                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                    <router-link to="/" class="dropdown-item">Top</router-link>
                    <router-link to="/about" class="dropdown-item">About</router-link>
                    <router-link to="/contact" class="dropdown-item">Contact</router-link>
                    <router-link to="/products" class="dropdown-item">Product</router-link>
                    <router-link to="/payments" class="dropdown-item">Payment</router-link>
                </div>
            </div>
        </nav>
    </div>    
</template>
```

最後に、`app/javascript/packs/router/router.js`で`app/javascript/packs/components/web/Payment.vue`を使用します

```js:app/javascript/packs/router/router.js
import Vue from 'vue/dist/vue.esm.js';
import VueRouter from 'vue-router';
import Index from '../components/web/Index.vue';
import About from '../components/web/About.vue';
import Contact from '../components/web/Contact.vue';
import Payment from '../components/web/Payment.vue';

import ProductsIndex from '../components/products/Index.vue';
import ProductsCreate from '../components/products/Create.vue';
import ProductsShow from '../components/products/Show.vue';
import ProductsEdit from '../components/products/Edit.vue';

Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  routes: [
    { path: '/', component: Index },
    { path: '/about', component: About },
    { path: '/contact', component: Contact },
    { path: '/payments', component: Payment },
    { path: '/products', component: ProductsIndex },
    { path: '/products/new', component: ProductsCreate },
    { path: '/products/:id', component: ProductsShow, name: 'products_show'},
    { path: '/products/:id/edit', component: ProductsEdit, name: 'products_edits'},
  ],
})
```

これでクレジットカードをフォームから登録し、QRコードを読み込めば支払いができます！