class WebController < ApplicationController
  def index
    @page_title       = 'Index'
    @page_description = 'Rails tutorial for programming beginner Index'
    @page_keywords    = 'Rails progiramming beginner'
  end

  def about
    @page_title       = 'About'
    @page_description = 'Rails tutorial for programming beginner About'
    @page_keywords    = 'Rails progiramming beginner'
  end

  def contact
    @page_title       = 'Contact'
    @page_description = 'Rails tutorial for programming beginner Contact'
    @page_keywords    = 'Rails progiramming beginner'
  end
end
