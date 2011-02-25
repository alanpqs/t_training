module Sunspot

  class Search::Hit
    def distance
      @stored_values['distance'] # distance_field_name
    end
  end

  class Query::Sort::DistanceSort < Query::Sort::Abstract
    def to_param
      "distance #{direction_for_solr}" # distance_field_name
    end
  end

end

