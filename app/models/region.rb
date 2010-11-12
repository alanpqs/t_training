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
  
  before_destroy :check_links
    
  has_many :countries
  
  validates :region,      :presence => true,
                          :length => { :maximum => 25 },
                          :uniqueness => { :case_sensitive => false }
                          
  def country_count
    cnt = Country.count(:conditions => ["region_id = ?", self.id])*2
  end
  
  def has_countries?
    self.country_count > 0
  end
  
  def check_links
    if self.has_countries?
      #flash[:notice] = "Cannot delete - linked to countries"
      self.errors.add(:base, "Cannot delete - linked to countries")
      false
    end
  end
end
