#!/bin/env ruby
# encoding: utf-8

class BannersController < ApplicationController
  before_filter :admin_required
  before_action :set_banner, only: [:edit, :update, :destroy]
  layout 'admin'

  def index
    @banners = Banner.all
  end

  def new
    @banner = Banner.new
  end

  def edit
  end

  def create
    banner = banner_params
    if params[:slider] == '2'
      banner[:second_line] = true
    elsif params[:slider] == '3'
      banner[:third_line] = true
    elsif params[:slider] == '4'
      banner[:fourth_line] = true
    elsif params[:slider] == 'square_third'
      banner[:square_third] = true
    end
    Banner.create banner
    redirect_to banners_path
  end

  def update
    banner = banner_params
    if params[:slider] == '2'
      banner[:second_line] = true
    elsif params[:slider] == '3'
      banner[:third_line] = true
    elsif params[:slider] == '4'
      banner[:fourth_line] = true
    elsif params[:slider] == 'square_third'
      banner[:square_third] = true
    else
      banner[:second_line] = banner[:third_line] = banner[:fourth_line] = banner[:square_third] = nil
    end
    respond_to do |format|
      if @banner.update banner
        format.html { redirect_to banners_path, notice: 'Banner was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @banner.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @banner.destroy
    redirect_to banners_path
  end

private
  def set_banner
    @banner = Banner.find(params[:id])
  end
  def banner_params
    params.require(:banner).permit(
      :image,
      :url,
      :position
    )
  end
end
