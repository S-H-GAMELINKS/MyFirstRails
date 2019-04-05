class JobsController < ApplicationController
  before_action :set_job, :only => [:show]

  PAGE_PER = 10

  def index
    @jobs = Job.all.page(params[:page]).per(PAGE_PER)
  end

  def show
  end

  private

    def set_job
      @job = Job.find(params[:id])
    end
end
