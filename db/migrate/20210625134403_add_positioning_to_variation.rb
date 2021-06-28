class AddPositioningToVariation < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :coorext, :string
  end
end
