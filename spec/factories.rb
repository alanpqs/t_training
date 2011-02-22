Factory.define :user do |user|
  user.name                     'Michael Hartl'
  user.email                    'mhartl@example.com'
  user.password                 'foobar'
  user.password_confirmation    'foobar'
  user.association :country
  user.location                 'London'
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :fee do |fee|
  fee.band                      'A'
  fee.bottom_of_range           0.00
  fee.top_of_range              19.99
  fee.credits_required          1
end

Factory.define :region do |region|
  region.region                 'S America'
end

Factory.define :country do |country|
  country.name                  'ABC'
  country.country_code          'A'
  country.currency_code         'JPY'
  country.phone_code            '+1-999'
  country.association :region
end

Factory.sequence :name do |n|
  "ABC#{n}"
end

Factory.sequence :country_code do |n|
  "A#{n}"
end

Factory.define :category do |category|
  category.category             'HR'
  category.target               'Job'
  category.association :user
  category.submitted_name                'HR'
  category.submitted_group               'Job'
end

Factory.sequence :category do |n|
  "Cat#{n}"
end

Factory.define :vendor do |vendor|
  vendor.name                   'Abc'
  vendor.address                'London'
  vendor.association :country
  vendor.email                  'vendor@example.com'
end

Factory.define :representation do |representation|
  representation.association :user
  representation.association :vendor
end

Factory.define :medium do |medium|
  medium.medium                 'Abc'
  medium.association :user
end

Factory.define :resource do |resource|
  resource.name                 'Resource'
  resource.association :vendor
  resource.association :category
  resource.association :medium
  resource.length_unit          'Hour'
  resource.length               24
end

Factory.define :item do |item|
  item.association :resource
  item.start                    Time.now + 7.days
  item.finish                   Time.now + 34.days
  item.cents                    15000
  item.currency                 'USD'
  item.venue                    'Holiday Inn, Cambridge'
end

Factory.sequence :start do |n|
  Time.now + (n + 11).days
end

Factory.sequence :finish do |f|
  Time.now + (f + 10).days
end

Factory.define :issue do |issue|
  issue.association :item
  issue.association :vendor
  issue.fee :fee
  issue.user :user
  issue.no_of_tickets            4
  issue.credits                  12
  issue.event                    true
  issue.cents                    400
  issue.currency                 'USD'
  issue.expiry_date              Time.now + 5.days
end

Factory.define :credit do |credit|
  credit.association :vendor
  credit.quantity                 50
  credit.currency                 'USD'
  credit.cents                    5000
end

Factory.define :searchlist do |searchlist|
  searchlist.association :user
  searchlist.focus                'Job'
  searchlist.association :category
  searchlist.topics               'Pay'
end
  
