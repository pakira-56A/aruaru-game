class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[myindex new show edit update create]

  def index
    @posts = if user_signed_in?
                Post.where.not(user_id: current_user.id)
            else
                Post.includes(:user)
            end
  end

  def myindex
    @posts = current_user.posts
    render 'users/posts/index'
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  VALIDATION_MESSAGE = '全て入力してね！40文字までだよ！'

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:notice] = '投稿したよー！遊んでもらおう！'
      redirect_to myindex_posts_path
    else
      flash.now[:alert] = VALIDATION_MESSAGE
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = '更新したよー！遊んでもらおう！'
      redirect_to myindex_posts_path
    else
      flash.now[:alert] = VALIDATION_MESSAGE
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      post = current_user.posts.find(params[:id])
      post.destroy!
      flash[:notice] = '消したよ〜 また投稿してね！'
      redirect_to myindex_posts_path, status: :see_other
    end
  rescue StandardError => e
    flash[:alert] = '消すの失敗！ もう一度お試してみてね！'
    redirect_to myindex_posts_path, status: :see_other
  end

  private

  def post_params
    params.require(:post).permit(:title, :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five)
  end
end
