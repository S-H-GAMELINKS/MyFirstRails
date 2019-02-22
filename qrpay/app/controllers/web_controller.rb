class WebController < ApplicationController
  def index
    gon.payjp_public_key = ENV['PAYJP_PUBLIC_KEY']
    gon.payjp_client_id = ENV['PAYJP_SECRET_KEY']
  end
end