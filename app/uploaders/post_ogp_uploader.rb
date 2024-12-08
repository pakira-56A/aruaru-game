class PostOgpUploader < CarrierWave::Uploader::Base

  # storage :file

  # if Rails.env.production?
    storage :fog
  # else
  #   storage :file
  # end

  def store_dir
    def store_dir
      if Rails.env.production?
        "#{mounted_as}_本番環境、投稿ID:#{model.id}"
      else
        "#{mounted_as}_ローカル、投稿ID:#{model.id}"
      end
    end
  end
end
