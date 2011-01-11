class AddScheduledMedium < ActiveRecord::Migration
  def self.up
    add_column :media, :scheduled, :boolean, :default => false
  end

  def self.down
    remove_column :media, :scheduled
  end
end
