# == Schema Information
# Schema version: 20101116103755
#
# Table name: categories
#
#  id         :integer         not null, primary key
#  category   :string(255)
#  aim        :integer
#  authorized :boolean
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Category < ActiveRecord::Base
  
  attr_accessible :category, :aim, :authorized, :user_id
  
  cat_regex = /\A(\w+(\s?([&]\s)?))+\Z/
  
  AIM_TYPES = [ "Business", "Job", "Personal", "World", "Fun" ]

  belongs_to :user
  
  validates :category,        :presence       => true,
                              :length         => { :maximum => 30 },
                              :uniqueness     => { :case_sensitive => false },
                              :format         => { :with => cat_regex, 
                                                   :message => "is invalid - please avoid commas, 
                                                                periods and double spaces" }   
  validates :aim,             :presence       => true,
                              :numericality   => true,
                              :inclusion      => { :in => (0..4) }
  #validates :user_id,         :presence       => true
                              
  def training_aim               #display the grouping (Job, Business, etc) for a category
    key = self.aim
    a = AIM_TYPES
    a[key]  
  end
  
  def self.selection_by_aim(index)   #create a list of categories after entering aim index (0..4)
    Category.find(:all, :conditions => ["aim = ?", index], :order => "category")
  end
  
  def self.display_aim(index)    #show the category group (Job etc) after inputting its index number
    a = AIM_TYPES
    a[index]
  end
  
  def self.aims_index(value)    #find index number (0..4) for an aim, given its label
    AIM_TYPES.index(value)
  end
                                  
end
