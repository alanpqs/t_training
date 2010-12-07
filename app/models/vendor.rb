# == Schema Information
# Schema version: 20101206142529
#
# Table name: vendors
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  country_id  :integer
#  address     :string(255)
#  website     :string(255)
#  email       :string(255)
#  phone       :string(255)
#  description :text
#  logo        :binary
#  inactive    :boolean
#  notes       :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Vendor < ActiveRecord::Base
  
  attr_accessible :name, :country_id, :address, :website, :email, :phone, :description, :logo
  
  belongs_to  :country
  has_many    :representations, :dependent => :destroy
  has_many    :users, :through => :representations

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,        :presence   => true,
                          :length     => { :maximum => 50 },
                          :uniqueness => { :scope => :country_id, :case_sensitive => false }
  validates :country_id,  :presence   => true
  validates :address,     :presence   => true,
                          :length     => { :maximum => 150 }
  validates :email,       #:presence   => true, :unless => :contactable?,
                          :format     => { :with => email_regex },
                          :length     => { :maximum => 40, :allow_blank => true }
  #validates :website,     :presence   => true, :unless => :contactable?
  validates :phone,       :length     => { :maximum => 20, :allow_blank => true }
                          #:presence   =>  true, :unless => :contactable?
  validates :description, :length     => { :maximum => 255, :allow_blank => true }
  validates :website,     :presence   => true, :unless => :contactable?
  
  def contactable?
    !self.email.blank? || !self.phone.blank? || !self.website.blank?
  end
end
