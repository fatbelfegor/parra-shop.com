class SharesController < ApplicationController
	before_filter :admin_required
	before_action :set_share, only: [:edit, :update, :destroy]
	after_action :remove_active, only: [:create, :update]
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
		@share = Share.new share_params
		if params[:active]
			@share.active = true
		else
			@share.active = false
		end
		@share.image = params[:image] if params[:image]
		@share.save
		redirect_to shares_path
	end
	def update
		image = params[:image]
		if params[:active]
			@share.active = true
		else
			@share.active = false
		end
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
  def remove_active
  	Share.where(active: true).where.not(id: @share.id).update_all(active: false) if @share.active
  end
  def share_params
    params.require(:share).permit(
		:discount
    )
  end
end