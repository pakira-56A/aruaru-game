class OgpCreator
  require "mini_magick"

  BASE_IMAGE_PATH = "./app/assets/images/OGP_game.png"
  GRAVITY = "center"
  TEXT_POSITION = "0,-170"
  FONT = "./app/assets/fonts/MPLUSRounded1c-Medium.ttf"
  FONT_SIZE = 50
  INDENTION_COUNT = 20
  ROW_LIMIT = 8
  MAX_TEXT_LENGTH = 400

  def self.build(text)
    text_a, text_b = sanitize(text).split("\n", 2)
    text_a = strip_line_head(text_a.to_s)
    text_b = prepare_text(text_b)
    image = MiniMagick::Image.open(BASE_IMAGE_PATH)

    # 緑色はユーザー名、青色は投稿名を表記します
    image.combine_options do |config|
      config.font FONT
      config.fill "green"
      config.gravity GRAVITY
      config.pointsize FONT_SIZE
      config.draw "text #{TEXT_POSITION} '#{text_a}'"

      config.fill "blue"
      config.pointsize FONT_SIZE + 10
      # 緑色の文字との距離（青文字に改行がある場合は80、ない場合は120）
      y_start = TEXT_POSITION.split(",").last.to_i + (text_b.include?("\n") ? 80 : 120)
      if text_b
        text_b.split("\n").each_with_index do |line, index| # 改行文字に基づいて行を分割
          y_position = y_start + 80 * index # 数字は改行した際のの行間
          config.draw "text #{TEXT_POSITION.split(',').first},#{y_position} '#{line}'"
        end
      end
    end
  end

  # ImageMagick の draw 構文・文字列展開に解釈されうる文字を取り除く。
  # 引用符は全角に置き換え、バックスラッシュ・%・行頭の@・制御文字は削除する。
  def self.sanitize(text)
    text = text.to_s.dup.force_encoding("UTF-8").scrub("")
    text = text[0, MAX_TEXT_LENGTH]
    text = text.gsub(/[\x00-\x09\x0B-\x1F\x7F\\%]/, "").gsub(/["']/, "’")
    text.split("\n").map { |line| strip_line_head(line) }.join("\n")
  end

  # 行頭の@（間に空白があっても連続していても）をすべて取り除く。
  def self.strip_line_head(line)
    line.sub(/\A(?:\s*@)+/, "")
  end

  def self.prepare_text(text)
    text = text.to_s
    # 20文字ごとの分割で新しく行頭になった@も取り除く
    text.scan(/.{1,#{INDENTION_COUNT}}/)[0...ROW_LIMIT].map { |line| strip_line_head(line) }.join("\n")
  end
end
