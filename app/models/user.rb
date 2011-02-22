# == Schema Information
# Schema version: 20101206142529
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean
#  country_id         :integer
#  location           :string(255)
#  latitude           :float
#  longitude          :float
#  vendor             :boolean
#

class User < ActiveRecord::Base

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessor   :password
  attr_accessible :name, :email, :password, :password_confirmation, :country_id, :location, :vendor, :admin
  
  belongs_to  :country
  has_many    :categories
  has_many    :representations, :dependent => :destroy
  has_many    :vendors, :through => :representations
  has_many    :media
  has_many    :issues
  has_many    :tickets
  has_many    :searchlists, :dependent => :destroy
  
  geocoded_by :where_is
  
  validates :name,        :presence     => true,
                          :length       => { :maximum => 50 }
  validates :email,       :presence     => true,
                          :format       => { :with => email_regex },
                          :uniqueness   => { :case_sensitive => false }
  validates :password,    :presence     => true,
                          :confirmation => true,
                          :length       => { :within => 6..40 }
  validates :country_id,  :presence     => true
  validates :location,    :presence     => true,
                          :length       => { :maximum => 50 }          
                        
  before_save :encrypt_password
  after_validation :fetch_coordinates
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def where_is
    [location, country.name].compact.join(', ')
  end
  
  def single_company_vendor?
    if self.vendor?
      self.vendors.count == 1
    end
  end
  
  def no_vendors?
    if self.vendor?
      self.vendors.count == 0
    end
  end
  
  def get_single_company_vendor
    if single_company_vendor?
      @representation = Representation.find(:first, :conditions => ["user_id = ?", self.id])
      return @representation.vendor_id
    else
      return nil
    end
  end
  
  def resource_duplicated_to_all?(resource_name)
    status = true
    if self.vendor?
      unless self.single_company_vendor?
        @vendors = self.vendors
        @vendors.each do |vendor|
          @resource = Resource.find(:first, 
               :conditions => ["name = ? and vendor_id =?", resource_name, vendor.id])
          if @resource.nil?
            status = false
          end
        end
      end
    end
    return status
  end
  
  private
  
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end
    
    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
    
    def self.generated_password
      a = ('a'..'z').to_a.shuffle[0..2].join
      b = (0..9).to_a.shuffle[0..2].join
      c = ('A'..'Z').to_a.shuffle[0..2].join
      d = (a + b + c)
      e = d.split(', ')
      pw = e.shuffle.join
    end
end
