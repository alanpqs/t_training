class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.integer :item_id
      t.integer :vendor_id
      t.boolean :event
      t.decimal :cents
      t.string :currency
      t.integer :no_of_tickets, :default => 1
      t.string :contact_method, :default => "Email"

      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
