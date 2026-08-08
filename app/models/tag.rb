class Tag < ApplicationRecord
  has_many :tag_maps, dependent: :destroy, foreign_key: "tag_id"
  has_many :posts, through: :tag_maps

  # 投稿が削除されてもTagレコードは残るため、投稿が1件以上あるタグだけを対象にする
  scope :with_posts, -> { joins(:posts).distinct }
  # 指定ユーザーが投稿した界隈のタグだけを対象にする
  scope :posted_by, ->(user) { with_posts.where(posts: { user_id: user.id }) }
end
