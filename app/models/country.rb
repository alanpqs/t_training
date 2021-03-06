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
  
  has_many      :users 
  has_many      :cities
  has_many      :vendors
  has_many      :searchlists, :dependent => :destroy
  
  idd_regex = /[+]\d+([-])?(\d+)?$/
  
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
  
  
  def self.currency_list
    @currencies = Money::Currency::TABLE.sort_by { |k,v| v[:name] }
    a = []
    @currencies.each do |k,v|
      a << ["#{v[:name]} (#{v[:iso_code]})", "#{v[:iso_code]}"]
    end
    return a
  end
  
  def currency_name
    currency = Money.new(1000, self.currency_code).currency
    currency.name
  rescue
    "Currency code has changed"
  end

  def currency_symbol
    currency = Money.new(1000, self.currency_code).currency
    currency.symbol
  rescue
    "None"
  end
  
  def currency_multiplier
    currency = Money.new(1000, self.currency_code).currency
    currency.subunit_to_unit
  end
  
  def decimal_places
    if self.currency_multiplier == 1000
      n = 3
    elsif self.currency_multiplier == 100
      n = 2
    else
      n = 0
    end
    return n
  end
  
  def exchange_rate
    require 'money/bank/google_currency'
    @code = self.currency_code
    Money.default_bank = Money::Bank::GoogleCurrency.new
    currency = Money.new(1000, @code).currency
    n = 1.to_money(@code)
    n.exchange_to(:USD)
  rescue
    "Unknown"
  end
  
end
