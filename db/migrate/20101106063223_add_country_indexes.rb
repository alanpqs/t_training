class AddCountryIndexes < ActiveRecord::Migration
  def self.up
    add_index :countries, :name, :unique => true
    add_index :countries, :country_code, :unique => true
  end

  def self.down
    remove_index :countries, :name
    remove_index :countries, :country_code
  end
end
