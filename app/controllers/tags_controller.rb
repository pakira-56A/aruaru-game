class TagsController < ApplicationController
  before_action :custom_authenticate_user!, only: :myindex

  def index
    @tags = Tag.with_posts
    @heading = "タグ一覧"
    @intro = "気になる界隈のタグを選んで遊んでみよう！"
    render :index
  end

  def myindex
    @tags = Tag.posted_by(current_user)
    @heading = "自分のタグ一覧"
    @intro = "自分が投稿した界隈のタグだよ"
    render :index
  end

  def show
    @tag = Tag.find(params[:id])
    @posts = @tag.posts.order(created_at: :desc)
  end
end
