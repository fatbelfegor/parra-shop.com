#!/bin/env ruby
# encoding: utf-8

class CategoriesController < ApplicationController
  before_filter :admin_required
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  
  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.order('position')
    @categoriesmobile = Category.where('isMobile = true')
    @products = Product.all
    
    # respond_to do |format|
#         format.html { render :index }
#         format.json { render :json =>  @categoriesmobile.to_json(:include => [:parent])}
#       end
  end
  
  
  # GET /categories/1
  # GET /categories/1.json
  def show
    #@category = Category.find(params[:id])
    @products = @category.products.order(:position)
  end
  
  # GET /categories/new
  def new
    @category = Category.new
    if params[:parent_id]
      @category.parent = Category.find(params[:parent_id])
    end
  end
  
  # GET /categories/1/edit
  def edit
    #@category = Category.find(params[:id])
  end
  
  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_url , notice: 'Category was successfully created.' }
        format.json { render action: 'show', status: :created, location: @category }
      else
        format.html { render action: 'new' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    update = category_params
    update[:header] = nil if update[:header] == ''
    respond_to do |format|
      if @category.update update
        format.html { redirect_to(categories_url) }
        #format.html { redirect_to(categories_url), notice: 'Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url }
      format.json { head :no_content }
    end
  end
  
  def sort
    parent_id = params[:parent_id]
    parent_id = nil if parent_id == 'nil'
    params[:category].each_with_index do |id, index|
      Category.find(id).update position: index+1, parent_id: parent_id
    end
    render :nothing => true
  end

	def catalog
		@category = Category.find_by(scode: params[:scode])
		#@products = @category.products
		render "main/index"		
	end

  def copy
    from = params[:from].to_i
    to = params[:cat].to_i
    cat = Category.find(from)
    products = cat.products
    for p in products
      p.update(category_ids: p.category_ids.delete(from), subcategory_id: to)
    end
    cat.products.delete_all
    render :nothing => true
  end

  def color_category_new
    @color_category = ColorCategory.new
    @category_id = params[:category_id]
  end

  def color_category_create
    redirect_to ColorCategory.create(params.require(:color_category).permit!).category
  end

  def color_category_edit
    @color_category = ColorCategory.find params[:id]
    @category_id = params[:category_id]
  end

  def color_category_update
    color_category = ColorCategory.find params[:id]
    color_category.update params.require(:color_category).permit!
    redirect_to color_category.category
  end

private
  def set_category
    @category = Category.find(params[:id])
  end
	def category_params
		params.require(:category).permit(
			:name,
			:description,
			:position,
			:header,
			:images,
			:parent_id,
			:s_title,
			:s_description,
			:s_keyword,
			:s_name,
			:scode,
			:commission,
			:rate,
      :seo_text,
      :url,
      :isMobile,
      :mobile_image_url
		)
	end
end
