class AddMosaicParamToVariation < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :mwidth_param, :integer
    add_column :variations, :mheight_param, :integer
  end
end
