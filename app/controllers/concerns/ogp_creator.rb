class OgpCreator
  require "mini_magick"

  BASE_IMAGE_PATH = "./app/assets/images/OGP_game.png"
  GRAVITY = "center"
  TEXT_POSITION = "0,-170"
  FONT = "./app/assets/fonts/MPLUSRounded1c-Medium.ttf"
  FONT_SIZE = 50
  INDENTION_COUNT = 20
  ROW_LIMIT = 8

  def self.build(text)
    text_a, text_b = text.split("\n", 2)
    text_a = text_a.gsub("'", "’").force_encoding("UTF-8")
    text_b = prepare_text(text_b)
    text_b = text_b.gsub("'", "’").force_encoding("UTF-8")
    image = MiniMagick::Image.open(BASE_IMAGE_PATH)

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

  def self.prepare_text(text)
    text = text.to_s.gsub("'", "’").force_encoding("UTF-8")
    text.scan(/.{1,#{INDENTION_COUNT}}/)[0...ROW_LIMIT].join("\n")
  end
end
