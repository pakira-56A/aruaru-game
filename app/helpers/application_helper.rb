module ApplicationHelper
  def default_meta_tags
    {
      site: "界隈探求ゲーム",
      title: "あるある神経衰弱",
      reverse: true,
      charset: "utf-8",
      description: "あらゆる界隈のあるあるを、AIで生成したり、みんなで投稿し遊ぶゲームです！",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: "界隈探求ゲーム",
        title: "あるある神経衰弱",
        description: "あらゆる界隈のあるあるを、AIで生成したり、みんなで投稿し遊ぶゲームです！",
        type: "website",
        url: request.original_url,
        image: image_url("OGP.png"),
        local: "ja-JP"
      },

      twitter: {
        card: "summary_large_image",
        site: "@https://x.com/pakira_rrrr",
        image: image_url("OGP.png")
      }
    }
  end
end
