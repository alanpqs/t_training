class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.integer :issue_id
      t.integer :user_id
      t.integer :quantity, :default => 1
      t.integer :credits
      t.boolean :confirmed, :default => false
      t.date :confirmation_date

      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end
