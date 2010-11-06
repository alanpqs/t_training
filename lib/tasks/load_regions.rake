require 'csv'

desc "Load regions into database."
task :load_regions => :environment do
    columns = [:region]
    values = CSV.read("#{RAILS_ROOT}/lib/regions.csv")
    options = { :validate => false }
    before_count = Region.count
    Region.import columns, values, options
    puts "Loaded #{Region.count - before_count} notes."
    
end
