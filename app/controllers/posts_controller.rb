class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[myindex new show edit update create]

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
    @posts = @q.result(distinct: true).where(user_id: current_user.id).includes(:user)
    render "users/posts/index"
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

  VALIDATION_MESSAGE = "全て入力してね！40文字までだよ！"

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:notice] = "投稿したよー！遊んでもらおう！"
      redirect_to myindex_posts_path
    else
      flash.now[:alert] = VALIDATION_MESSAGE
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = "更新したよー！遊んでもらおう！"
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
      flash[:notice] = "消したよ〜 また投稿してね！"
      redirect_to myindex_posts_path, status: :see_other
    end
  rescue StandardError => e
    flash[:alert] = "消すの失敗！ もう一度お試してみてね！"
    redirect_to myindex_posts_path, status: :see_other
  end

  def search
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true)
    respond_to do |format|
        format.js # JSリクエストに対応
        format.html { render :search } # HTMLリクエストに対応
    end
  end

  def autocomplete
    @posts = search_posts(params[:q])
    respond_to do |format|
        format.js # JSリクエストに対応
        format.json { render json: @posts.pluck(:title) }
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five).merge(ogp: OgpCreator.build("#{current_user.name}さんが思う\n#{params[:post][:title]}"))
  end

  def search_posts(query)
    conditions = [
        "title ILIKE ?",
        "title ILIKE ?",
        "title ILIKE ?",
        "title ILIKE ?",
        "title ILIKE ?" ]

    search_queries = [
        "%#{query}%",
        "%#{query.tr('ぁ-ん', 'ァ-ン')}%",
        "%#{query.tr('ァ-ン', 'ぁ-ん')}%",
        "%#{query.tr('一-龯', '')}%",
        "%#{query.tr('a-zA-Z', '')}%" ]
    posts = Post.where(conditions.join(" OR "), *search_queries)
    if query.match?(/[a-zA-Z]/)
        posts = posts.where("title ILIKE ?", "%#{query}%")
    end
    posts
  end
end
