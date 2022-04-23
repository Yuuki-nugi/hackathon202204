class AddProductsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :line_id, null: false
      t.string :yahoo_product_id, null: false
      t.boolean :is_liked, null: false, default: false

      t.timestamps
    end
  end
end
