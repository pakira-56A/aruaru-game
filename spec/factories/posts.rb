FactoryBot.define do
    factory :post do
        title { "タイトル" }
        aruaru_one { "内容1" }
        aruaru_two { "内容2" }
        aruaru_three { "内容3" }
        aruaru_four { "内容4" }
        aruaru_five { "内容5" }
        association :user
    end
end
