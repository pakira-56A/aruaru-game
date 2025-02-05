class SearchPostsController < ApplicationController
  def search
    @q = Post.ransack(params[:q])
    # AIが生成した投稿は除外
    @posts = @q.result(distinct: true).where.not(user: User.find_by(name: "OPEN_AI_ANSWER"))
    respond_to do |format|
      format.js
      format.html { render :search }
    end
    @tags = Tag.all
  end

  def autocomplete
    # AIが生成した投稿は除外
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
            # AIが生成した投稿は（userテーブルと結合して検索し、投稿IDを取得してから）除外
            .where.not(id: Post.joins(:user).where(users: { name: "OPEN_AI_ANSWER" }).select(:id))

    if query.match?(/[a-zA-Z]/)
      posts = posts.where("title ILIKE ?", "%#{query}%")
    end
    posts
  end
end
