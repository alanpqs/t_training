# == Schema Information
# Schema version: 20101105154656
#
# Table name: countries
#
#  id            :integer         not null, primary key
#  name          :string(255)
#  country_code  :string(255)
#  currency_code :string(255)
#  phone_code    :string(255)
#  region_id     :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Country < ActiveRecord::Base
  
  attr_accessible :name, :country_code, :currency_code, :phone_code, :region_id
  
  belongs_to    :region
  
  idd_regex = /[+]\d+([-])?\d+$/
  
  validates :name,            :presence     => true,
                              :length       => { :maximum => 35 },
                              :uniqueness   => { :case_sensitive => false }
  validates :country_code,    :presence     => true,
                              :length       => { :maximum => 3},
                              :uniqueness   => { :case_sensitive => false }
  validates :currency_code,   :presence     => true,
                              :length       => { :maximum => 3}
  validates :phone_code,      :presence     => true,
                              :length       => { :maximum => 7},
                              :format       => { :with => idd_regex }
  validates :region_id,       :presence     => true,
                              :numericality => true
  
  
end
