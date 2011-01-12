class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :resource_id
      t.boolean :scheduled, :default => false
      t.date :start
      t.date :end
      t.string :days
      t.string :time_of_day
      t.decimal :price
      t.string :venue
      t.boolean :filled, :default => false
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
