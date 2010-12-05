class AddAuthorizedToCity < ActiveRecord::Migration
  def self.up
    add_column :cities, :authorized, :boolean, :default => false
  end

  def self.down
    remove_column :cities, :authorized
  end
end
