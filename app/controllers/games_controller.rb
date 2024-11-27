class GamesController < ApplicationController
  before_action :authenticate_user!, only: %i[start]

  def start
    @post = Post.find(params[:id])
    prepare_meta_tags(@post)
  end

  private

  def prepare_meta_tags(post)
    user_name = post.user.name
    title = post.title
    ogp_text = "#{user_name}さんが思う\n#{title}"
    image_url = "#{request.base_url}/images/ogp.png?text=#{CGI.escape(ogp_text)}"
    OgpCreator.build(ogp_text) # 画像生成メソッドを呼び出す

    set_meta_tags og: {
                    site_name: 'あるある神経衰弱',
                    title: post.title,
                    description: 'この界隈あるあるで遊ぼう！',
                    type: 'website',
                    url: request.original_url,
                    image: image_url,
                    locale: 'ja-JP'
                  },
                  twitter: {
                    card: 'summary_large_image',
                    site: '@https://x.com/pakira_rrr',
                    image: image_url
                  }
  end
end
