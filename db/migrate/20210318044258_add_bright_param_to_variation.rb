class AddBrightParamToVariation < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :bright_param, :integer
  end
end
