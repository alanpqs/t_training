# == Schema Information
# Schema version: 20110112001028
#
# Table name: items
#
#  id          :integer         not null, primary key
#  resource_id :integer
#  scheduled   :boolean
#  start       :date
#  end         :date
#  days        :string(255)
#  time_of_day :string(255)
#  price       :decimal(, )
#  venue       :string(255)
#  filled      :boolean
#  notes       :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Item < ActiveRecord::Base
  
  attr_accessible :resource_id, :scheduled, :start, :end, :days, 
                  :time_of_day, :price, :venue, :filled, :notes
  
  attr_accessor :dollar_value
                
  DAYTIME_TYPES = [ "All day", "Mornings", "Afternoons", "Evenings" ]
                  
  belongs_to :resource
  
  #days_regex = /[A-Z][a-z]{2}(\W[A-Z][a-z]{2})*\Z/
  days_regex = /([A-Z][a-z]{2}(\W[A-Z][a-z]{2})*\Z)|\Z/
  
  validates :resource_id,       :presence       => true
  validates :start,             :presence       => true
  validates :end,               :presence       => true, :if => :event?
  validates :days,              :length         => { :maximum => 28, :allow_blank => true },
                                :format         => { :with => days_regex }
  validates :time_of_day,       :inclusion      => { :in => DAYTIME_TYPES, :allow_blank => true }
  validates :price,             :presence       => true,
                                :numericality   => { :only_integer => true }
  validates :venue,             :presence       => true,
                                :length         => { :maximum => 100 }
  
  private
  
    def event?
      self.scheduled == true
    end
end
