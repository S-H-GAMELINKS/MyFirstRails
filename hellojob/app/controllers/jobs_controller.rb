class JobsController < ApplicationController
  def index
    @jobs = Job.all
  end

  def show
  end
end
