# == Schema Information
# Schema version: 20101202195036
#
# Table name: cities
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  country_id :integer
#  created_at :datetime
#  updated_at :datetime
#  latitude   :float
#  longitude  :float
#

class City < ActiveRecord::Base
  
  attr_accessible :name, :country_id, :latitude, :longitude
  
  belongs_to :country
  
  geocoded_by :location
  
  after_validation :fetch_coordinates
  
  city_regex = /\A[A-Z][a-z]*\b\S?([\s|\S][a-zA-Z][a-z]*\b\S?)*\z/
  
  validates  :name,       :presence     => true,
                          :length       => { :maximum => 25 }, 
                          :uniqueness   => { :scope => :country_id, :case_sensitive => false },
                          :format       => { :with => city_regex,
          :message => "should be correctly formatted, starting with a capital and followed by small letters" }
  validates  :country_id, :presence     => true
  validates  :latitude,   :inclusion    => { :in => -90..90, :allow_nil => true },
                          :numericality => true, :allow_nil => true
  validates  :longitude,  :inclusion    => { :in => -180..180, :allow_nil => true },
                          :numericality => true, :allow_nil => true
                          
  
  def location
    [name, self.country.name].compact.join(', ')
  end
  
  def self.no_geolocation
    City.find(:all, :conditions => ["latitude IS ? OR longitude IS ?", nil, nil])
  end
                     
end
