# == Schema Information
# Schema version: 20110131131017
#
# Table name: fees
#
#  id               :integer         not null, primary key
#  band             :string(255)
#  bottom_of_range  :decimal(8, 2)
#  top_of_range     :decimal(8, 2)
#  credits_required :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Fee < ActiveRecord::Base
  
  attr_accessible :band, :bottom_of_range, :top_of_range, :credits_required

  has_many  :issues
  
  validates :band,              :presence       => true,
                                :length         => { :maximum => 1 },
                                :uniqueness     => { :case_sensitive => false }
  validates :bottom_of_range,   :presence       => true,
                                :numericality   => true
  validates :top_of_range,      :presence       => true,
                                :numericality   => true
  validates :credits_required,  :presence       => true,
                                :numericality   => { :only_integer => true }
  
  
end
