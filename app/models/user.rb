class User < ApplicationRecord
  devise :database_authenticatable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :like_posts, through: :likes, source: :post

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    if user.new_record?
      existing_user = find_by(email: auth.info.email)
      if existing_user && !email_verified?(auth)
        # メール未検証のGoogleアカウントでは既存ユーザーに紐付けない（なりすまし防止）。
        # provider/uid を持たない空の未保存ユーザーを返し、コントローラ側で認証失敗として扱う。
        return new
      elsif existing_user
        # 同じメールの既存ユーザーが見つかった場合、provider/uidを紐付けておく。
        # これをしないと次回以降も毎回メール照合になり、メール変更時にアカウントが分裂しうる。
        existing_user.update(provider: auth.provider, uid: auth.uid)
        user = existing_user
      else
        user.name = auth.info.name
        user.email = auth.info.email
        user.save!
      end
    end
    user
  end

  def self.email_verified?(auth)
    verified = auth.info&.email_verified
    verified = auth.extra&.raw_info&.email_verified if verified.nil?
    verified == true || verified.to_s == "true"
  end
  private_class_method :email_verified?

  def self.create_unique_string
    SecureRandom.uuid
  end

  def like(post)
    like_posts << post
  end

  def unlike(post)
    like_posts.destroy(post)
  end

  def like?(post)
    like_posts.include?(post)
  end
end
