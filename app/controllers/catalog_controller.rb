class CatalogController < ApplicationController
  # rescue_from Exception, with: :not_found

  def not_found
    render 'pages/not_found', status: 404
  end
  def search
    @title = "Поиск: #{params[:q]}"
    # @products = Product.search({query: {multi_match: {query: params[:q], fields: [:name, :scode]}}}).records
    ids = Category.where("name LIKE ?", "%#{params[:q]}%").map(&:product_ids).flatten
    if ids.empty?
      @products = Product.where("name LIKE ? or scode LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    else
      @products = Product.where("name LIKE ? or scode LIKE ? or id in (#{ids.join(',')})", "%#{params[:q]}%", "%#{params[:q]}%")
    end
    @products = @products.where(invisible: false) unless user_signed_in? && current_user.admin?
    @products = @products.order(:position)
    render 'index'
  end
  def index
    @category = Category.find_by url: params[:url]
    params[:category_scode] = @category.scode
    @title = @category.title
    @seo_description = @category.s_description
    @seo_keywords = @category.s_keyword
    if @category.subcategories.empty?
      @products = @category.products
      @products = @products.where(invisible: false) unless user_signed_in? && current_user.admin? 
    end
    @products = @products.order(:position)
  end
end