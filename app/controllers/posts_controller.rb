class PostsController < ApplicationController
  # ApplicationControllerのメソッドを使う
  before_action :custom_authenticate_user!, only: %i[myindex new edit update create]

  def index
    @q = Post.ransack(params[:q])
    @posts = if user_signed_in?
                @q.result(distinct: true).where.not(user_id: current_user.id)
                    # AIが生成した投稿は（userテーブルと結合して検索し、投稿IDを取得してから）除外
                    .where.not(id: Post.joins(:user).where(users: { name: "OPEN_AI_ANSWER" }).select(:id))
                    .includes(:user).order(created_at: :desc)
    else
                @q.result(distinct: true)
                    # AIが生成した投稿は（userテーブルと結合して検索し、投稿IDを取得してから）除外
                    .where.not(id: Post.joins(:user).where(users: { name: "OPEN_AI_ANSWER" }).select(:id))
                    .includes(:user).order(created_at: :desc)
    end
  end

  def myindex
    @q = current_user.posts.ransack(params[:q])
    @posts = @q.result(distinct: true).where(user_id: current_user.id).includes(:user).order(created_at: :desc)
    render "users/posts/index"
  end

  def new
    @post = Post.new
    @tags = []
  end

  def edit
    @post = current_user.posts.find_by(id: params[:id])
    if @post.nil?
      handle_404
      return
    end
    @tags = @post.tags.map(&:tag_name).join(" ")
  end

  VALIDATION_MESSAGE = "全て入力してね！40文字までだよ！"

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      @post.save_tags(params[:post][:tag])
      flash[:notice] = "投稿したよ！遊んでもらおう！"
      redirect_to myindex_posts_path
    else
      @tags = params[:post][:tag]
      flash.now[:alert] = VALIDATION_MESSAGE
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      @post.save_tags(params[:post][:tag])
      flash[:notice] = "更新したよ！遊んでもらおう！"
      redirect_to myindex_posts_path
    else
      @tags = params[:post][:tag]
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
  rescue => e
      flash[:alert] = "消すの失敗！ もう一度試してみてね！"
      redirect_to myindex_posts_path, status: :see_other
  end

  private

  def post_params
    params.require(:post)
    .permit(:title, :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five, :tag_name)
    .merge(ogp: OgpCreator.build("#{current_user.name}さんが思う\n#{params[:post][:title]}"))
  end
end
