FactoryBot.define do
  factory :tag do
    sequence(:tag_name) { |n| "タグ#{n}" }
  end
end
