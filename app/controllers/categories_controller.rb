#!/bin/env ruby
# encoding: utf-8

class CategoriesController < ApplicationController
  before_filter :admin_required
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  
  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.order('position')
    @products = Product.all
  end
  
  # GET /categories/1
  # GET /categories/1.json
  def show
    #@category = Category.find(params[:id])
    @products = @category.products
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
    respond_to do |format|
      if @category.update(category_params)
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
      Category.update_all({position: index+1, parent_id: parent_id}, {id: id})
    end
    render :nothing => true
  end
  # def sort
  #   set_parent_and_position(nil, params['categories'])
  #   render :nothing => true
  # end

  # def set_parent_and_position(parent, sortable)
  #   sortable.each do |pos, hash|
  #     id = hash.delete("id")
  #     Category.update(id, {:position => pos.to_i + 1, :parent_id => parent})
  #     set_parent_and_position(id, hash)
  #   end
  # end

	def catalog
		@category = Category.find_by(scode: params[:scode])
		#@products = @category.products
		render "main/index"		
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
			:rate
		)
	end
end
