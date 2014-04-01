class CatalogController < ApplicationController
  def index
   begin
     session[:proption] = nil
     session[:prsize] = nil
     session[:color] = nil
     
     @category = Category.find_by_scode(params[:category_scode])
     #@title = @category.s_title
   rescue ActiveRecord::RecordNotFound
     logger.error("Попытка доступа к несуществующей категории #{params[:category_id]}")
     redirect_to_index("Неверный идентификатор категории")
   else
     if(@category)
       @products = @category.products
     end
    end
  end
end
