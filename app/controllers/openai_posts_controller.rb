class OpenaiPostsController < ApplicationController
    protect_from_forgery  # CSRF対策

    def answer
        question = params[:question]

        if question.blank?
            flash[:alert] = "あるあるを知りたい界隈名を入力してね！"
            redirect_to root_path
            return
        end

        # お題がAIが以前生成したものであれば取得、なければ生成
        post = Post.find_or_create_from_openai(question)

        # データベースに保存されていればゲーム画面に遷移
        if post&.persisted?
            redirect_to start_game_path(post)
        else
            # postが存在が保存されてない場合、postが存在しない場合でメッセージを分岐
            flash[:alert] = post ? "ごめんね！あるある思いつかない！代わりに投稿してね！" : "AI使いすぎちゃった！また今度使ってね！"
            redirect_to root_path
        end
    end
end
