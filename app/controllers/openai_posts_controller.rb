class OpenaiPostsController < ApplicationController
  protect_from_forgery  # CSRF対策

  def answer
    question = params[:question]

    if question.blank?
      flash[:alert] = "あるあるを知りたい界隈名を入力してね！"
      redirect_to root_path
      return
    end

    post = Post.find_or_create_from_openai(question)

    if post&.persisted?
      redirect_to start_game_path(post)
    else
      flash[:alert] = post ? "ごめんね！あるある思いつかない！代わりに投稿してね！" : "AI使いすぎちゃった！また今度使ってね！"
      redirect_to root_path
    end

  Time.zone = "Tokyo"
  cookies[:cookie_count] = {
    value: Time.zone.today.to_s,
    expires: Time.zone.now + 1.day,
    secure: Rails.env.production?,
    httponly: true,   # XSS対策
    same_site: :lax   # CSRF対策
    }
  end
end
