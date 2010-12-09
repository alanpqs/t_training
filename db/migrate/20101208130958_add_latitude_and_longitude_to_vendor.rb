class AddLatitudeAndLongitudeToVendor < ActiveRecord::Migration
  def self.up
    add_column :vendors, :latitude, :float
    add_column :vendors, :longitude, :float
  end

  def self.down
    remove_column :vendors, :longitude
    remove_column :vendors, :latitude
  end
end
