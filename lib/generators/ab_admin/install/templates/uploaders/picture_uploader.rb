class PictureUploader < AbAdmin::CarrierWave::BaseUploader
  
  process quality: 80
  process cropper: :cropper_geometry

  version :thumb do
    process resize_to_fill: [80, 80]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
