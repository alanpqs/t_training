# == Schema Information
# Schema version: 20110112001028
#
# Table name: items
#
#  id          :integer         not null, primary key
#  resource_id :integer
#  reference   :string(255)
#  start       :date
#  finish      :date
#  days        :text
#  time_of_day :string(255)
#  cents       :decimal(, )
#  currency    :string(255)
#  venue       :string(255)
#  filled      :boolean
#  notes       :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Item < ActiveRecord::Base
  
  attr_accessible :resource_id, :start, :finish, :days, :reference,
                  :time_of_day, :venue, :filled, :notes, :cents, :currency
  
  attr_accessor :dollar_value, :day_mon, :day_tue, :day_wed, :day_thu, :day_fri, :day_sat, :day_sun, 
                :price     
                
  composed_of :price,
  :class_name => "Money",
  :mapping => [%w(cents cents), %w(currency currency_as_string)],
  :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
  :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
  
  DAYTIME_TYPES = [ "All day", "Mornings", "Afternoons", "Evenings" ]
  WEEKDAY_TYPES = [ "mon", "tue", "wed", "thu", "fri", "sat", "sun"]
                  
  belongs_to :resource
  
  has_many   :issues, :dependent => :destroy
  
  days_regex = /([A-Z][a-z]{2}(\W[A-Z][a-z]{2})*\Z)|\Z/
  
  validates :resource_id,       :presence       => true
  validates :start,             :presence       => true,
                                :uniqueness     => { :scope => [:resource_id, :venue],
                                                    :message => "must not be a duplicate.  If you really want
                                                    to enter the same program starting on the same day, enter
                                                    a different venue" }               
  validates :finish,            :presence       => true, :if => :event?                  
  validates :days,              :length         => { :maximum => 28, :allow_blank => true },
                                :format         => { :with => days_regex }
  validates :time_of_day,       :inclusion      => { :in => DAYTIME_TYPES, :allow_blank => true }
  validates :venue,             :presence       => true,
                                :length         => { :maximum => 100 }
  validates :cents,             :presence       => true,
                                :numericality   => true
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
     :conditions => ["media.scheduled = ? AND finish > ? AND resources.vendor_id = ?", true, Time.now, vendor ],
     :order => "items.start" )
  end
  
  def self.ticketable_events(vendor)
    self.find(:all, :include => [{:resource => :medium}], 
     :conditions => ["media.scheduled = ? AND finish > ? AND resources.vendor_id = ? AND items.filled = ?", 
     true, Time.now, vendor, false ],
     :order => "items.start" )
  end
  
  def self.has_ticketable_events?(vendor)
    result = false
    total = self.count(:all, :joins => [{:resource => :medium}], 
     :conditions => ["media.scheduled = ? AND finish > ? AND resources.vendor_id = ? AND items.filled = ?", 
     true, Time.now, vendor, false ])
    result = true if total > 0
    return result
  end
  
  def self.ticketable_resources(vendor)
    self.find(:all, :include => [{:resource => :medium}], 
      :conditions => ["resources.vendor_id = ? AND media.scheduled = ? AND items.filled = ?", vendor, false, false],
      :order => "resources.name" )
  end
  
  def self.has_ticketable_resources?(vendor)
    result = false
    total = self.count(:all, :joins => [{:resource => :medium}], 
      :conditions => ["resources.vendor_id = ? AND media.scheduled = ? AND items.filled = ?", vendor, false, false])
    result = true if total > 0
    return result  
  end
  
  def self.any_ticketable?(vendor)
    self.has_ticketable_events?(vendor) || self.has_ticketable_resources?(vendor)
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
  
  def split_days_array
    @days = self.days.downcase.split("/")
    @days_of_week = WEEKDAY_TYPES
    @days_of_week.each do |dw|
      if @days.include?(dw)
        if dw == "mon"
          self.day_mon = true
        elsif dw == "tue"
          self.day_tue = true 
        elsif dw == "wed"
          self.day_wed = true   
        elsif dw == "thu"
          self.day_thu = true 
        elsif dw == "fri"
          self.day_fri = true 
        elsif dw == "sat"
          self.day_sat = true 
        elsif dw == "sun"
          self.day_sun = true
        end
      end        
    end
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
  
  def decplaces(vendor)
    @vendor = Vendor.find(vendor)
    @country = Country.find(@vendor.country_id)
    @dp = @country.decimal_places
  end
  
  def formatted_price(vendor)
    prc = sprintf("%.#{self.decplaces(vendor)}f", self.price)
    "#{self.currency_symbol(vendor)} #{prc}"
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
    n.exchange_to(:USD) / @country.currency_multiplier
  rescue
    "Unknown"
  end
  
  def has_issues?
    self.issues.count > 0
  end
  
  private
  
    def event?
      self.resource.medium.scheduled == true unless self.resource_id.blank?
    end
end
