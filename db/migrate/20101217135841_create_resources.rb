class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.string :name
      t.integer :vendor_id
      t.integer :category_id
      t.integer :medium_id
      t.string :length_unit, :default => "Hour"
      t.integer :length, :default => 1
      t.string :description
      t.string :webpage
      t.boolean :hidden, :default => false 

      t.timestamps
    end
  end

  def self.down
    drop_table :resources
  end
end
