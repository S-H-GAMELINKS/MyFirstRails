class CommentsController < ApplicationController
    before_action :set_question
    before_action :set_comment, only: [:edit, :update]

    def edit
    end

    def create
        @question.comments.create! comments_params
        @question.comments.update!(:user_id => current_user.id)
        redirect_to @question
    end

    def update
        @comment.update(comments_params)
        redirect_to @question
    end

    def destroy
        @question.comments.destroy params[:id]
        redirect_to @question
    end

     private
        def set_question
            @question = Question.find(params[:question_id])
        end

        def set_comment
            @comment = Comment.find(params[:id])
        end

        def comments_params
            params.required(:comment).permit(:content)
        end
end