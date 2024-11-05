class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 30 }
  validates :aruaru_one, presence: true, length: { maximum: 30 }
  validates :aruaru_two, presence: true, length: { maximum: 30 }
  validates :aruaru_three, presence: true, length: { maximum: 30 }
  validates :aruaru_four, presence: true, length: { maximum: 30 }
  validates :aruaru_five, presence: true, length: { maximum: 30 }

  belongs_to :user
end
