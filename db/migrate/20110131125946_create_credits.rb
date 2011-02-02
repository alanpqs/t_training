class CreateCredits < ActiveRecord::Migration
  def self.up
    create_table :credits do |t|
      t.integer :vendor_id
      t.integer :quantity
      t.string :currency, :default => "USD"
      t.decimal :cents
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :credits
  end
end
