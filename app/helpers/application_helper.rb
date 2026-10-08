module ApplicationHelper
  def default_meta_tags
    # content_for(:title) があればページ名を使う。display_meta_tags が出す
    # <title> と、レイアウトが独自に出す <title> の中身を合わせるための処理
    # （2つの <title> タグが別の文字列を持つと、どちらが表示されるかが
    # ブラウザの実装に依存して不安定になるため）。
    page_title = content_for(:title).presence || "あるある神経衰弱：界隈探求ゲーム"

    {
      site: "あるある神経衰弱：界隈探求ゲーム",
      title: page_title,
      reverse: true,
      charset: "utf-8",
      description: "あらゆる界隈のあるあるを、AIで生成したり、みんなで投稿し遊ぶゲームです！",
      canonical: request.original_url,
      separator: "|",
      og: {
          site_name: "あるある神経衰弱：界隈探求ゲーム",
          title: page_title,
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
