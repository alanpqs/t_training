class AddTicketCreditsToVendor < ActiveRecord::Migration
  def self.up
    add_column :vendors, :ticket_credits, :integer, :default => 50
  end

  def self.down
    remove_column :vendors, :ticket_credits
  end
end
