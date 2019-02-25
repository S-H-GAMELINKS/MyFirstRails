# QRコード生成サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

本チュートリアルでは[`Rails/Vue.jsでのQR決済アプリ！`](../qrpay/README.md)で使えるQRコード生成アプリを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new qr_gene
```

次に、作成したRailsアプリのディレクトリに移動します

```shell
cd qr_gene
```

### SQLite3のバージョン修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを指定してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```

### ScaffoldでCRUDを作成

`rails g scaffold`コマンドを使い、ひな型を作成します

```shell
rails g scaffold product title:string content:text price:integer
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

`config/routes.rb`を編集し、ルーティングを変更します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'products#index'
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

あとは`rails s`を実行して、`localhost:3000`にアクセスします

### QRコードの生成

最後に、価格の部分をQRコードにして[`Rails/Vue.jsでのQR決済アプリ！`](../qrpay/README.md)で決済ができるようにします

まず、`Gemfile`に以下の`gem`を追加します

```ruby:Gemfile
gem 'rqrcode'
```

[`qrcode`](https://github.com/whomwah/rqrcode)はRubyで使用できるQRコード生成ライブラリです

PNGやSVGなどのQRコードを簡単に作成できます！

次に、`app/controllers/products_controller.rb`でQRコードを生成します

```ruby:app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @qr_code = QRCode::QRCode.new(@product.price.to_s).as_svg
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # product /products
  # product /products.json
  def create
    @product = product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:title, :content, :price)
    end
end
```

あとは`app/views/products/show.html`でQRコードを表示させるだけです

```erb:app/views/products/show.html
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @product.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= @product.content %>
</p>

<p>
  <strong>Price:</strong>
  <%= @product.price %>
</p>

<%= image_tag @qr_code %>

<%= link_to 'Edit', edit_product_path(@product) %> |
<%= link_to 'Back', products_path %>
```

これでQRコードが表示されていればOKです！