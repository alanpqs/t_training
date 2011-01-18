# == Schema Information
# Schema version: 20110112001028
#
# Table name: items
#
#  id          :integer         not null, primary key
#  resource_id :integer
#  reference   :string(255)
#  start       :date
#  end         :date
#  days        :text
#  time_of_day :string(255)
#  cents       :integer
#  currency    :string(255)
#  venue       :string(255)
#  filled      :boolean
#  notes       :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Item < ActiveRecord::Base
  
  attr_accessible :resource_id, :start, :end, :days, :reference,
                  :time_of_day, :venue, :filled, :notes, :cents, :currency
  
  attr_accessor :dollar_value, :day_mon, :day_tue, :day_wed, :day_thu, :day_fri, :day_sat, :day_sun, 
                :price     
                
  composed_of :price,
  :class_name => "Money",
  :mapping => [%w(cents cents), %w(currency currency_as_string)],
  :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }
  
  DAYTIME_TYPES = [ "All day", "Mornings", "Afternoons", "Evenings" ]
  WEEKDAY_TYPES = [ "mon", "tue", "wed", "thu", "fri", "sat", "sun"]
                  
  belongs_to :resource
  
  days_regex = /([A-Z][a-z]{2}(\W[A-Z][a-z]{2})*\Z)|\Z/
  
  validates :resource_id,       :presence       => true
  validates :start,             :presence       => true,
                                :uniqueness     => { :scope => [:resource_id, :venue] }
  validates :end,               :presence       => true, :if => :event?
  validates :days,              :length         => { :maximum => 28, :allow_blank => true },
                                :format         => { :with => days_regex }
  validates :time_of_day,       :inclusion      => { :in => DAYTIME_TYPES, :allow_blank => true }
  validates :venue,             :presence       => true,
                                :length         => { :maximum => 100 }
  validates :cents,             :numericality   => { :only_integer => true },
                                :presence       => true
  validates :currency,          :presence       => true,
                                :length         => { :maximum => 3 }
  
  
  def ref
    if self.reference.blank? 
      self.id 
    else
      self.reference
    end
  end
  
  def self.scheduled_events(vendor)
    self.find(:all, :include => [{:resource => :medium}], 
      :conditions => ["media.scheduled = ? and end > ? and resources.vendor_id = ?", true, Time.now, vendor ] )
  end
  
  def build_days_array(mon, tue, wed, thu, fri, sat, sun)
    required_days = Array.new
    @weekdays = WEEKDAY_TYPES
    @weekdays.each do |weekday|
      if weekday == "mon"
        @attr = mon
      elsif weekday == "tue"
        @attr = tue
      elsif weekday == "wed"
        @attr = wed
      elsif weekday == "thu"
        @attr = thu
      elsif weekday == "fri"
        @attr = fri
      elsif weekday == "sat"
        @attr = sat
      else
        @attr = sun
      end
      if @attr == "true"
        required_days.push "#{weekday.camelcase}"  
      end
    end
    req_days = required_days.join("/")
    self.days = req_days
  end
  
  def currency_symbol(vendor)
    @vendor = Vendor.find(vendor)
    @country = Country.find(@vendor.country_id)
    sym = @country.currency_symbol
    if sym == "None"
      sym = @country.currency_code
    end
    return sym
  end
  
  def formatted_price(vendor)
    "#{self.currency_symbol(vendor)} #{self.price}"
  end
  
  def availability
    if self.filled?
      return "No"
    else
      return "Yes"
    end
  end
  
  def conversion_to_dollars(vendor)
    require 'money/bank/google_currency'
    @vendor = Vendor.find(vendor)
    @country = Country.find(@vendor.country_id)
    @code = @country.currency_code
    Money.default_bank = Money::Bank::GoogleCurrency.new
    currency = Money.new(1000, @code).currency
    n = self.cents.to_money(@code)
    n.exchange_to(:USD) / 100
  rescue
    "Unknown"
  end
  
  private
  
    def event?
      self.resource.medium.scheduled == true unless self.resource_id.blank?
    end
end
