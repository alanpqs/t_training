# == Schema Information
# Schema version: 20110126061414
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
#

class Issue < ActiveRecord::Base
  
  attr_accessible :item_id, :vendor_id, :event, :cents, :currency, 
                  :no_of_tickets, :contact_method
  
  attr_accessor :ticket_price     
                
  composed_of :ticket_price,
  :class_name => "Money",
  :mapping => [%w(cents cents), %w(currency currency_as_string)],
  :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }
  
  CONTACT_TYPES = [ "Email", "Phone" ]
                  
  belongs_to :vendor
  belongs_to :item
  
  before_create :complete_issue_details
  
  
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
                                
  private
  
    def complete_issue_details
      
    end                                                            
end
