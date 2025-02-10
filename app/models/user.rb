class User < ApplicationRecord
  devise :database_authenticatable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_one_attached :avatar
  attr_accessor :remove_avatar

  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :like_posts, through: :likes, source: :post

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    if user.new_record?
      existing_user = find_by(email: auth.info.email)
      if existing_user
        user = existing_user
      else
        user.name = auth.info.name
        user.email = auth.info.email
        user.save!
      end
    end
    user
  end

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
