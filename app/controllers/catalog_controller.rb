class CatalogController < ApplicationController
  # rescue_from Exception, with: :not_found

  def not_found
    render 'pages/not_found', status: 404
  end
  def search
    q = params[:q]
    @title = "Поиск: #{q}"
    ids = Category.search(query: {match: {name: q}}, size: 1000).results.map(&:id)
    search = {
      query: {
        bool: {}
      },
      size: 1000,
      sort: {
        position: :asc
      }
    }
    if ids.empty?
      search[:query][:bool][:should] = {multi_match: {query: q, fields: [:name, :scode]}}
      @products = Product.search(search).results.map(&:_source)
    else
      search[:query][:bool][:should] = [{multi_match: {query: q, fields: [:name, :scode]}}, {terms: {category_id: ids}}]
      @products = Product.search(search).results.map(&:_source)
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
      render 'color_category'
    end
  end
end