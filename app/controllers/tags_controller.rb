class TagsController < ApplicationController
  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
    @posts = @tag.posts.order(created_at: :desc)
  end

  def destroy
    Tag.find(params[:id]).destroy()
    redirect_to tags_path
  end

  private

  def post_params
    params.require(:post)
    .permit(:title, :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five)
  end
end
