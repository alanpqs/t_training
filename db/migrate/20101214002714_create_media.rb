class CreateMedia < ActiveRecord::Migration
  def self.up
    create_table :media do |t|
      t.string :medium
      t.boolean :authorized, :default => false
      t.integer :user_id
      t.text :rejection_message

      t.timestamps
    end
  end

  def self.down
    drop_table :media
  end
end
