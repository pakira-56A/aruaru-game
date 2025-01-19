class Like < ApplicationRecord
    belongs_to :user
    belongs_to :post

    # 同じ投稿を何度もお気に入りするのを防止
    validates :user_id, uniqueness: { scope: :post_id }
end
