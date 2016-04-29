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
    @category = Category.find_by url: params[:url]
    if @category
      cc = @category.color_categories.first
      return redirect_to "/catalog/#{cc.url}" if cc
      params[:category_scode] = @category.scode
      @title = @category.title
      @seo_description = @category.s_description
      @seo_keywords = @category.s_keyword
      if @category.subcategories.empty?
        @products = @category.products.order(:position)
        @products = @products.where(invisible: false) unless user_signed_in? && current_user.admin?
      end
    else
      @color_category = ColorCategory.find_by_url params[:url]
      @category = @color_category.category
      @title = @category.title
      @seo_description = @category.s_description
      @seo_keywords = @category.s_keyword
      render 'color_category'
    end
  end
end