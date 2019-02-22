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