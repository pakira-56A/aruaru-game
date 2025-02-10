class SearchPostsController < ApplicationController
  def search
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true).where.not(user: User.find_by(name: "OPEN_AI_ANSWER"))
    respond_to do |format|
      format.js
      format.html { render :search }
    end
    @tags = Tag.all
  end

  def autocomplete
    @posts = search_posts(params[:q]).where.not(user: User.find_by(name: "OPEN_AI_ANSWER"))
    respond_to do |format|
      format.js
      format.json { render json: @posts.pluck(:title) }
    end
  end

  private

  def search_posts(query)
    conditions = [
      "title ILIKE ?",
      "title ILIKE ?",
      "title ILIKE ?",
      "title ILIKE ?" ]

    search_queries = [
      "%#{query}%",
      "%#{query.tr('ぁ-ん', 'ァ-ン')}%",
      "%#{query.tr('ァ-ン', 'ぁ-ん')}%",
      "%#{query.tr('a-zA-Z', '')}%" ]

    posts = Post.where(conditions.join(" OR "), *search_queries)
            .where.not(id: Post.joins(:user).where(users: { name: "OPEN_AI_ANSWER" }).select(:id))

    if query.match?(/[a-zA-Z]/)
      posts = posts.where("title ILIKE ?", "%#{query}%")
    end
    posts
  end
end
