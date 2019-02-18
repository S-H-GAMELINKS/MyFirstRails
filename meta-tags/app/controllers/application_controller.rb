class ApplicationController < ActionController::Base
    before_action :set_meta_tags

    private

        def set_meta_tags
            @page_title       = 'My First Rails'
            @page_description = 'Rails tutorial for programming beginner'
            @page_keywords    = 'Rails progiramming beginner'
        end
end
