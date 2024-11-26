module ApplicationHelper
    def default_meta_tags
        {
        site: 'あるある神経衰弱：界隈探求ゲーム',
        title: 'あるある神経衰弱：界隈探求ゲーム',
        reverse: true,
        charset: 'utf-8',
        description: 'あらゆる界隈のあるあるを、AIで生成したり、みんなで投稿し遊ぶゲームです！',
        keywords: 'あるある,神経衰弱,界隈',
        canonical: request.original_url,
        separator: '|',
        og: {
            site_name: :site,
            title: :title,
            description: :description,
            type: 'website',
            url: request.original_url,
            image: image_url('OGP.png'),
            local: 'ja-JP'
        },

        twitter: {
            card: 'summary_large_image',
            site: '@https://x.com/pakira_rrrr',
            image: image_url('OGP.png')
        }
        }
    end
end
