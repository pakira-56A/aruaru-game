class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 40 }
  validates :aruaru_one, :aruaru_two, :aruaru_three, :aruaru_four, :aruaru_five, presence: true, length: { maximum: 40 }

  belongs_to :user

  has_many :tag_maps, dependent: :destroy
  has_many :tags, through: :tag_maps
  has_many :likes, dependent: :destroy

  mount_uploader :ogp, PostOgpUploader

  # AIが生成した投稿は検索対象から除外
  scope :exclude_open_ai_answer, -> { where.not(user: User.find_by(name: "OPEN_AI_ANSWER")) }

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

    # AIに生成させる場合（お題の文字数制限は、入力フォームで制限してます）
    def self.find_or_create_from_openai(question)
      # Railsのキャッシュでお題で以前作った投稿を探す。あれば取得、なければデータベースを探す。
      cached_post = Rails.cache.fetch("openai_post_#{question}") do
          # ユーザーが入力したお題で、AIが以前生成した投稿をデータベースから探す
          find_by(title: question, user: User.find_by(name: "OPEN_AI_ANSWER"))
      end

      # キャッシュかデータベースから取得した投稿があれば、その投稿を返す
      return cached_post if cached_post

      # 見つからなければ、openai_service.rbの記載を使う
      openai_response = OpenaiService.get_response(question)
      # openai_service.rbで反応がなければ、nilを返す
      return nil unless openai_response

      # AIの返答を使って、あるあるを５つに切り分ける処理をする
      answers = process_openai_response(openai_response)
      # お題とAIが生成したあるあるを使って、新しい投稿を作成
      post = create_from_answers(question, answers)

      # 新規作成した投稿がデータベースに保存されたら、キャッシュにその投稿を記録
      Rails.cache.write("openai_post_#{question}", post) if post.persisted?
      # 新規作成した投稿を返す
      post
  end

  private

  # AIの返答を、あるあるを５つに切り分け。不要な記号などを除去
  def self.process_openai_response(response)
      response.split("。").map(&:strip)
              .reject { |sentence| sentence.start_with?(".") }
              .map { |sentence| sentence.sub(/^\d+\s*/, "") }
  end

  # お題とAIが生成したあるあるを使って、新しい投稿を作成
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
