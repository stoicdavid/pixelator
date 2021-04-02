class AddRgbParamToVariation < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :rgb, :string
  end
end
