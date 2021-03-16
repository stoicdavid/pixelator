class AddPictureToVariations < ActiveRecord::Migration[6.1]
  def change
    add_reference :variations, :picture, null: false, foreign_key: true
  end
end
