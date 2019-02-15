class WebController < ApplicationController
  def index
    @zipfile = Zipfile.new
  end
end
