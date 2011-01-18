# == Schema Information
# Schema version: 20101211122542
#
# Table name: vendors
#
#  id                :integer         not null, primary key
#  name              :string(255)
#  country_id        :integer
#  address           :string(255)
#  website           :string(255)
#  email             :string(255)
#  phone             :string(255)
#  description       :text
#  verification_code :string(255)
#  verified          :boolean
#  inactive          :boolean
#  notes             :text
#  created_at        :datetime
#  updated_at        :datetime
#  latitude          :float
#  longitude         :float
#  show_reviews      :boolean
#

class Vendor < ActiveRecord::Base
  
  attr_accessible :name, :country_id, :address, :website, :email, :phone, :description, :verified,
                  :verification_code, :show_reviews, :inactive, :notes
  
  belongs_to  :country
  has_many    :representations, :dependent => :destroy
  has_many    :users, :through => :representations
  has_many    :resources, :dependent => :destroy, :order => "name"

  geocoded_by :where_is
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,        :presence   => true,
                          :length     => { :maximum => 50 },
                          :uniqueness => { :scope => :country_id, :case_sensitive => false }
  validates :country_id,  :presence   => true
  validates :address,     :presence   => true,
                          :length     => { :maximum => 50 }
  validates :email,       :presence   => true,
                          :format     => { :with => email_regex },
                          :length     => { :maximum => 40 }
  validates :phone,       :length     => { :maximum => 20, :allow_blank => true }
  validates :description, :length     => { :maximum => 255, :allow_blank => true }
  validates :website,     :length     => { :maximum => 50, :allow_blank => true }
  
  after_validation :fetch_coordinates
  
  #def contactable?
  #  !self.email.blank? || !self.phone.blank? || !self.website.blank?
  #end
  
  def where_is
    [address, country.name].compact.join(', ') unless country_id.nil?
  end
  
  def generated_verification_code
    a = ('a'..'z').to_a.shuffle[0..5].join
    b = (0..9).to_a.shuffle[0..5].join
    c = ('A'..'Z').to_a.shuffle[0..5].join
    d = (a + b + c)
    e = d.split('')
    v_code = e.shuffle.join
  end
  
  def unverified?
    verified == false
  end
  
  def verification_status
    return "Awaiting email verification!" if unverified?
    return nil
  end
  
  def count_reps_excluding_self
    self.users.count - 1
  end
  
  def has_resource?(name)
    @resource = Resource.find(:first, 
                               :conditions => ["name = ? and vendor_id = ?", name, self.id])
    !@resource.nil?
  end
  
  def is_associated_with?(user)
    result = false
    @reps = self.users
    @reps.each do |rep|
      if rep.id == user
        result = true
      end
    end
    return result
  end
  
  def has_scheduled_resources?
    result = false
    unless self.unverified? || self.inactive?
      total = self.resources.count(:all, :joins => :medium, 
                                   :conditions => { :media => { :scheduled => true } })
      result = true if total > 0
    end
    return result
  end
  
  def has_permanent_resources?
    result = false
    unless self.unverified? || self.inactive?
      total = self.resources.count(:all, :joins => :medium, 
                                   :conditions => { :media => { :scheduled => false } })
      result = true if total > 0
    end
    return result
  end
  
  def resourceless?
    !self.has_permanent_resources? && !self.has_scheduled_resources?
  end
  
  def phone_with_code
    a = []
    a << self.phone.scan(/./)
    a = a.flatten
    if a.shift == "0"
      new_number = "(0)"
      a.each {|i| new_number << i}
      display_number = new_number.strip
    else
      display_number = self.phone
    end
    self.country.phone_code + " " + display_number
  end
end
