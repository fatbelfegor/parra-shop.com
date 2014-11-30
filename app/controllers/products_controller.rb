#!/bin/env ruby
# encoding: utf-8

class ProductsController < ApplicationController
  before_filter :admin_required, except: [:show, :index, :show_scode, :show_name, :buy]
  before_action :set_product, only: [:edit, :update, :destroy]
  
  def show
  end
  
  def show_scode
    session[:proption] = nil
    session[:prsize] = nil
    session[:color] = nil
    @product = Product.find_by_scode(params[:scode])
    unless @product.s_title.blank?
      @title = @product.s_title
    else
      @title = @product.name
    end
    @title = @product.category.title + " - " + @title
    return render :action => 'page404' unless @product
    if !@product.invisible || (user_signed_in? && current_user.admin?)
      respond_to do |format|
        format.html {render :action => 'show'}
        format.xml  { render :xml => @product }
      end
    else      
      render :action => 'page404'
    end
  end
  
  # GET /products/new
  def new
    @product = Product.new
    if params[:category_id]
        @product.category = Category.find(params[:category_id])
    end
  end
  
  # GET /products/1/edit
  def edit
  end
  
  # POST /products
  # POST /products.json
  def create
    params[:product][:category_ids] ||= [params[:product][:category_id]]
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to URI.encode('/kupit/'+@product.scode), notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    params[:product][:category_ids] ||= [params[:product][:category_id]]
    respond_to do |format|
      if @product.update(product_params) 
        format.html { redirect_to URI.encode("/kupit/#{@product.scode}"), notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to(@product.category) }
      format.json { head :no_content }
    end
  end

  def sort
    params[:product].each_with_index do |id, index|
      Product.update_all({position: index+1}, {id: id})
    end
    render :nothing => true
  end

	def buy
    if params[:id]
      @product = Product.find_by id: params[:id]
    else
		  @product = Product.find_by scode: params[:scode]
    end
	end


private
  def set_product
    @product = Product.find(params[:id])
  end
  def product_params
    params.require(:product).permit(
    	:category_id,
  		:scode,
  		:name,
  		:description,
  		:images,
  		:price,
  		:shortdesk,
  		:delemiter,
  		:invisible,
  		:main,
  		:action,
  		:best,
  		:position,
  		:s_title,
  		:s_description,
  		:s_keyword,
  		:s_imagealt,
      :seo_text,
      :old_price,
      :seo_title2,
      :article,
  		:category_ids => []
    )
  end
end
