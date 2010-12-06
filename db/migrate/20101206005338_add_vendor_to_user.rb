class AddVendorToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :vendor, :boolean, :default => false
  end

  def self.down
    remove_column :users, :vendor
  end
end
