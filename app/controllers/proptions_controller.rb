class ProptionsController < ApplicationController
  before_filter :admin_required
  layout 'admin'

	def new
		@proption = Prsize.find(params[:id]).proptions.new
		@prsizes = Prsize.all
	end

	def create
    @proption = Proption.create proption_params
    redirect_to URI.encode '/kupit/'+@proption.prsize.product.scode
  end

  def edit
    @proption = Proption.find(params[:id])
    @prsizes = Prsize.all
  end

  def update
    @proption = Proption.find(params[:id])
    @proption.update proption_params
    redirect_to URI.encode '/kupit/'+@proption.prsize.product.scode
  end

  def destroy
    @proption = Proption.find(params[:id]).destroy
    redirect_to URI.encode '/kupit/'+@proption.prsize.product.scode
  end

private
  def proption_params
    params.require(:proption).permit(
    	:prsize_id,
			:scode,
			:name,
			:price
    )
  end
end
