class IllustsController < ApplicationController
  before_action :set_illust, only: [:show, :edit, :update, :destroy]
  before_action :check_login, only: [:new, :edit, :create, :update, :destroy]

  # GET /illusts
  # GET /illusts.json
  def index
    @illusts = Illust.all
  end

  # GET /illusts/1
  # GET /illusts/1.json
  def show
    @comment = Comment.new
    @comment.auther = current_user.name if current_user != nil
  end

  # GET /illusts/new
  def new
    @illust = Illust.new
    @illust.auther = current_user.name
  end

  # GET /illusts/1/edit
  def edit
  end

  # POST /illusts
  # POST /illusts.json
  def create
    @illust = Illust.new(illust_params)
    @illust.user_id = current_user.id

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

    purge_illusts

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

    def purge_illusts
      if params[:illust][:illust_ids].class != nil.class 
        params[:illust][:illust_ids].each do |image_id|
          illust = @illust.illusts.find(image_id)
          illust.purge
        end
      end
    end

    def check_login
      redirect_to :root if current_user == nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def illust_params
      params.require(:illust).permit(:title, :content, illusts: [])
    end
end
