class AddFeeIdToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :fee_id, :integer
    add_column :issues, :expiry_date, :date
    add_column :issues, :user_id, :integer
  end

  def self.down
    remove_column :issues, :fee_id
    remove_column :issues, :expiry_date
    remove_column :issues, :user_id
  end
end
