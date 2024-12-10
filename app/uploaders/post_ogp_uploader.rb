class PostOgpUploader < CarrierWave::Uploader::Base

  # storage :file

  # if Rails.env.production?
    storage :fog
  # else
  #   storage :file
  # end


  def store_dir
    if Rails.env.production?
      "#{mounted_as}_production:post_ID:#{model.id}"
    else
      "#{mounted_as}_development:post_ID:#{model.id}"
    end
  end

end
