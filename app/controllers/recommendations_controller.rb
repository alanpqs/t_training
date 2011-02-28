class RecommendationsController < ApplicationController
  
  def index
    @title = "Resources recommended for you"
    @searchlist = Searchlist.find(params[:searchlist_id])
    params[:search] ? @searchstring = params[:search] : @searchstring = "\"#{@searchlist.category.category}\" #{@searchlist.topics}"
    params[:search] = @searchstring
    #@searchstring = "'#{@searchlist.category.category}' #{@searchlist.topics}"
    @format_delimiter = "where Format = '#{@searchlist.format_string}'" 
    @location_delimiter = "and Location = '#{@searchlist.location_descriptor}'" 
    @tag_name = "Edit keywords and search again"
    
    reg_id = @searchlist.region_id
    frmt_id = @searchlist.medium_id
    cntry_id = @searchlist.country_id
    search_lat = current_user.latitude.to_f
    search_lng = current_user.longitude.to_f
    search_radius = @searchlist.proximity
    boost_val = 1.0
    query = params[:search] 
    @search = Resource.search do
      if search_radius.blank?
        keywords query
        with(:hidden, false)
        with(:vendor_verified, true)
        with(:region_id, reg_id) unless reg_id.blank?
        with(:format_id, frmt_id) unless frmt_id.blank?
        with(:country_id, cntry_id) unless cntry_id.blank?
        paginate :page => params[:page], :per_page => 20
      else
        keywords query
        with(:hidden, false)
        with(:vendor_verified, true)
        with(:format_id, frmt_id) unless frmt_id.blank?
        paginate :page => params[:page], :per_page => 20
        adjust_solr_params do |params|
          params[:q] = "{!spatial qtype=dismax boost=#{boost_val} circles=#{search_lat},#{search_lng},#{search_radius}}" + "#{params[:q]}"
        end
            
      end
    end
        
    @recommendations = @search.results
    
    store_search
    session[:return_to_resource] = nil
    @image_1 = "tick_octagon.png"
    @image_2 = "ticket_icon.png"
    @instructions = "Taking orders now"
    @instructions_2 = "Discounted tickets on offer"
  end

end
