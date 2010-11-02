class CurrenciesController < ApplicationController
  def index
    @title = "Currencies"
    @currencies = Money::Currency::TABLE
    @s_currencies = @currencies.sort_by { |k,v| v[:iso_code] }
  end

  def show
    @title = "Currency"
  end

end
