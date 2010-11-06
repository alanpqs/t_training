# == Schema Information
# Schema version: 20101105154656
#
# Table name: regions
#
#  id         :integer         not null, primary key
#  region     :string(255)
#  created_by :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Region < ActiveRecord::Base
  
  attr_accessible :region
  
  has_many :countries
  
  validates :region,      :presence => true,
                          :length => { :maximum => 25 },
                          :uniqueness => { :case_sensitive => false }
end
