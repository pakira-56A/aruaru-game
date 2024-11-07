ActiveRecord::Base.transaction do

    10.times do |n|
        User.create!(
            name: "テスト#{n+1}",
            email: "test#{n+1}@example.com",
            password: "password")
        end

    user_ids = User.ids

    20.times do |n|
        user = User.find_by(id: user_ids.sample)
        if user
            user.posts.create!(
                title: "タイトル#{n}",
                aruaru_one: "あるある1#{n + 1}",
                aruaru_two: "あるある2:#{n + 1}",
                aruaru_three: "あるある3:#{n + 1}",
                aruaru_four: "あるある4:#{n + 1}",
                aruaru_five: "あるある5:#{n + 1}")
        else
            Rails.logger.error "ユーザーが見つからないエラー"
        end
    end
end

Rails.logger.debug "#{User.count}さんと、投稿「#{Post.count}」がDBに入った"