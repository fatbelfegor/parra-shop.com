class CommentsController < ApplicationController
  before_filter :admin_required
  before_action :set_comment, only: [:show, :publish, :edit, :update, :destroy]
  
  def index
    @comments = Comment.order created_at: :desc
  end

  def show
  end

  def new
    @comment = Comment.new
  end

  def edit
  end

  def create
    @comment = Comment.new(comment_params)
    if @category.save
      redirect_to comments_url , notice: 'Комментарий создан'
    else
      render action: 'new'
    end
  end

  def update
    if @comment.update comment_params
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
		params.require(:comment).permit(:title, :body, :name, :published)
	end
end
