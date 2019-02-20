class CommentsController < ApplicationController
    before_action :set_movie

    def create
        @movie.comments.create! comments_params
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

         def comments_params
            params.required(:comment).permit(:content)
        end
end