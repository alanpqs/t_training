class CreateSearchlists < ActiveRecord::Migration
  def self.up
    create_table :searchlists do |t|
      t.integer :user_id
      t.string :focus
      t.integer :category_id
      t.string :topics
      t.integer :proximity
      t.integer :country_id
      t.integer :region_id
      t.integer :medium_id

      t.timestamps
    end
  end

  def self.down
    drop_table :searchlists
  end
end
