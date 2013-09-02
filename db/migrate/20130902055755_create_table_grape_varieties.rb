class CreateTableGrapeVarieties < ActiveRecord::Migration
	def up
		create_table :grape_varieties do |t|
			t.integer :product_id
			t.string :name_zh
			t.string :name_en
			t.string :origin_name
			t.string :percent
			t.timestamps
		end

		add_index :grape_varieties, :product_id
		add_index :grape_varieties, :name_en
		add_index :grape_varieties, :name_zh
		add_index :grape_varieties, :origin_name
	end

	def down
		drop_table :grape_varieties
	end
end
