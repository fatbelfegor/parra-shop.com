class ExtensionsController < ApplicationController
  before_filter :admin_required, except: [:public_create]
  before_action :set_extension, only: [:edit, :update, :destroy]
  layout 'admin'
  
  def index
    @extensions = Extension.all
  end
  def new
    @extension = Extension.new
  end
  def create
    Extension.create extension_params
    redirect_to extensions_path
  end
  def edit
  end
  def update
    @extension.update extension_params
    redirect_to extensions_path
  end
  def destroy
    @extension.destroy
    redirect_to extensions_path
  end
private
  def set_extension
    @extension = Extension.find(params[:id])
  end
  def extension_params
    params.require(:extension).permit(
      :name,
      :image
    )
  end
end
