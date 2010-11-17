class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :category
      t.integer :aim
      t.boolean :authorized, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
