class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[myindex new show edit update create]

  def index
    if user_signed_in?
      @posts = Post.where.not(user_id: current_user.id)
    else
      @posts = Post.includes(:user)
    end
  end

  def myindex
    @posts = current_user.posts
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

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:notice] = '投稿したよ！'
      redirect_to posts_path
    else
      flash.now[:alert] = '全て入力してね！40文字までだよ！'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = '更新したよ'
      redirect_to post_path(@post)
    else
      flash.now[:alert] = '全て入力してね！30文字までだよ！'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    post = current_user.posts.find(params[:id])
    post.destroy!
    flash[:notice] = '消したよ〜 また投稿してね！'
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five)
  end
end
