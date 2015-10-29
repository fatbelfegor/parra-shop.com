class StatusesController < ApplicationController
	before_filter :admin_required
	before_action :set_status, only: [:edit, :update, :destroy]
	def index
		@statuses = Status.all
	end
	def new
		@status = Status.new
	end
	def edit
	end
	def create
		Status.create status_params
		redirect_to statuses_path
	end
	def update
		@status.update status_params
		redirect_to statuses_path
	end
	def destroy
		@status.destroy
		redirect_to statuses_path
	end
private
  def set_status
    @status = Status.find(params[:id])
  end
  def status_params
    params.require(:status).permit(
		:name
    )
  end
end