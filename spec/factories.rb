Factory.define :user do |user|
  user.name                     "Michael Hartl"
  user.email                    "mhartl@example.com"
  user.password                 "foobar"
  user.password_confirmation    "foobar"
  user.association :country
  user.location                 "London"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :region do |region|
  region.region                 "S America"
end

Factory.define :country do |country|
  country.name                  "ABC"
  country.country_code          "A"
  country.currency_code         "JPY"
  country.phone_code            "+1-999"
  country.association :region
end

Factory.sequence :name do |n|
  "ABC#{n}"
end

Factory.sequence :country_code do |n|
  "A#{n}"
end

Factory.define :category do |category|
  category.category             "HR"
  category.target               "Job"
  category.association :user
  #category.submitted_name       "HR"
  #category.submitted_group      "Job"
end

Factory.sequence :category do |n|
  "Cat#{n}"
end

Factory.define :vendor do |vendor|
  vendor.name                   "Abc"
  vendor.address                "London"
  vendor.association :country
  vendor.email                  "vendor@example.com"
end

Factory.define :representation do |representation|
  representation.association :user
  representation.association :vendor
end

Factory.define :medium do |medium|
  medium.medium                 "Abc"
  medium.association :user
end

Factory.define :resource do |resource|
  resource.name                 "Resource"
  resource.association :vendor
  resource.association :category
  resource.association :medium
  resource.length_unit          "Hour"
  resource.length               24
  
end

