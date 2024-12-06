class PostOgpUploader < CarrierWave::Uploader::Base

  # storage :file

  #　❶一旦ローカルででS3に保存できるか確認
  storage :fog

  # ❷保存場所を指定
  # if Rails.env.production?
  #   storage :fog
  # else
  #   storage :file
  # end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
