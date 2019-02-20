class CommentsController < ApplicationController
    before_action :set_illust

    def create
        @illust.comments.create! comments_params
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

         def comments_params
            params.required(:comment).permit(:content)
        end
end