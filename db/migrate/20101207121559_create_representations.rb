class CreateRepresentations < ActiveRecord::Migration
  def self.up
    create_table :representations do |t|
      t.integer :user_id
      t.integer :vendor_id

      t.timestamps
    end
  end

  def self.down
    drop_table :representations
  end
end
