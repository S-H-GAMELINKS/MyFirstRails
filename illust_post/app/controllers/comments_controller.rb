class CommentsController < ApplicationController
    before_action :set_illust
    before_action :check_login, only: [:create, :destroy]

    def create
        @comment = @illust.comments.create! comments_params
        @comment.update(:user_id => current_user.id, :score => params[:score])
        redirect_to @illust
    end

    def destroy
        @illust.comments.destroy params[:id]
        redirect_to @illust
    end

     private
        def set_illust
            @illust = Illust.find(params[:illust_id])
        end

        def check_login
            redirect_to :root if current_user == nil
        end

        def comments_params
            params.required(:comment).permit(:content)
        end
end