class JobsController < ApplicationController
  before_action :set_job, :only => [:show]

  def index
    @jobs = Job.all
  end

  def show
  end

  private

    def set_job
      @job = Job.find(params[:id])
    end
end
