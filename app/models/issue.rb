# == Schema Information
# Schema version: 20110127173925
#
# Table name: issues
#
#  id             :integer         not null, primary key
#  item_id        :integer
#  vendor_id      :integer
#  event          :boolean
#  cents          :decimal(, )
#  currency       :string(255)
#  no_of_tickets  :integer         default(1)
#  contact_method :string(255)     default("Email")
#  created_at     :datetime
#  updated_at     :datetime
#  fee_id         :integer
#  expiry_date    :date
#  user_id        :integer
#

class Issue < ActiveRecord::Base
  
  attr_accessible :item_id, :vendor_id, :event, :cents, :currency, 
                  :no_of_tickets, :contact_method, :fee_id, :expiry_date, :user_id
  
  attr_accessor :ticket_price     
                
  composed_of :ticket_price,
  :class_name => "Money",
  :mapping => [%w(cents cents), %w(currency currency_as_string)],
  :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
  :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
  
  CONTACT_TYPES = [ "Email", "Phone" ]
                  
  belongs_to :vendor
  belongs_to :item
  belongs_to :fee
  belongs_to :user
  
  
  validates :vendor_id,         :presence       => true
  validates :item_id,           :presence       => true
  validates :cents,             :presence       => true,
                                :numericality   => true
  validates :currency,          :presence       => true,
                                :length         => { :maximum => 3 }
  validates :no_of_tickets,     :presence       => true,
                                :numericality   => { :only_integer => true }
  validates :contact_method,    :presence       => true,
                                :inclusion      => { :in => CONTACT_TYPES }
  validates :fee_id,            :presence       => true
  validates :expiry_date,       :presence       => true
  validates :user_id,           :presence       => true 
                                
  
  def d_places(vendor)
    @vendor = Vendor.find(vendor)
    @country = Country.find(@vendor.country_id)
    @dp = @country.decimal_places
  end
  
  def curr_symbol(vendor)
    @vendor = Vendor.find(vendor)
    @country = Country.find(@vendor.country_id)
    sym = @country.currency_symbol
    if sym == "None"
      sym = @country.currency_code
    end
    return sym
  end
  
  def formatted_ticket_price(vendor)
    prc = sprintf("%.#{self.d_places(vendor)}f", self.ticket_price)
    "#{self.curr_symbol(vendor)} #{prc}"
  end
   
  def convert_to_dollars(vendor)
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
  
  def fee_band
    doll_val = self.convert_to_dollars(self.vendor_id)
    @fees = Fee.find(:all)
    @band = 1
    @fees.each do |fee|
      if doll_val >= fee.bottom_of_range && doll_val <= fee.top_of_range
        @band = fee.band
      end
    end
    return @band
  end
  
  def fee_charged
    @fee = Fee.find_by_band(self.fee_band)
    Money.new(@fee.cents, "USD") * self.no_of_tickets
  end                                                          
end
