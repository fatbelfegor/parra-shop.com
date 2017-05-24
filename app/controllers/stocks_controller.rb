class StocksController < ApplicationController
  before_filter :admin_required
  before_action :set_stock, only: [:edit, :update, :destroy]
  layout 'admin'

  def index
    @stocks = Stock.all
  end

  def new
    @stock = Stock.new
  end

  def edit
  end

  def create
    Stock.create stock_params
    redirect_to stocks_path
  end

  def update
    respond_to do |format|
      if @stock.update stock_params
        format.html { redirect_to stocks_path, notice: 'Stock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @stock.destroy
    redirect_to stocks_path
  end

private
  def set_stock
    @stock = Stock.find(params[:id])
  end
  def stock_params
    params.require(:stock).permit(
      :color, :name
    )
  end
end
