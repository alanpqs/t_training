# == Schema Information
# Schema version: 20101028112934
#
# Table name: regions
#
#  id         :integer         not null, primary key
#  region     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Region < ActiveRecord::Base
  
  attr_accessible :region
  
  validates :region,      :presence => true,
                          :length => { :maximum => 25 },
                          :uniqueness => { :case_sensitive => false }
end
