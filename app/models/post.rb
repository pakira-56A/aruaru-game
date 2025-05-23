class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 40 }
  validates :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five, presence: true, length: { maximum: 40 }

  belongs_to :user

  has_many :tag_maps, dependent: :destroy
  has_many :tags, through: :tag_maps
  has_many :likes, dependent: :destroy

  mount_uploader :ogp, PostOgpUploader

  scope :exclude_open_ai_answer, -> { where.not(user: User.find_by(name: "OPEN_AI_ANSWER")) }

  def self.ransackable_attributes(_auth_object = nil)
    [ "title" ]
  end

  def save_tags(tags)
    # .uniqで同じタグ名が複数あれば削除
    tag_list = tags.split(/[[:blank:]]+|、|。|,|\./).uniq
    current_tags = self.tags.pluck(:tag_name)
    old_tags = current_tags - tag_list
    new_tags = tag_list - current_tags

    # tagsテーブルから、old_tagsを探し出して削除
    old_tags.each do |old|
      self.tags.delete Tag.find_by(tag_name: old)
    end

    # tagsテーブルからnew_tagsを探し、tag_mapsテーブルにtag_idを追加
    new_tags.each do |new|
      # tag_nameがnewと一致するタグを探し、1件もなければ作成
      new_post_tag = Tag.find_or_create_by(tag_name: new)
      # new_post_tagには、見つけたor作成したタグが格納
      self.tags << new_post_tag
    end
  end

  # AIに生成させる場合、過去に作ってればそれを、なければ新たに作成（お題の文字数制限は、入力フォームで制限してます）
  def self.find_or_create_from_openai(question)
    # Railsののキャッシュから、AIが作成したお題の投稿がないか探す
    cached_post = Rails.cache.fetch("openai_post_#{question}") do
      find_by(title: question, user: User.find_by(name: "OPEN_AI_ANSWER"))
    end

    # キャッシュに、AIが作成したお題の投稿が見つかった場合、その投稿を返す
    return cached_post if cached_post

    # OpenAIサービスを呼び出して、questionに対する応答を取得
    openai_response = OpenaiService.get_response(question)
    # もし取得できなかったら、nilを返す
    return nil unless openai_response

    answers = process_openai_response(openai_response)
    post = create_from_answers(question, answers)

    # 作成した投稿がデータベースに保存されたら（post.persisted?がtrueなら）、再度キャッシュにその投稿を保存
    Rails.cache.write("openai_post_#{question}", post) if post.persisted?
    post
  end

  private

  def self.process_openai_response(response)
    response.split("。").map(&:strip)
            .reject { |sentence| sentence.start_with?(".") }
            .map { |sentence| sentence.sub(/^\d+\s*/, "") }
  end

  def self.create_from_answers(question, answers)
    create(title: question,
            user: User.find_or_create_by(name: "OPEN_AI_ANSWER"),
            aruaru_one: answers[0],
            aruaru_two: answers[1],
            aruaru_three: answers[2],
            aruaru_four: answers[3],
            aruaru_five: answers[4])
  end
end
