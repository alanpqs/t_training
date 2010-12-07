# == Schema Information
# Schema version: 20101207121559
#
# Table name: representations
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  vendor_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Representation < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :vendor
  
  validates     :user_id,       :presence =>  true,
                                :uniqueness => { :scope => :vendor_id }
  validates     :vendor_id,     :presence =>  true
end
