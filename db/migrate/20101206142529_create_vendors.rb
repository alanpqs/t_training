class CreateVendors < ActiveRecord::Migration
  def self.up
    create_table :vendors do |t|
      t.string :name
      t.integer :country_id
      t.string :address
      t.string :website
      t.string :email
      t.string :phone
      t.text :description
      t.string :verification_code
      t.boolean :verified, :default => false
      t.boolean :inactive, :default => false
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :vendors
  end
end
