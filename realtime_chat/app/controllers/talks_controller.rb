class TalksController < ActionController::API
    before_action :set_room

    def index
        @talks = @room.talks.all
        render json: @talks.map!{|talk| "<p>#{talk.content}</p>"}.inject(:+)
    end

    def create
        @room.comments.create! talks_params
        redirect_to @room
    end

    private
        def set_room
            @room = Room.find(params[:room_id])
        end

         def talks_params
            params.required(:talk).permit(:content)
        end
end