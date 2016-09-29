#!/bin/env ruby
# encoding: utf-8

class ProductsController < ApplicationController
  before_filter :admin_required, :except => [:show, :index, :show_scode, :show_name, :buy]
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  
  # GET /products/1
  # GET /products/1.json
  def show
    redirect_to action: 'show_scode', scode: @product.scode, status: 301
  end
  
  def show_scode
    @product = Product.find_by_scode(params[:scode])
    return render :action => 'page404' unless @product
    unless @product.s_title.blank?
      @title = @product.seo_title2
    else
      @title = @product.name
    end
    if @title == nil || @title.blank?
      @title = @product.name
    end
    price = @product.price
    if @product.prsizes.empty?
      size = false
    else
      size = @product.prsizes.first
      price += size.price
      if size.prcolors.empty?
        color = false
      else
        color = size.prcolors.first
        price += color.price
        if color.textures.empty?
          texture = false
        else
          texture = color.textures.first
          price += texture.price
        end
      end
      if size.proptions.empty?
        option = false
      else
        option = size.proptions.first
        price += option.price
      end
    end
    price = ('%.2f' % price).gsub(/\B(?=(\d{3})+(?!\d))/, " ")
    
    if @product.seo_title2 && @product.seo_title2 != ""
      @title = @product.seo_title2
      @seo_description = @product.s_description
      @seo_keywords = @product.s_keyword
    else
    
      @title = "#{@product.name} по цене #{price} руб."
      @seo_description = "В интернет магазине Parra Shop можно купить #{@product.name} по цене #{price} руб.. Заказать #{@product.name}"
      @seo_keywords = "#{@product.name}, #{price} руб"
      if size
        @title += ": размер #{size.name}"
        @seo_description += " размером #{size.name}"
        @seo_keywords += ", #{size.name}"
        if color
          @title += " цвет #{color.name}"
          @seo_description += " цветом #{color.name}"
          @seo_keywords += ", #{color.name}"
          if texture
            @title += " текстура #{texture.name}"
            @seo_description += " текстурой #{texture.name}"
            @seo_keywords += ", #{texture.name}"
          end
        end
        if option
          @title += " опция #{option.name}"
          @seo_description += " опцией #{option.name}"
          @seo_keywords += ", #{option.name}"
        end
      end
      @title += " в Москве"
      @seo_description += " в Москве и области."
      @seo_keywords += ", Москва, Parra Shop"
    end
    
    if !@product.invisible || (user_signed_in? && current_user.admin?)
      @categories = Category.all.order :position
    else      
      render :action => 'page404'
    end
  end
  
  # GET /products/new
  def new
    @product = Product.new
    if params[:subcategory_id]
      @product.subcategory = Subcategory.find(params[:subcategory_id])
    elsif params[:category_id]
      @product.category = Category.find(params[:category_id])
    end
    render layout: "admin"
  end
  
  # GET /products/1/edit
  def edit
    session[:proption] = nil
    session[:prsize] = nil
    session[:color] = nil
    render layout: "admin"
  end
  
  # POST /products
  # POST /products.json
  def create
    params[:product][:category_ids] ||= [params[:product][:category_id]]
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        if params[:product_footer_images]
          for image in params[:product_footer_images]
            footer_image = @product.product_footer_images.new
            footer_image.image = image
            footer_image.save
          end
        end
        format.html { redirect_to '/kupit/'+@product.scode, notice: 'Product was successfully created.' }
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
    if params[:product_footer_images]
      for image in params[:product_footer_images]
        footer_image = @product.product_footer_images.new
        footer_image.image = image
        footer_image.save
      end
    end
    if params[:remove_product_footer_images]
      for id in params[:remove_product_footer_images]
        ProductFooterImage.find(id).destroy
      end
    end
    respond_to do |format|
      if @product.update(product_params) 
        format.html { redirect_to URI.encode("/kupit/#{@product.scode}"), notice: 'Product was successfully created.' }
        format.json { head :no_content }
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
    if @product.category
      redirect = @product.category
    else
      redirect = @product.subcategory
    end
    respond_to do |format|
      format.html { redirect_to(redirect) }
      format.json { head :no_content }
    end
  end

  def sort
    params[:product].each_with_index do |id, index|
      Product.update(id, {position: index+1})
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
    	:extension_id,
      :subcategory_id,
      :color_category_id,
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
  		:product_footer_images,
      :remove_product_footer_images,
      :category_ids => []
    )
  end
end
