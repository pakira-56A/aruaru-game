class PostOgpUploader < CarrierWave::Uploader::Base
  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def store_dir
    if Rails.env.production?
      "#{mounted_as}_production:post_ID:#{model.id}"
    else
      # 保存できてるかテスト時用のフォルダ名
      "#{mounted_as}_development:post_ID:#{model.id}"
    end
  end
end
