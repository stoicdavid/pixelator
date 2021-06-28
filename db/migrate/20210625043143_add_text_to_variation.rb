class AddTextToVariation < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :phrase, :string
  end
end
