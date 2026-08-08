FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    sequence(:name) { |n| "ユーザー#{n}" }
    provider { "provider_name" }
    sequence(:uid) { |n| "unique_uid_#{n}" }

    # AIが自動生成した投稿を持つ特別なユーザー（アプリ全体で名前で判別している）
    trait :open_ai_answer do
      name { "OPEN_AI_ANSWER" }
    end
  end
end
