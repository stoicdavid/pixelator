class CreateVariations < ActiveRecord::Migration[6.1]
  def change
    create_table :variations do |t|
      t.string :filter_type

      t.timestamps
    end
  end
end
