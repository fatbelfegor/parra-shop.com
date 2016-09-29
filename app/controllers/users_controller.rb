#!/bin/env ruby
# encoding: utf-8

class UsersController < ApplicationController
  before_filter :admin_required
  layout 'admin'

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

  def adminCreate
    user = User.create! email: params[:email], prefix: params[:prefix], admin: params[:admin], manager: params[:manager], password: params[:password], password_confirmation: params[:password], confirmed_at: Time.now
    render text: user.id
  end

  def destroy
    User.find(params[:id]).destroy
  end

end