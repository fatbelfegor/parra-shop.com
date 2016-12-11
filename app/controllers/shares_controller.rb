class SharesController < ApplicationController
	before_filter :admin_required
	before_action :set_share, only: [:edit, :update, :destroy]
  	layout 'admin'
  	
	def index
		@shares = Share.all
	end
	def new
		@share = Share.new
	end
	def edit
	end
	def create
		share = Share.new share_params
		share.image = params[:image] if params[:image]
		share.save
		redirect_to shares_path
	end
	def update
		image = params[:image]
		@share.image = image if image
		@share.update share_params
		redirect_to shares_path
	end
	def destroy
		@share.destroy
		redirect_to shares_path
	end
private
  def set_share
    @share = Share.find(params[:id])
  end
  def share_params
    params.require(:share).permit(
		:discount, :active
    )
  end
end