# == Schema Information
# Schema version: 20110126154759
#
# Table name: fees
#
#  id              :integer         not null, primary key
#  band            :string(255)
#  bottom_of_range :decimal(8, 2)
#  top_of_range    :decimal(8, 2)
#  cents           :decimal(8, 2)
#  currency        :string(255)     default("USD")
#  created_at      :datetime
#  updated_at      :datetime
#

class Fee < ActiveRecord::Base
  
  attr_accessor   :cost
  attr_accessible :band, :bottom_of_range, :top_of_range, :cents, :currency, :cost
  
  
  composed_of :cost,
  :class_name => "Money",
  :mapping => [%w(cents cents), %w(currency currency_as_string)],
  :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
  :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }

  has_many  :issues
  
  validates :band,              :presence       => true,
                                :length         => { :maximum => 1 },
                                :uniqueness     => { :case_sensitive => false }
  validates :bottom_of_range,   :presence       => true,
                                :numericality   => true
  validates :top_of_range,      :presence       => true,
                                :numericality   => true
  validates :cents,             :presence       => true,
                                :numericality   => true
  validates :currency,          :presence       => true,
                                :length         => { :maximum => 3 }
  
  
end
