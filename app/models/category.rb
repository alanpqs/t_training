# == Schema Information
# Schema version: 20101116103755
#
# Table name: categories
#
#  id         :integer         not null, primary key
#  category   :string(255)
#  target     :string(255)
#  authorized :boolean
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Category < ActiveRecord::Base
  
  attr_accessible :category, :target, :authorized, :user_id
  
  cat_regex = /\A(\w+(\s?([&]\s)?))+\Z/
  
  TARGET_TYPES = [ "Business", "Job", "Personal", "World", "Fun" ]

  belongs_to :user
  
  validates :category,        :presence       => true,
                              :length         => { :maximum => 30 },
                              :uniqueness     => { :case_sensitive => false },
                              :format         => { :with => cat_regex, 
                                                   :message => "is invalid - please avoid commas, 
                                                                periods and double spaces" }   
  validates :target,          :presence       => true,
                              :inclusion      => { :in => TARGET_TYPES }
  validates :user_id,         :presence       => true
                                  
end
