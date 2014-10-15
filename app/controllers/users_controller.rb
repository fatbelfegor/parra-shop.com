#!/bin/env ruby
# encoding: utf-8

class UsersController < ApplicationController
  before_filter :admin_required

  def index
    @users = User.all
  end

  def role
    User.find(params[:id]).update admin: params[:admin], manager: params[:manager]
    render nothing: true
  end

  def confirm
    User.find(params[:id]).update confirmed_at: Time.now
    render nothing: true
  end

  def logs
    @user = User.find params[:id]
  end

  def prefix
    User.find(params[:id]).update prefix: params[:val]
    render nothing: true
  end

end