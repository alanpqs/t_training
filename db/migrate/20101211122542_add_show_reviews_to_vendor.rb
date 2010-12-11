class AddShowReviewsToVendor < ActiveRecord::Migration
  def self.up
    add_column :vendors, :show_reviews, :boolean, :default => false
  end

  def self.down
    remove_column :vendors, :show_reviews
  end
end
