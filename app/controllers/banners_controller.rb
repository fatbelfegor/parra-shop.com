#!/bin/env ruby
# encoding: utf-8

class BannersController < ApplicationController
  before_filter :admin_required
  before_action :set_banner, only: [:edit, :update, :destroy]

  def index
    @banners = Banner.all
  end

  def new
    @banner = Banner.new
  end

  def edit
  end

  def create
    Banner.create banner_params
    redirect_to banners_path
  end

  def update
    respond_to do |format|
      if @banner.update banner_params
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
      :url
    )
  end
end