class Picture < ApplicationRecord

  has_one_attached :image
  has_many :variations
  accepts_nested_attributes_for :variations, :allow_destroy => true
  
  def remaining_filters
     Variation::FILTER_TYPES - variations.map(&:filter_type)
  end

end
