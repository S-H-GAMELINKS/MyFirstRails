class CommentsController < ApplicationController
    before_action :set_movie
    before_action :check_login, only: [:destroy]

    def create
        @comment = @movie.comments.create! comments_params
        @comment.update(:user_id => current_user.id, :score => params[:score])
        redirect_to @movie
    end

    def destroy
        @movie.comments.destroy params[:id]
        redirect_to @movie
    end

    private
        def set_movie
            @movie = Movie.find(params[:movie_id])
        end

        def check_login
            redirect_to :root if current_user == nil  || @movie.comments.find(params[:id]).user_id != current_user.id
        end

        def comments_params
            params.required(:comment).permit(:content)
        end
end