# == Schema Information
# Schema version: 20101116103755
#
# Table name: categories
#
#  id         :integer         not null, primary key
#  category   :string(255)
#  aim        :integer
#  authorized :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Category < ActiveRecord::Base
  
  attr_accessible :category, :aim, :authorized
  
  cat_regex = /\A(\w+(\s?([&]\s)?))+\Z/
  
  AIM_TYPES = [ "Business", "Job", "Personal", "World", "Fun" ]

  
  validates :category,        :presence       => true,
                              :length         => { :maximum => 30 },
                              :uniqueness     => { :case_sensitive => false },
                              :format         => { :with => cat_regex, 
                                                   :message => "is invalid - please avoid commas, 
                                                                periods and double spaces" }   
  validates :aim,             :presence       => true,
                              :numericality   => true,
                              :inclusion      => { :in => (0..4) }
                              
  def training_aim
    key = self.aim
    a = AIM_TYPES
    a[key]  
  end
  
  def self.selection_by_aim(value)
    Category.find(:all, :conditions => ["aim = ?", value], :order => "category")
  end
  
  def self.display_aim(value)
    a = AIM_TYPES
    a[value]
  end
                                
end
