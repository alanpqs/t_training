class AddAttendanceToMedium < ActiveRecord::Migration
  def self.up
    add_column :media, :attendance, :boolean, :default => false
  end

  def self.down
    remove_column :media, :attendance
  end
end
