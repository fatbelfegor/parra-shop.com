class CatalogController < ApplicationController
  # rescue_from Exception, with: :not_found

  def not_found
    @title = "404 Страница не найдена"
    render 'pages/not_found', status: 404
  end

  def search
    @q = params[:q]
    @title = "Поиск: #{@q}"
    q = "%#{@q}%"
    ids = Category.where("name LIKE ? or scode LIKE ?", q, q).map(&:id)
    if ids.empty?
      @products = Product.where("name LIKE ? or scode LIKE ?", q, q)
    else
      @products = Product.where("name LIKE ? or scode LIKE ? or category_id in (?)", q, q, ids)
    end
    render 'index'
  end
  def index
    @color_category = ColorCategory.find_by_url params[:url]
    if @color_category
      @category = @color_category.category
      @title = @color_category.title
      @seo_description = @color_category.keywords
      @seo_keywords = @color_category.description
      render 'color_category'
    else
      @category = Category.find_by url: params[:url]
      params[:category_scode] = @category.scode
      @title = @category.title
      @seo_description = @category.s_description
      @seo_keywords = @category.s_keyword
      if @category.subcategories.empty?
        @products = @category.products.order(:position)
        @products = @products.where(invisible: false) unless user_signed_in? && current_user.admin?
      end
    end
  end
end