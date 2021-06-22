class Picture < ApplicationRecord

  has_one_attached :image
  has_many :variations, dependent: :destroy
  accepts_nested_attributes_for :variations, :allow_destroy => true
  validate :acceptable_image
  



  def remaining_filters
     Variation::FILTER_TYPES - (variations.map(&:filter_type)-["Brillo"])
  end
  
  def remaining_conv_filters
     Variation::FILTER_TYPES[14..19] - (variations.map(&:filter_type)-["Brillo"])
  end
  
  def acceptable_image
    return unless image.attached?
    
    unless image.byte_size <= 5.megabyte
        errors.add(:image, " la imagen es muy grande para ser procesada")
    end

    acceptable_types = ["image/jpeg", "image/png"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, " la imagen debe ser JPG o PNG")
    end

  end

end
