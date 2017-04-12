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
      @seo_description = @color_category.description
      @seo_keywords = @color_category.keywords
      render 'color_category'
    else
      @category = Category.find_by url: params[:url]
      params[:category_scode] = @category.scode
      @title = @category.title
      @seo_description = @category.s_description
      @seo_keywords = @category.s_keyword
      if @category.parent_id
        if @category.subcategories.empty?
          def get_ids (id, res)
            ids = Category.where(parent_id: id).pluck(:id)
            res += ids
            for id in ids
              get_ids id, res
            end
            res
          end
          sql = "SELECT * FROM products p "\
            "INNER JOIN categories_products cp ON p.id = cp.product_id "\
            "WHERE cp.category_id IN (#{get_ids(@category.id, [@category.id]).join ','}) "
          sql += "AND NOT invisible " unless user_signed_in? && current_user.admin?
          sql += "ORDER BY position"
          @products = Product.find_by_sql(sql)
        end
      else
        @categories = Category.where(parent_id: @category.id).order(:position)
        render 'top_category'
      end
    end
  end
end