class WebController < ApplicationController
  def index
    gon.hogehoge = "hogehoge"
  end
end
