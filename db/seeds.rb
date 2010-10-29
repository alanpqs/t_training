["Africa", "Arab World", "Asia", "Europe", "North America", "Pacific", "South America"].each do |region|
  Region.find_or_create_by_region(region)
end
