class Variation < ApplicationRecord
  FILTER_TYPES = ['Gray1', 'Gray2','Gray3', 'Gray4','Gray5', 'Gray6','Gray7', 'Gray8','Gray9', 'Brillo', 'Mosaico']
  attr_accessor :variations_attributes
  belongs_to :picture
  has_one_attached :image
  def pdi_filter(filter_asked)
    filter_applied = FILTER_TYPES.index(filter_asked)
    im = Vips::Image.new_from_file ActiveStorage::Blob.service.send(:path_for, picture.image.key), access: :sequential
    case filter_applied
    when 0
      im = (im[0]+im[1]+im[2])/3
    when 1
      im = (im[0]*0.3+im[1]*0.59+im[2]*0.11)
    when 2
      im = (im[0]*0.2126+im[1]*0.7152+im[2]*0.0722)
    when 3
      im = ([im[0],im[1],im[2]].max+[im[0],im[1],im[2]].min)/2
    when 4
      im = [im[0],im[1],im[2]].max
    when 5
      im = [im[0],im[1],im[2]].min
    when 6
      im = im[0]
    when 7
      im = im[1]
    when 8
      im = im[2]
    else
    end
    
    filename = "#{im.filename.to_s.split('.').first}_#{filter_asked}.jpg"
    im.write_to_file "app/assets/images/#{filename}"
    self[:filter_type] = filter_asked
    image.attach(io: File.open(Rails.root.join('app','assets','images',"#{filename}")), filename:'#{filename}.jpg',content_type:'image/jpg')
  end
  

  
end
