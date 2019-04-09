class WebController < ApplicationController
  def index
    gon.gurunavi_key = ENV['GURUNAVI_API']
  end
end
