class PostOgpUploader < CarrierWave::Uploader::Base

  # storage :file

  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def store_dir
    "#{mounted_as}_#{model.user.name}さんの#{model.title}（投稿ID:#{model.id}）"
  end
end
