require 'spec_helper'

describe Fee do
  
  before(:each) do
    @attr = { :band => "A", :bottom_of_range => 0.00, :top_of_range => 20.00, :credits_required => 1 }
  end
  
  it "should create a 'fee' instance given valid attributes" do
    Fee.create!(@attr)
  end
  
  it "should not accept an empty 'band' entry" do
    no_band_fee = Fee.new(@attr.merge(:band => nil))
    no_band_fee.should_not be_valid
  end
  
  it "should not accept a long 'band' entry" do
    long_band_fee = Fee.new(@attr.merge(:band => "AB"))
    long_band_fee.should_not be_valid
  end
  
  it "should not accept a duplicate 'band'" do
    Fee.create!(@attr)
    @duplicate_band = Fee.new(@attr.merge(:band => "A", :cents => 1000))
    @duplicate_band.should_not be_valid
  end
  
  it "should not accept a duplicate 'band' if case is the only difference" do
    Fee.create!(@attr)
    @duplicate_band_case = Fee.new(@attr.merge(:band => "a", :cents => 2000))
    @duplicate_band_case.should_not be_valid
  end
  
  it "should not accept an empty 'bottom_of_range' entry" do
    no_bottom_fee = Fee.new(@attr.merge(:bottom_of_range => nil))
    no_bottom_fee.should_not be_valid
  end
  
  it "should not accept an empty 'top_of_range' entry" do
    no_top_fee = Fee.new(@attr.merge(:top_of_range => nil))
    no_top_fee.should_not be_valid
  end
  
  it "should not accept text in the 'top_of_range' field" do
    text_top_fee = Fee.new(@attr.merge(:top_of_range => "Top"))
    text_top_fee.should_not be_valid
  end
  
  it "should not accept an empty 'credits_required' entry" do
    no_credits_fee = Fee.new(@attr.merge(:credits_required => nil))
    no_credits_fee.should_not be_valid
  end
  
  it "should accept a zero entry for 'credits_required'" do
    zero_credits_fee = Fee.new(@attr.merge(:credits_required => 0))
    zero_credits_fee.should be_valid
  end
  
  it "should only accept an integer entered for 'credits_required'" do
    fraction_credits_fee = Fee.new(@attr.merge(:credits_required => 1.5))
    fraction_credits_fee.should_not be_valid
  end
end
