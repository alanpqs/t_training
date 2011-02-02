# == Schema Information
# Schema version: 20110131131017
#
# Table name: tickets
#
#  id                :integer         not null, primary key
#  issue_id          :integer
#  user_id           :integer
#  quantity          :integer         default(1)
#  credits           :integer
#  confirmed         :boolean
#  confirmation_date :date
#  created_at        :datetime
#  updated_at        :datetime
#

class Ticket < ActiveRecord::Base
  
  attr_accessible :issue_id, :user_id, :quantity, :credits, :confirmed, :confirmation_date
  
  belongs_to :issue
  belongs_to :user
  
  validates :issue_id,          :presence       => true
  validates :user_id,           :presence       => true
  validates :quantity,          :presence       => true,
                                :numericality   => { :only_integer => true }
  validates :credits,           :presence       => true,
                                :numericality   => { :only_integer => true }
                                
end
