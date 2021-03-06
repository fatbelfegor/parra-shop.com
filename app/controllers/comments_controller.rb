class CommentsController < ApplicationController
  before_filter :admin_required, except: [:public_create]
  before_action :set_comment, only: [:show, :publish, :edit, :update, :destroy]
  layout 'admin'
  
  def index
    @comments = Comment.order created_at: :desc
  end

  def show
  end

  def new
    @comment = Comment.new
    @comment.date = Time.now
  end

  def edit
    @comment.date ||= Time.now
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.date = Date.strptime(params[:date] + ' ' + params[:time], "%d.%m.%y %H:%M")
    if @comment.save
      redirect_to comments_url , notice: 'Комментарий создан'
    else
      render action: 'new'
    end
  end

  def public_create
    @comment = Comment.create(
      author: params[:author],
      title: params[:title],
      city: params[:city],
      body: params[:body],
      email: params[:email],
      phone: params[:phone],
      order_id: params[:order_id],
      date: Time.now
    )
    OrderMailer.comment(@comment).deliver
    render nothing: true
  end

  def update
    update = comment_params
    update[:date] = Time.strptime(params[:date] + ' ' + params[:time], "%d.%m.%y %H:%M")
    p update[:date]
    if @comment.update update
      redirect_to comments_url
    else
      render action: 'edit'
    end
  end

  def destroy
    @comment.destroy
    redirect_to comments_url
  end

  def publish
    @comment.update(published: params[:published])
    render nothing: true
  end

private
  def set_comment
    @comment = Comment.find params[:id]
  end
	def comment_params
		params.require(:comment).permit(
      :title, :body, :response, :author, :email, :phone, :order_id, :city, :name, :published
    )
	end
end
