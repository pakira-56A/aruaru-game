class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 40 }
  validates :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five, presence: true, length: { maximum: 40 }

  belongs_to :user

  mount_uploader :ogp, PostOgpUploader
end
