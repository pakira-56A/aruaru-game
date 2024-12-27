class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 40 }
  validates :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five, presence: true, length: { maximum: 40 }

  belongs_to :user

  has_many :tag_maps, dependent: :destroy
  has_many :tags, through: :tag_maps

  mount_uploader :ogp, PostOgpUploader

  def self.ransackable_attributes(_auth_object = nil)
    [ "title" ]
  end

  def save_tags(tags)
    # タグをスペース区切りで分割し配列に。 + は「一回以上の繰り返し」、.uniqで同じタグ名が複数あれば削除
    tag_list = tags.split(/[[:blank:]]+|、|。|,|\./).uniq
    current_tags = self.tags.pluck(:tag_name)
    old_tags = current_tags - tag_list
    new_tags = tag_list - current_tags

    # tagsテーブルからold_tagsを探し出して削除する
    old_tags.each do |old|
      # tag_mapsテーブルにあるpost_idとtag_idを削除
      self.tags.delete Tag.find_by(tag_name: old)
    end

    # tagsテーブルからnew_tagsを探し、tag_mapsテーブルにtag_idを追加
    new_tags.each do |new|
      # 条件のレコードを初めの1件を取得し、1件もなければ作成
      new_post_tag = Tag.find_or_create_by(tag_name: new)
      # tag_mapsテーブルにpost_idとtag_idを保存
      self.tags << new_post_tag
    end
  end
end
