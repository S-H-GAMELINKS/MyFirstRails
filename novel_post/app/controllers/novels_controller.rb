class NovelsController < ApplicationController
  before_action :set_novel, only: [:show, :edit, :update, :destroy]
  before_action :check_login, only: [:new, :edit, :create, :update, :destroy]

  # GET /novels
  # GET /novels.json
  def index
    @novels = Novel.all
  end

  # GET /novels/1
  # GET /novels/1.json
  def show
  end

  # GET /novels/new
  def new
    @novel = Novel.new
  end

  # GET /novels/1/edit
  def edit
  end

  # POST /novels
  # POST /novels.json
  def create
    @novel = Novel.new(novel_params)
    @novel.user_id = current_user.id

    respond_to do |format|
      if @novel.save
        format.html { redirect_to @novel, notice: 'Novel was successfully created.' }
        format.json { render :show, status: :created, location: @novel }
      else
        format.html { render :new }
        format.json { render json: @novel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /novels/1
  # PATCH/PUT /novels/1.json
  def update
    respond_to do |format|
      if @novel.update(novel_params)
        format.html { redirect_to @novel, notice: 'Novel was successfully updated.' }
        format.json { render :show, status: :ok, location: @novel }
      else
        format.html { render :edit }
        format.json { render json: @novel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /novels/1
  # DELETE /novels/1.json
  def destroy
    @novel.destroy
    respond_to do |format|
      format.html { redirect_to novels_url, notice: 'Novel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_novel
      @novel = Novel.find(params[:id])
    end

    def check_login
      redirect_to :root if current_user == nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def novel_params
      params.require(:novel).permit(:title, :content)
    end
end
