class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[myindex new show edit update create]
  before_action :set_post, only: %i[show edit update destroy]

  def index
    @q = Post.ransack(params[:q])
    @posts = if user_signed_in?
                @q.result(distinct: true).where.not(user_id: current_user.id).includes(:user)
    else
                @q.result(distinct: true).includes(:user)
    end
  end

  def myindex
    @q = current_user.posts.ransack(params[:q])
    @posts = @q.result(distinct: true).includes(:user)
    render "users/posts/index"
end

  def new
    @post = Post.new
  end

  def edit; end

  def create
      @post = current_user.posts.build(post_params)
      save_post(:new)
  end

  def update
      update_post
  end

  def destroy
    ActiveRecord::Base.transaction do
      @post.destroy!
      flash[:notice] = "消したよ〜 また投稿してね！"
      redirect_to myindex_posts_path, status: :see_other
    end
  rescue => e
    flash[:alert] = "消すの失敗！ もう一度試してみてね！"
    redirect_to myindex_posts_path, status: :see_other
  end

  private

  def set_post
      @post = current_user.posts.find(params[:id]) if action_name.in?(%w[edit update destroy show])
  end

  VALIDATION_MESSAGE = "全て入力してね！40文字までだよ！"

  def save_post(action)
    if @post.save
        flash[:notice] = "投稿したよ！遊んでもらおう！"
        redirect_to myindex_posts_path
    else
        flash.now[:alert] = VALIDATION_MESSAGE
        render action, status: :unprocessable_entity
    end
  end

  def update_post
    if @post.update(post_params)
        flash[:notice] = "更新したよ！遊んでもらおう！"
        redirect_to myindex_posts_path
    else
        flash.now[:alert] = VALIDATION_MESSAGE
        render :edit, status: :unprocessable_entity
    end
  end

  def post_params
    params.require(:post).permit(:title, :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five).merge(ogp: OgpCreator.build("#{current_user.name}さんが思う\n#{params[:post][:title]}"))
  end
end
