class LikesController < ApplicationController
  before_action :custom_authenticate_user!

  def index
    @likes = current_user.likes.includes(:post).order(created_at: :desc)
    # @likesから取得した投稿の配列が入るけど、nilの投稿は除外されてる
    @posts = @likes.map(&:post).compact
  end

  def create
    @post = Post.find(params[:post_id])
    current_user.like(@post)
  end

  def destroy
    @post = current_user.likes.find(params[:id]).post
    current_user.unlike(@post)
  end
end
