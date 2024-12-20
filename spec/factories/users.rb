FactoryBot.define do
    factory :user do
        sequence(:email) { |n| "user_#{n}@example.com" }
        password { "password" }
        password_confirmation { "password" }
        name { "ユーザー名" }
        provider { "provider_name" }
        uid { "unique_uid" }
    end
end
