class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :category
      t.string :target
      t.boolean :authorized, :default => 0
      t.references :user
      t.text :message
      t.boolean :message_sent, :default => 0
      t.string :submitted_name
      t.string :submitted_group

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
