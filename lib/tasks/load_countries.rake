require 'csv'

desc "Load countries into database."
task :load_countries => :environment do
    columns = [:name, :country_code, :currency_code, :phone_code, :region_id]
    values = CSV.read("#{RAILS_ROOT}/lib/countries.csv")
    options = { :validate => false }
    before_count = Country.count
    Country.import columns, values, options
    puts "Loaded #{Country.count - before_count} countries."
    
end
