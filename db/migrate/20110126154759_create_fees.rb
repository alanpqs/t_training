class CreateFees < ActiveRecord::Migration
  def self.up
    create_table :fees do |t|
      t.string :band
      t.decimal :bottom_of_range, :precision => 8, :scale => 2
      t.decimal :top_of_range, :precision => 8, :scale => 2
      t.integer :credits_required

      t.timestamps
    end
  end

  def self.down
    drop_table :fees
  end
end
