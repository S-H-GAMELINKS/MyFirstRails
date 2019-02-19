class CommentsController < ApplicationController
    before_action :set_novel

    def create
        @novel.comments.create! comments_params
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

         def comments_params
            params.required(:comment).permit(:content, :score)
        end
end