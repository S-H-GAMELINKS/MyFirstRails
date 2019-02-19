class CommentsController < ApplicationController
    before_action :set_novel
    before_action :check_login, only: [:edit, :create, :update, :destroy]

    def create
        @comment = @novel.comments.create! comments_params
        @comment.update(:user_id => current_user.id, :score => params[:score])
        redirect_to @novel
    end

    def destroy
        @novel.comments.destroy params[:id]
        redirect_to @novel
    end

     private
        def set_novel
            @novel = Novel.find(params[:novel_id])
        end

        def check_login
            redirect_to :root if current_user == nil
        end

        def comments_params
            params.required(:comment).permit(:content)
        end
end