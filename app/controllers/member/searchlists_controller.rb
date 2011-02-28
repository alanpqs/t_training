class Member::SearchlistsController < ApplicationController
  
   before_filter :authenticate,    :except => [:create, :update]    
   before_filter :member_legality_check,  :only   => [:create, :update]
  
  def index
    @title = "Your search preferences"
    @user = current_user
    @searchlists = Searchlist.all_by_member(@user)
    @tag_name = "Create a new search-list"
    cookies[:group_name] = nil
    @search_count = Searchlist.count_by_member(current_user)
  end

  def new
    if params[:group].blank?
      flash[:error] = "You didn't select the aim.  Please try again."
      redirect_to member_focus_path
    else
      @title = "Preferences: build a search-list"
      @focus = params[:group]
      cookies[:group_name] = @focus
      @searchlist = Searchlist.new
      @user = current_user
      @searchlist.user_id = @user.id
      @searchlist.focus = @focus
      @categories = Category.all_authorized_by_target(@focus)
      @media = Medium.all_authorized
      @countries = Country.all
      @regions = Region.all
      @tag_name = "Save your preferences - then search"
    end 
  end
  
  def create
    @searchlist = Searchlist.new(params[:searchlist])
    if @searchlist.save
      @searchlist.adjust_location_search
      flash[:success] = "Your search-list has been permanently saved."
      redirect_to searchlist_recommendations_path(@searchlist)
    else
      @title = "Preferences: build a search-list"
      @media = Medium.all_authorized
      @countries = Country.all
      @regions = Region.all
      @categories = Category.all_authorized_by_target(cookies[:group_name])
      @tag_name = "Save your preferences - then search"
      render "new"  
    end
  end

  def edit
    @title = "Edit search-list"
      @searchlist = Searchlist.find(params[:id])
      if @searchlist.country_id == current_user.country_id
        @searchlist.country_id = nil
      end
      @categories = Category.all_authorized_by_target(@searchlist.focus)
      @media = Medium.all_authorized
      @countries = Country.all
      @regions = Region.all
      @tag_name = "Confirm changes - and search"
  end
  
  def update
    @searchlist = Searchlist.find(params[:id])

    if @searchlist.update_attributes(params[:searchlist])
      @searchlist.adjust_location_search
      flash[:success] = "Your search-list has been updated."
      redirect_to searchlist_recommendations_path(@searchlist)
    else
      @title = "Edit search-list"
      if @searchlist.country_id == current_user.country_id
        @searchlist.country_id = nil
      end
      @categories = Category.all_authorized_by_target(@searchlist.focus)
      @media = Medium.all_authorized
      @countries = Country.all
      @regions = Region.all
      @tag_name = "Confirm changes - and search"
      render "edit"  
    end
  end
  
  def destroy
    @searchlist = Searchlist.find(params[:id])
    @searchlist.destroy
    flash[:success] = "Search-list successfully deleted."
    redirect_to member_searchlists_path  
  end
end
