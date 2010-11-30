require 'spec_helper'

describe City do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @attr = { :name => "Abc de", :country_id => @country.id, :latitude => 20.357, :longitude => -50.36 }
  end
  
  it "should create an instance given valid attributes" do
    City.create!(@attr)
  end
  
  it "should not have an empty city name" do
    no_name_city = City.new(@attr.merge(:name => ""))
    no_name_city.should_not be_valid
  end
  
  it "should not accept a city name longer than 25 characters" do
    long_name = "C" + ("a" * 25)
    long_name_city = City.new(@attr.merge(:name => long_name))
    long_name_city.should_not be_valid
  end
  
  it "should not accept an empty country association" do
    no_country_city = City.new(@attr.merge(:country_id => nil))
    no_country_city.should_not be_valid
  end
  
  it "should accept a correctly formatted name" do
    correct_city = ["Los Angeles", "Rio de Janeiro", "Jeanne d'Arc", "Sanaa'"]
    correct_city.each do |city|
      ok_city = City.new(@attr.merge(:name => city))
      ok_city.should be_valid
    end
  end
  
  it "should reject an incorrectly formatted name" do
    incorrect_city = ["LOS ANGELES", "rio de janeiro", "Jeanne d'ARC", "Sana'a "]
    incorrect_city.each do |city|
      bad_city = City.new(@attr.merge(:name => city))
      bad_city.should_not be_valid
    end
  end
  
  it "should not accept a duplicate city in the same country" do
    City.create!(@attr)
    duplicate_city = City.new(@attr.merge(:latitude => 47.77))
    duplicate_city.should_not be_valid
  end
  
  it "should not accept a duplicate city in the same country up to case" do
    City.create!(@attr)
    duplicate2_city = City.new(@attr.merge(:name => "Abc De"))
    duplicate2_city.should_not be_valid
  end
  
  it "should accept a duplicate city in a different country" do
    @second_country = Factory(:country, :name => "Xyz", :country_code => "Xyz", :region_id => @region.id)
    City.create!(@attr)
    other_country_city = City.new(@attr.merge(:country_id => @second_country.id))
    other_country_city.should be_valid
  end
  
  it "should accept empty latitude and longitude fields" do
    no_dimension_city = City.new(@attr.merge(:latitude => nil, :longitude => nil))
    no_dimension_city.should be_valid
  end
  
  it "should not allow a latitude greater than 90 degrees" do
    wrong_latitude_city = City.new(@attr.merge(:latitude => 90.5))
    wrong_latitude_city.should_not be_valid
  end
  
  it "should not allow a latitude less than - 90 degrees" do
    wrong_latitude_city2 = City.new(@attr.merge(:latitude => -91.5))
    wrong_latitude_city2.should_not be_valid
  end
  
  it "should accept a value within the range -90 .. 90 for latitude" do
    right_latitude_city = City.new(@attr.merge(:latitude => -61.3798))
    right_latitude_city.should be_valid
  end
  
  it "should not allow a longitude greater than 180 degrees" do
    wrong_longitude_city = City.new(@attr.merge(:longitude => 180.5))
    wrong_longitude_city.should_not be_valid
  end
  
  it "should not allow a longitude less than -180 degrees" do
    wrong_longitude_city2 = City.new(@attr.merge(:longitude => -180.5))
    wrong_longitude_city2.should_not be_valid
  end
  
  it "should allow a valid longitude within the range -180 .. 180" do
    right_longitude_city = City.new(@attr.merge(:longitude => -12.45803))
    right_longitude_city.should be_valid
  end
  
  it "should only accept a numeric value for latitude" do
    wrong_latitude_city3 = City.new(@attr.merge(:latitude => "North"))
    wrong_latitude_city3.should_not be_valid
  end
  
  it "should only accept a numeric value for longitude" do
    wrong_longitude_city3 = City.new(@attr.merge(:longitude => "West"))
    wrong_longitude_city3.should_not be_valid
  end
end
