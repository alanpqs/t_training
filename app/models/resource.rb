# == Schema Information
# Schema version: 20110111104631
#
# Table name: resources
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  vendor_id   :integer
#  category_id :integer
#  medium_id   :integer
#  length_unit :string(255)     default("Hour")
#  length      :integer         default(1)
#  description :string(255)
#  webpage     :string(255)
#  hidden      :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

class Resource < ActiveRecord::Base
  
  attr_accessible :name, :vendor_id, :category_id, :medium_id, :length_unit, :length, 
        :description, :webpage, :hidden, :tag_list, :feature_list
  attr_writer :tag_list, :feature_list
  
  LENGTH_TYPES = [ "Minute", "Hour", "Day", "Month", "Term", "Year", "Session", "Term", "Page", "Item" ]
  
  acts_as_taggable
  acts_as_taggable_on :features
  
  belongs_to :vendor
  belongs_to :category
  belongs_to :medium
  
  validates :name,            :presence       => true,
                              :length         => { :maximum => 50 },
                              :uniqueness     => { :scope => [:vendor_id, :category_id], :case_sensitive => false }
  validates :vendor_id,       :presence       => true
  validates :category_id,     :presence       => true
  validates :medium_id,       :presence       => true
  validates :length_unit,     :presence       => true,
                              :inclusion      => { :in => LENGTH_TYPES }
  validates :length,          :presence       => true,
                              :numericality   => { :only_integer => true }
  validates :description,     :length         => { :maximum => 255, :allow_blank => true }
  validates :webpage,         :length         => { :maximum => 50, :allow_blank => true }
  
  validates_length_of :feature_list, :maximum => 15, 
                              :too_long => " - the maximum number of actual words in the keyword list is 15.", 
                              :tokenizer => lambda {|str| str.scan(/\w+/) }

  
  validates_associated :vendor, :category, :medium


end
