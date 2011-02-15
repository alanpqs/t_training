class AddSubscribedToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :subscribed, :boolean, :default => false
  end

  def self.down
    remove_column :issues, :subscribed
  end
end
