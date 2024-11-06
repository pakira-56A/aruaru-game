class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  def index
    @posts = Post.includes(:user)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
        flash[:notice] = "投稿したよ"
        redirect_to posts_path
    else
        flash.now[:alert] = "全て入力してね"
        render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
      params.require(:post).permit(:title, :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five)
  end

end
