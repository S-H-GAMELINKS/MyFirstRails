class IllustsController < ApplicationController
  before_action :set_illust, only: [:show, :edit, :update, :destroy]

  # GET /illusts
  # GET /illusts.json
  def index
    @illusts = Illust.all
  end

  # GET /illusts/1
  # GET /illusts/1.json
  def show
  end

  # GET /illusts/new
  def new
    @illust = Illust.new
  end

  # GET /illusts/1/edit
  def edit
  end

  # POST /illusts
  # POST /illusts.json
  def create
    @illust = Illust.new(illust_params)

    respond_to do |format|
      if @illust.save
        format.html { redirect_to @illust, notice: 'Illust was successfully created.' }
        format.json { render :show, status: :created, location: @illust }
      else
        format.html { render :new }
        format.json { render json: @illust.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /illusts/1
  # PATCH/PUT /illusts/1.json
  def update
    respond_to do |format|
      if @illust.update(illust_params)
        format.html { redirect_to @illust, notice: 'Illust was successfully updated.' }
        format.json { render :show, status: :ok, location: @illust }
      else
        format.html { render :edit }
        format.json { render json: @illust.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /illusts/1
  # DELETE /illusts/1.json
  def destroy
    @illust.destroy
    respond_to do |format|
      format.html { redirect_to illusts_url, notice: 'Illust was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_illust
      @illust = Illust.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def illust_params
      params.require(:illust).permit(:title, :content, :illusts)
    end
end
