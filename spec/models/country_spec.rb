require 'spec_helper'

describe Country do
  
  before(:each) do
    @attr = { :name => "United Kingdom", :country_code => "GBR", :currency_code => "GBP",
              :phone_code => "+35-386", :region_id => 3
    } 
  end
  
  it "should create an instance given valid attributes" do
    Country.create!(@attr)
  end
  
  it "should not accept an empty Name field" do
    no_name_country = Country.new(@attr.merge(:name => ""))
    no_name_country.should_not be_valid
  end
  
  it "should not accept an empty Country_code field" do
    no_country_code = Country.new(@attr.merge(:country_code => ""))
    no_country_code.should_not be_valid
  end
  
  it "should not accept an empty Currency_code field" do
    no_currency_code = Country.new(@attr.merge(:currency_code => ""))
    no_currency_code.should_not be_valid
  end
  
  it "should not accept an empty Phone_code field" do
    no_phone_code = Country.new(@attr.merge(:phone_code => ""))
    no_phone_code.should_not be_valid
  end
  
  it "should not accept an empty Region_id field" do
    no_region_id = Country.new(@attr.merge(:region_id => nil))
    no_region_id.should_not be_valid
  end
  
  it "should reject a long Name" do
    long_name = "a" * 36
    long_name_country = Country.new(@attr.merge(:name => long_name))
    long_name_country.should_not be_valid
  end
  
  it "should reject a long Country_code" do
    long_c_code = "a" * 4
    long_c_code_country = Country.new(@attr.merge(:country_code => long_c_code))
    long_c_code_country.should_not be_valid
  end
  
  it "should reject a long Currency_code" do
    long_curr_code = "a" * 4
    long_curr_code_country = Country.new(@attr.merge(:currency_code => long_curr_code))
    long_curr_code_country.should_not be_valid
  end
  
  it "should reject a long Phone_code" do
    long_phone_code = "+355-356"
    long_phone_code_country = Country.new(@attr.merge(:currency_code => long_phone_code))
    long_phone_code_country.should_not be_valid
  end
  
  it "should reject duplicate Names" do
    Country.create!(@attr)
    country_with_duplicate_name = Country.new(@attr.merge(:country_code => "ZZZ"))
    country_with_duplicate_name.should_not be_valid
  end
  
  it "should reject duplicate Country codes" do
    Country.create!(@attr)
    country_with_duplicate_country_code = Country.new(@attr.merge(:name => "ZZZ"))
    country_with_duplicate_country_code.should_not be_valid
  end
  
  it "should reject Names identical up to case" do
    upcased_name = @attr[:name].upcase
    Country.create!(@attr.merge(:name => upcased_name))
    country_with_duplicate_name = Country.new(@attr)
    country_with_duplicate_name.should_not be_valid
  end
  
  it "should reject Country codes identical up to case" do
    downcased_c_code = @attr[:country_code].downcase
    Country.create!(@attr.merge(:country_code => downcased_c_code))
    country_with_duplicate_c_code = Country.new(@attr)
    country_with_duplicate_c_code.should_not be_valid
  end
  
  it "should accept valid international phone codes" do
    country = %w[Abc Bcd]
    phone = %w[+123 +123-45]
    code = %w[ABC BCD]
    seq = [0,1]
    seq.each do |n|
      valid_phone_code = Country.new(@attr.merge( :country => country[n], 
                                                  :country_code => code[n], :phone_code => phone[n]))
      valid_phone_code.should be_valid
    end
  end
  
  it "should reject invalid international phone codes" do
    country = %w[P Q R]
    phone = %w[123 +1-23-45 +123-2+]
    code = %w[S T U]
    seq = [0,1,2]
    seq.each do |n|
      invalid_phone_code = Country.new(@attr.merge( :country => country[n], 
                                                    :country_code => code[n], :phone_code => phone[n]))
      invalid_phone_code.should_not be_valid
    end
  end
  
  it "should have a numeric Region_id" do
    invalid_region_code = Country.new(@attr.merge(:country => "M", 
                                                  :country_code => "P", :region_id => "A"))
    invalid_region_code.should_not be_valid
  end
end
