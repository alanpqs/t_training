# == Schema Information
# Schema version: 20110131131017
#
# Table name: credits
#
#  id         :integer         not null, primary key
#  vendor_id  :integer
#  quantity   :integer
#  currency   :string(255)     default("USD")
#  cents      :decimal(, )
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Credit < ActiveRecord::Base
  
  attr_accessible :vendor_id, :quantity, :currency, :cents, :note
  attr_accessor :payment
  
  composed_of :payment,
  :class_name => "Money",
  :mapping => [%w(cents cents), %w(currency currency_as_string)],
  :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
  :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
  
  belongs_to :vendor
  
  validates :vendor_id,         :presence       => true
  validates :currency,          :presence       => true,
                                :length         => { :maximum => 3 }
  validates :cents,             :presence       => true,
                                :numericality   => true
  validates :quantity,          :presence       => true,
                                :numericality   => { :only_integer => true }
  validates :note,              :length         => { :maximum => 100, :allow_blank => true }
                                
end
